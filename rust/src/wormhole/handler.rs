use crate::api::{ConnectionType, Events, TUpdate, Value};
use crate::frb_generated::StreamSink;
use async_std::sync::{Arc, Condvar, Mutex};
use futures::FutureExt;
use futures::future::BoxFuture;
use magic_wormhole::transit;
use magic_wormhole::transit::TransitInfo;
use std::rc::Rc;

/// generate dummy implementation for cancel handler
pub fn gen_handler_dummy<'a>() -> BoxFuture<'a, ()> {
    let notifier = Arc::new((Mutex::new(false), Condvar::new()));
    async move {
        let (lock, cvar) = &*notifier;
        let mut started = lock.lock().await;
        while !*started {
            started = cvar.wait(started).await;
        }
    }
    .boxed()
}

/// generate new transithandler which callbacks connectiontype through streamsink
pub fn gen_transit_handler(actions: Rc<StreamSink<TUpdate>>) -> Box<dyn Fn(TransitInfo)> {
    let fnn = move |info: TransitInfo| {
        match info.conn_type {
            transit::ConnectionType::Direct => {
                _ = actions.add(TUpdate::new(
                    Events::ConnectionType,
                    Value::ConnectionType(ConnectionType::Direct, info.peer_addr.to_string()),
                ));
            }
            transit::ConnectionType::Relay { name: Some(n) } => {
                _ = actions.add(TUpdate::new(
                    Events::ConnectionType,
                    Value::ConnectionType(ConnectionType::Relay, n),
                ));
            }
            transit::ConnectionType::Relay { name: None } => {
                _ = actions.add(TUpdate::new(
                    Events::ConnectionType,
                    Value::ConnectionType(ConnectionType::Relay, info.peer_addr.to_string()),
                ));
            }
            _ => {}
        };
    };
    Box::new(fnn)
}

/// generate new progress handler to callback through streamsink
pub fn gen_progress_handler(action: Rc<StreamSink<TUpdate>>) -> Box<dyn Fn(u64, u64)> {
    let handler = move |received: u64, total: u64| {
        if received == 0 {
            _ = action.add(TUpdate::new(Events::Total, Value::Int(total as i32)));
            _ = action.add(TUpdate::new(Events::StartTransfer, Value::Int(-1)));
        }
        _ = action.add(TUpdate::new(Events::Sent, Value::Int(received as i32)));
    };
    Box::new(handler)
}
