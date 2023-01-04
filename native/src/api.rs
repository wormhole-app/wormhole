// This is the entry point of your Rust library.
// When adding new code to your project, note that only items used
// here will be transformed to their Dart equivalents.

use std::borrow::Cow;
use std::time::Duration;
use magic_wormhole::rendezvous::DEFAULT_RENDEZVOUS_SERVER;
use magic_wormhole::{AppConfig, transfer, transit, Wormhole};
use magic_wormhole::transfer::{APPID, TransferError};
use async_std::{sync::Arc};
use flutter_rust_bridge::StreamSink;
use futures::executor::block_on;
use futures::FutureExt;

pub fn test(sink: StreamSink<String>) -> anyhow::Result<()> {
    for i in 0..5 {
        std::thread::sleep(Duration::from_secs(1));
        sink.add(format!("Hey from rust stream {}", i));
    }

    Ok(())
}

pub enum Events {
    Code,
    Total,
    Sent
}

pub struct TUpdate {
    pub event: Events,
    pub value: String
}

pub fn send_file(file_name: String, file_path: String, actions: StreamSink<TUpdate>) -> anyhow::Result<()> {
    block_on(async {
        match send_filea(file_name, file_path, actions).await {
            Ok(_) => {}
            Err(_) => {}
        }
    });

    Ok(())
}

async fn send_filea(file_name: String, file_path: String, actions: StreamSink<TUpdate>) -> Result<(), ()> {
    let mut relay_hints: Vec<transit::RelayHint> = vec![];
    if relay_hints.is_empty() {
        relay_hints.push(transit::RelayHint::from_urls(
            None,
            [transit::DEFAULT_RELAY_SERVER
                .parse()
                .unwrap()],
        ).unwrap())
    }

    // let mut uri_rendezvous =  Some(url::Url::parse(DEFAULT_RENDEZVOUS_SERVER).unwrap());
    let code_length = 2;
    let appconfig = AppConfig {
        id: APPID,
        rendezvous_url: Cow::from(DEFAULT_RENDEZVOUS_SERVER),
        app_version: 42,
    };

    let (server_welcome, connector) =
        match Wormhole::connect_without_code(appconfig, code_length).await {
            Ok(v) => v,
            Err(e) => {
                println!("{}", e);
                return Err(())
            }
        };

    let code = server_welcome.code;

    actions.add(TUpdate{event: Events::Code, value: code.clone().0});
    println!("Your code is: {}", code);

    println!("awaiting receiver");
    let wormhole = match connector.await {
        Ok(v) => v,
        Err(e) => {
            println!("{}", e);
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
        actions
    ))
        .await {
        Ok(_) => (),
        Err(e) => {
            println!("{}", e);
            return Err(())
        }
    };
    println!("finished sending");
    Ok(())
}

async fn send(
    wormhole: Wormhole,
    relay_hints: Vec<transit::RelayHint>,
    file_path: &str,
    file_name: &str,
    transit_abilities: transit::Abilities,
    actions: StreamSink<TUpdate>
) -> Result<(), TransferError> {
    use async_std::sync::{Condvar, Mutex};

    let notifier = Arc::new((Mutex::new(false), Condvar::new()));
    let test = async move {
        let (lock, cvar) = &*notifier;
        let mut started = lock.lock().await;
        while !*started {
            started = cvar.wait(started).await;
        }
    }
        .boxed();

    transfer::send_file_or_folder(wormhole, relay_hints, file_path, file_name, transit_abilities, &transit::log_transit_connection, move |sent, total| {
        if sent == 0 {
            actions.add(TUpdate{event: Events::Total, value: format!("{}", total)});
        }
        // pb.set_position(sent);
        actions.add(TUpdate{event: Events::Sent, value: format!("{}", sent)});
    }, test)
        .await?;
    // pb2.finish();
    Ok(())
}