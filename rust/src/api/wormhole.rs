use crate::frb_generated::StreamSink;
/// Entrypoint of Wormhole Rust backend
use crate::wormhole::receive::request_file_impl;
use crate::wormhole::send::{send_file_impl, send_files_impl};
use crate::wormhole::zip::list_dir;
use futures::FutureExt;
use futures::executor::block_on;
use futures::future::{AbortHandle, Abortable, BoxFuture, Either, Shared, pending, select};
use log::{debug, error, info};
use magic_wormhole::rendezvous::DEFAULT_RENDEZVOUS_SERVER;
use magic_wormhole::{Code, transit};
use std::cmp::Ordering;
use std::collections::HashMap;
use std::future::Future;
use std::path::PathBuf;
use std::rc::Rc;
use std::str::FromStr;
use std::string::ToString;
use std::sync::Mutex;

// make types neccessary for api visible
pub use crate::wormhole::types::build_info::BuildInfo;
pub use crate::wormhole::types::error_types::ErrorType;
pub use crate::wormhole::types::events::Events;
pub use crate::wormhole::types::t_update::TUpdate;
pub use crate::wormhole::types::value::{ConnectionType, Value};

// Initialize flutter_logger for Rust log integration
flutter_logger::flutter_logger_init!();

/// Keep a global temp file path reference
static TEMP_FILE_PATH: Mutex<Option<String>> = Mutex::new(None);

/// initialize backend api
pub fn init(temp_file_path: String) {
    info!(
        "Initializing Wormhole backend with temp path: {}",
        temp_file_path
    );
    *TEMP_FILE_PATH.lock().unwrap() = Some(temp_file_path);
}

pub struct ServerConfig {
    pub rendezvous_url: String,
    pub transit_url: String,
}

/// Passed to a send to cancel it from the frontend
#[frb(opaque)]
pub struct CancelToken {
    handle: AbortHandle,
    cancelled: Shared<BoxFuture<'static, ()>>,
}

impl CancelToken {
    #[frb(sync)]
    #[allow(clippy::new_without_default)]
    pub fn new() -> CancelToken {
        let (handle, registration) = AbortHandle::new_pair();
        // the pending future never finishes, so this resolves on abort only
        let cancelled = Abortable::new(pending::<()>(), registration)
            .map(|_| ())
            .boxed()
            .shared();
        CancelToken { handle, cancelled }
    }

    #[frb(sync)]
    pub fn cancel(&self) {
        info!("Cancelling transfer");
        self.handle.abort();
    }

    pub(crate) fn is_cancelled(&self) -> bool {
        self.handle.is_aborted()
    }

    /// future resolving on cancel, to pass as magic-wormhole cancel handler
    pub(crate) fn future(&self) -> Shared<BoxFuture<'static, ()>> {
        self.cancelled.clone()
    }

    /// run the future unless the transfer gets cancelled first, None on cancel
    pub(crate) async fn guard<T>(&self, future: impl Future<Output = T>) -> Option<T> {
        futures::pin_mut!(future);
        match select(self.future(), future).await {
            Either::Left(_) => None,
            Either::Right((v, _)) => Some(v),
        }
    }
}

pub fn send_files(
    file_paths: Vec<String>,
    name: String,
    code_length: u8,
    server_config: ServerConfig,
    cancel: &CancelToken,
    actions: StreamSink<TUpdate>,
) {
    let actions = Rc::new(actions);

    match file_paths.len().cmp(&1) {
        Ordering::Less => {
            error!("No files provided for send_files");
            _ = actions.add(TUpdate::new(
                Events::Error,
                Value::Error(ErrorType::InvalidFilename),
                // todo proper error message
            ));
        }
        Ordering::Equal => {
            debug!("Sending single file: {}", file_paths[0]);
            block_on(async {
                send_file_impl(
                    name,
                    file_paths[0].to_string(),
                    code_length,
                    server_config,
                    actions,
                    cancel,
                )
                .await;
            });
        }
        Ordering::Greater => {
            info!(
                "Sending multiple files ({}), will create zip",
                file_paths.len()
            );
            let files: HashMap<String, String> = file_paths
                .iter()
                .map(|x| {
                    (
                        x.to_string(),
                        PathBuf::from(x)
                            .file_name()
                            .unwrap_or_default()
                            .to_str()
                            .unwrap_or_default()
                            .to_string(),
                    )
                })
                .collect();
            let temp_dir = TEMP_FILE_PATH
                .lock()
                .unwrap()
                .clone()
                .expect("set temp file func not called");
            block_on(async {
                send_files_impl(
                    name,
                    files,
                    code_length,
                    temp_dir,
                    server_config,
                    actions,
                    cancel,
                )
                .await;
            });
        }
    }
}

pub fn send_folder(
    folder_path: String,
    name: String,
    code_length: u8,
    server_config: ServerConfig,
    cancel: &CancelToken,
    actions: StreamSink<TUpdate>,
) {
    let files = match list_dir(folder_path) {
        Ok(v) => v,
        Err(e) => {
            error!("Failed to list directory: {:?}", e);
            _ = actions.add(TUpdate::new(
                Events::Error,
                Value::Error(ErrorType::InvalidFilename),
                // todo proper error message
            ));
            return;
        }
    };

    let temp_dir = TEMP_FILE_PATH
        .lock()
        .unwrap()
        .clone()
        .expect("set temp file func not called");

    block_on(async {
        send_files_impl(
            name,
            files,
            code_length,
            temp_dir,
            server_config,
            Rc::new(actions),
            cancel,
        )
        .await;
    });
}

pub fn request_file(
    passphrase: String,
    storage_folder: String,
    server_config: ServerConfig,
    cancel: &CancelToken,
    actions: StreamSink<TUpdate>,
) {
    block_on(async {
        request_file_impl(passphrase, storage_folder, server_config, actions, cancel).await;
    });
}

pub fn get_passphrase_uri(passphrase: String, rendezvous_server: Option<String>) -> String {
    let url = rendezvous_server.and_then(|a| url::Url::parse(a.as_str()).ok());

    magic_wormhole::uri::WormholeTransferUri {
        code: Code::from_str(&passphrase).unwrap(),
        rendezvous_server: url,
        is_leader: false,
    }
    .to_string()
}

pub fn get_build_info() -> BuildInfo {
    BuildInfo::new()
}

pub fn default_rendezvous_url() -> String {
    DEFAULT_RENDEZVOUS_SERVER.to_string()
}

pub fn default_transit_url() -> String {
    transit::DEFAULT_RELAY_SERVER.to_string()
}
