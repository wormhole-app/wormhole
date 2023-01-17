use crate::api::{Events, TUpdate};
use async_std::fs::OpenOptions;
use async_std::sync::{Arc, Condvar, Mutex};
use flutter_rust_bridge::StreamSink;
use futures::future::BoxFuture;
use futures::FutureExt;
use magic_wormhole::rendezvous::DEFAULT_RENDEZVOUS_SERVER;
use magic_wormhole::transfer::{AppVersion, TransferError, APPID};
use magic_wormhole::{transfer, transit, AppConfig, Code, Wormhole};
use std::borrow::Cow;
use std::path::{Path, PathBuf};
use std::rc::Rc;

fn gen_relay_hints() -> Vec<transit::RelayHint> {
    let mut relay_hints: Vec<transit::RelayHint> = vec![];
    if relay_hints.is_empty() {
        relay_hints.push(
            transit::RelayHint::from_urls(None, [transit::DEFAULT_RELAY_SERVER.parse().unwrap()])
                .unwrap(),
        )
    }
    relay_hints
}

fn gen_app_config() -> AppConfig<AppVersion> {
    AppConfig {
        id: APPID,
        rendezvous_url: Cow::from(DEFAULT_RENDEZVOUS_SERVER),
        app_version: AppVersion {},
    }
}

fn gen_handler_dummy<'a>() -> BoxFuture<'a, ()> {
    let notifier = Arc::new((Mutex::new(false), Condvar::new()));
    return async move {
        let (lock, cvar) = &*notifier;
        let mut started = lock.lock().await;
        while !*started {
            started = cvar.wait(started).await;
        }
    }
    .boxed();
}

pub async fn send_file_impl(
    file_name: String,
    file_path: String,
    code_length: u8,
    actions: StreamSink<TUpdate>,
) -> Result<(), ()> {
    let actions = Rc::new(actions);

    let relay_hints = gen_relay_hints();
    let appconfig = gen_app_config();

    let (server_welcome, connector) =
        match Wormhole::connect_without_code(appconfig, code_length as usize).await {
            Ok(v) => v,
            Err(e) => {
                println!("{}", e);
                actions.add(TUpdate::new(Events::Error, e.to_string()));
                return Err(());
            }
        };

    let code = server_welcome.code;
    actions.add(TUpdate::new(Events::Code, code.clone().0));

    println!("awaiting receiver");
    let wormhole = match connector.await {
        Ok(v) => v,
        Err(e) => {
            println!("{}", e);
            actions.add(TUpdate::new(Events::Error, e.to_string()));
            return Err(());
        }
    };

    println!("sending file");
    match Box::pin(send(
        wormhole,
        relay_hints,
        file_path.as_str(),
        file_name.as_str(),
        transit::Abilities::ALL_ABILITIES,
        Rc::clone(&actions),
    ))
    .await
    {
        Ok(_) => (),
        Err(e) => {
            println!("{}", e);
            actions.add(TUpdate::new(Events::Error, e.to_string()));
            return Err(());
        }
    };
    actions.add(TUpdate::new(Events::Finished, file_name));
    Ok(())
}

pub async fn request_file_impl(
    passphrase: String,
    storage_folder: String,
    actions: StreamSink<TUpdate>,
) {
    let actions = Rc::new(actions);

    let relay_hints = gen_relay_hints();
    let appconfig = gen_app_config();

    let (_, wormhole) = match Wormhole::connect_with_code(appconfig, Code(passphrase)).await {
        Ok(v) => v,
        Err(e) => {
            println!("{}", e);
            actions.add(TUpdate::new(Events::Error, e.to_string()));
            return;
        }
    };

    let req = match transfer::request_file(
        wormhole,
        relay_hints,
        transit::Abilities::ALL_ABILITIES,
        gen_handler_dummy(),
    )
    .await
    {
        Ok(v) => v,
        Err(e) => {
            actions.add(TUpdate::new(Events::Error, e.to_string()));
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

    let file_name = match req.filename.file_name() {
        None => {
            actions.add(TUpdate::new(
                Events::Error,
                "Sender did not specify an filename".to_string(),
            ));
            return;
        }
        Some(v) => v,
    };
    let file_path = Path::new(storage_folder.as_str()).join(file_name);
    let file_path = match find_free_filepath(file_path) {
        None => {
            actions.add(TUpdate::new(
                Events::Error,
                "No valid filepath could be found".to_string(),
            ));
            return;
        }
        Some(s) => s,
    };

    let action_c = Rc::clone(&actions);
    let on_progress = move |received, total| {
        if received == 0 {
            action_c.add(TUpdate::new(Events::Total, format!("{}", total)));
            action_c.add(TUpdate::new(Events::StartTransfer, "".to_string()));
        }
        action_c.add(TUpdate::new(Events::Sent, format!("{}", received)));
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
            actions.add(TUpdate::new(Events::Error, e.to_string()));
            return;
        }
    };

    match req
        .accept(
            &transit::log_transit_connection,
            on_progress,
            &mut file,
            gen_handler_dummy(),
        )
        .await
    {
        Ok(_) => {}
        Err(e) => {
            // todo better handling
            actions.add(TUpdate::new(Events::Error, e.to_string()));
            return;
        }
    }
    actions.add(TUpdate::new(
        Events::Finished,
        file_path.to_str().unwrap().to_string(),
    ));
}

fn find_free_filepath(path: PathBuf) -> Option<PathBuf> {
    if !path.exists() {
        return Some(path);
    }

    let ext = match path.extension().and_then(|x| x.to_str()) {
        None => return None,
        Some(s) => s,
    };

    match path.file_stem().and_then(|x| x.to_str()) {
        None => None,
        Some(v) => {
            let p = format!("{}(copy).{}", v, ext);
            let mut path = path.clone();
            path.set_file_name(p.as_str());
            return find_free_filepath(path.to_path_buf());
        }
    }
}

async fn send(
    wormhole: Wormhole,
    relay_hints: Vec<transit::RelayHint>,
    file_path: &str,
    file_name: &str,
    transit_abilities: transit::Abilities,
    actions: Rc<StreamSink<TUpdate>>,
) -> Result<(), TransferError> {
    let handler = gen_handler_dummy();
    transfer::send_file_or_folder(
        wormhole,
        relay_hints,
        file_path,
        file_name,
        transit_abilities,
        &transit::log_transit_connection,
        move |sent, total| {
            if sent == 0 {
                actions.add(TUpdate::new(Events::Total, format!("{}", total)));
                actions.add(TUpdate::new(Events::StartTransfer, "".to_string()));
            }
            actions.add(TUpdate::new(Events::Sent, format!("{}", sent)));
        },
        handler,
    )
    .await?;
    Ok(())
}

#[cfg(test)]
mod tests {
    use async_std::task::block_on;
    use flutter_rust_bridge::rust2dart::Rust2Dart;
    // Note this useful idiom: importing names from outer (for mod tests) scope.
    use super::*;

    #[test]
    fn test_add() {
        println!("test");
        block_on(async {
            request_file_impl(
                "7-microscope-gazelle".to_string(),
                "/home/lukas/Downloads".to_string(),
                StreamSink::new(Rust2Dart::new(0)),
            )
            .await;
        });
    }
}
