use std::borrow::{Cow};
use std::rc::Rc;
use magic_wormhole::rendezvous::DEFAULT_RENDEZVOUS_SERVER;
use magic_wormhole::{AppConfig, transfer, transit, Wormhole};
use magic_wormhole::transfer::{APPID, TransferError};
use async_std::sync::{Condvar, Mutex, Arc};
use flutter_rust_bridge::StreamSink;
use futures::FutureExt;
use crate::api::{Events, TUpdate};

pub async fn send_file_impl(file_name: String, file_path: String, code_length: u8, actions: StreamSink<TUpdate>) -> Result<(), ()> {
    let actions = Rc::new(actions);

    let mut relay_hints: Vec<transit::RelayHint> = vec![];
    if relay_hints.is_empty() {
        relay_hints.push(transit::RelayHint::from_urls(
            None,
            [transit::DEFAULT_RELAY_SERVER
                .parse()
                .unwrap()],
        ).unwrap())
    }

    let appconfig = AppConfig {
        id: APPID,
        rendezvous_url: Cow::from(DEFAULT_RENDEZVOUS_SERVER),
        app_version: 1,
    };

    let (server_welcome, connector) =
        match Wormhole::connect_without_code(appconfig, code_length as usize).await {
            Ok(v) => v,
            Err(e) => {
                println!("{}", e);
                actions.add(TUpdate::new(Events::Error, e.to_string()));
                return Err(())
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
            return Err(())
        }
    };

    println!("sending file");
    match Box::pin(send(
        wormhole,
        relay_hints,
        file_path.as_str(),
        file_name.as_str(),
        transit::Abilities::ALL_ABILITIES,
        Rc::clone(&actions)
    ))
        .await {
        Ok(_) => (),
        Err(e) => {
            println!("{}", e);
            actions.add(TUpdate::new(Events::Error, e.to_string()));
            return Err(())
        }
    };
    actions.add(TUpdate::new(Events::Finished, "".to_string()));
    Ok(())
}

async fn send(
    wormhole: Wormhole,
    relay_hints: Vec<transit::RelayHint>,
    file_path: &str,
    file_name: &str,
    transit_abilities: transit::Abilities,
    actions: Rc<StreamSink<TUpdate>>
) -> Result<(), TransferError> {
    let notifier = Arc::new((Mutex::new(false), Condvar::new()));
    let handler = async move {
        let (lock, cvar) = &*notifier;
        let mut started = lock.lock().await;
        while !*started {
            started = cvar.wait(started).await;
        }
    }
        .boxed();

    transfer::send_file_or_folder(wormhole, relay_hints, file_path, file_name, transit_abilities, &transit::log_transit_connection, move |sent, total| {
        if sent == 0 {
            actions.add(TUpdate::new(Events::Total, format!("{}", total)));
            actions.add(TUpdate::new(Events::StartTransfer, "".to_string()));
        }
        actions.add(TUpdate::new(Events::Sent, format!("{}", sent)));
    }, handler).await?;
    Ok(())
}