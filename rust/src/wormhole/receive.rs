use crate::api::{CancelToken, ErrorType, Events, ServerConfig, TUpdate, Value};
use crate::frb_generated::StreamSink;
use crate::wormhole::handler::{gen_progress_handler, gen_transit_handler};
use crate::wormhole::helpers::{gen_app_config, gen_relay_hints, sanitize_filename};
use crate::wormhole::path::find_free_filepath;
use async_std::fs::{OpenOptions, remove_file};
use magic_wormhole::{Code, MailboxConnection, Wormhole, transfer, transit};
use std::path::Path;
use std::rc::Rc;
use std::str::FromStr as _;

fn parse_code(passphrase: &str) -> Result<Code, String> {
    Code::from_str(passphrase).map_err(|error| error.to_string())
}

pub async fn request_file_impl(
    passphrase: String,
    storage_folder: String,
    server_config: ServerConfig,
    actions: StreamSink<TUpdate>,
    cancel: &CancelToken,
) {
    let actions = Rc::new(actions);

    // push event that we are in connection state
    _ = actions.add(TUpdate::new(Events::Connecting, Value::Int(0)));

    let relay_hints = match gen_relay_hints(&server_config) {
        Ok(v) => v,
        Err(_) => {
            _ = actions.add(TUpdate::new(
                Events::Error,
                Value::Error(ErrorType::ConnectionError),
            ));
            return;
        }
    };
    let appconfig = gen_app_config(&server_config);

    let code = match parse_code(&passphrase) {
        Ok(code) => code,
        Err(e) => {
            _ = actions.add(TUpdate::new(
                Events::Error,
                Value::ErrorValue(ErrorType::ConnectionError, e),
            ));
            return;
        }
    };

    // the connection phase has no cancel handler of its own, so drop the
    // connection futures on cancel
    let connection = match cancel
        .guard(MailboxConnection::connect(appconfig, code, true))
        .await
    {
        None => return,
        Some(Ok(v)) => v,
        Some(Err(e)) => {
            _ = actions.add(TUpdate::new(
                Events::Error,
                Value::ErrorValue(ErrorType::ConnectionError, e.to_string()),
            ));
            return;
        }
    };

    let wormhole = match cancel.guard(Wormhole::connect(connection)).await {
        None => return,
        Some(Ok(v)) => v,
        Some(Err(e)) => {
            _ = actions.add(TUpdate::new(
                Events::Error,
                Value::ErrorValue(ErrorType::ConnectionError, e.to_string()),
            ));
            return;
        }
    };

    let req = match transfer::request_file(
        wormhole,
        relay_hints,
        transit::Abilities::ALL,
        cancel.future(),
    )
    .await
    {
        Ok(v) => v,
        Err(e) => {
            _ = actions.add(TUpdate::new(
                Events::Error,
                Value::ErrorValue(ErrorType::FileRequestError, e.to_string()),
            ));
            return;
        }
    };

    /* If None, the task got cancelled */
    let req = match req {
        Some(req) => req,
        None => return,
    };

    /*
     * Control flow is a bit tricky here:
     * - First of all, we ask if we want to receive the file at all
     * - Then, we check if the file already exists
     * - If it exists, ask whether to overwrite and act accordingly
     * - If it doesn't, directly accept, but DON'T overwrite any files
     */

    let sanitized_filename = sanitize_filename(&req.file_name());
    let file_path = Path::new(storage_folder.as_str()).join(sanitized_filename);
    let file_path = match find_free_filepath(file_path) {
        None => {
            _ = actions.add(TUpdate::new(
                Events::Error,
                Value::Error(ErrorType::NoFilePathFound),
            ));
            return;
        }
        Some(s) => s,
    };

    /* Then, accept if the file exists */
    let mut file = match OpenOptions::new()
        .write(true)
        .create_new(true)
        .open(&file_path)
        .await
    {
        Ok(v) => v,
        Err(e) => {
            _ = actions.add(TUpdate::new(
                Events::Error,
                Value::ErrorValue(ErrorType::FileOpen, e.to_string()),
            ));
            return;
        }
    };

    let on_progress = gen_progress_handler(Rc::clone(&actions));
    let transit_handler = gen_transit_handler(Rc::clone(&actions));

    let result = req
        .accept(transit_handler, on_progress, &mut file, cancel.future())
        .await;

    // magic-wormhole notifies the peer and returns Ok when cancelled
    if cancel.is_cancelled() {
        drop(file);
        let _ = remove_file(&file_path).await;
        return;
    }

    match result {
        Ok(_) => {}
        Err(e) => {
            // todo better handling
            _ = actions.add(TUpdate::new(
                Events::Error,
                Value::ErrorValue(ErrorType::TransferError, e.to_string()),
            ));
            return;
        }
    }
    _ = actions.add(TUpdate::new(
        Events::Finished,
        Value::String(file_path.to_str().unwrap_or_default().to_string()),
    ));
}
