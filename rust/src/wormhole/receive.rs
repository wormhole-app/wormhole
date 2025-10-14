use crate::api::{ErrorType, Events, ServerConfig, TUpdate, Value};
use crate::frb_generated::StreamSink;
use crate::wormhole::handler::{gen_handler_dummy, gen_progress_handler, gen_transit_handler};
use crate::wormhole::helpers::{gen_app_config, gen_relay_hints};
use crate::wormhole::path::find_free_filepath;
use async_std::fs::OpenOptions;
use magic_wormhole::{Code, MailboxConnection, Wormhole, transfer, transit};
use std::path::Path;
use std::rc::Rc;

pub async fn request_file_impl(
    passphrase: String,
    storage_folder: String,
    server_config: ServerConfig,
    actions: StreamSink<TUpdate>,
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

    let connection = match MailboxConnection::connect(appconfig, Code(passphrase), true).await {
        Ok(v) => v,
        Err(e) => {
            _ = actions.add(TUpdate::new(
                Events::Error,
                Value::ErrorValue(ErrorType::ConnectionError, e.to_string()),
            ));
            return;
        }
    };

    let wormhole = match Wormhole::connect(connection).await {
        Ok(v) => v,
        Err(e) => {
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
        gen_handler_dummy(),
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

    let file_path = Path::new(storage_folder.as_str()).join(req.file_name());
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

    match req
        .accept(transit_handler, on_progress, &mut file, gen_handler_dummy())
        .await
    {
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
