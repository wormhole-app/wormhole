// This is the entry point of your Rust library.
// When adding new code to your project, note that only items used
// here will be transformed to their Dart equivalents.

use flutter_rust_bridge::StreamSink;
use futures::executor::block_on;
use crate::impls::send_file_impl;

pub enum Events {
    Code,
    Total,
    Sent,
    Error,
    Finished,
    StartTransfer
}

pub struct TUpdate {
    pub event: Events,
    pub value: String
}

impl TUpdate {
    pub fn new(event: Events, value: String) -> TUpdate {
        TUpdate{event, value }
    }
}

pub fn send_file(file_name: String, file_path: String, code_length: u8, actions: StreamSink<TUpdate>) -> anyhow::Result<()> {
    block_on(async {
        match send_file_impl(file_name, file_path, code_length, actions).await {
            Ok(_) => {}
            Err(_) => {}
        }
    });

    Ok(())
}