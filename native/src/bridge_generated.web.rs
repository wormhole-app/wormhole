use super::*;
// Section: wire functions

#[wasm_bindgen]
pub fn wire_init(port_: MessagePort, temp_file_path: String) {
    wire_init_impl(port_, temp_file_path)
}

#[wasm_bindgen]
pub fn wire_send_files(port_: MessagePort, file_paths: JsValue, name: String, code_length: u8) {
    wire_send_files_impl(port_, file_paths, name, code_length)
}

#[wasm_bindgen]
pub fn wire_send_folder(port_: MessagePort, folder_path: String, name: String, code_length: u8) {
    wire_send_folder_impl(port_, folder_path, name, code_length)
}

#[wasm_bindgen]
pub fn wire_request_file(port_: MessagePort, passphrase: String, storage_folder: String) {
    wire_request_file_impl(port_, passphrase, storage_folder)
}

#[wasm_bindgen]
pub fn wire_get_passphrase_uri(
    port_: MessagePort,
    passphrase: String,
    rendezvous_server: Option<String>,
) {
    wire_get_passphrase_uri_impl(port_, passphrase, rendezvous_server)
}

#[wasm_bindgen]
pub fn wire_get_build_time(port_: MessagePort) {
    wire_get_build_time_impl(port_)
}

// Section: allocate functions

// Section: related functions

// Section: impl Wire2Api

impl Wire2Api<String> for String {
    fn wire2api(self) -> String {
        self
    }
}
impl Wire2Api<Vec<String>> for JsValue {
    fn wire2api(self) -> Vec<String> {
        self.dyn_into::<JsArray>()
            .unwrap()
            .iter()
            .map(Wire2Api::wire2api)
            .collect()
    }
}
impl Wire2Api<Option<String>> for Option<String> {
    fn wire2api(self) -> Option<String> {
        self.map(Wire2Api::wire2api)
    }
}

impl Wire2Api<Vec<u8>> for Box<[u8]> {
    fn wire2api(self) -> Vec<u8> {
        self.into_vec()
    }
}
// Section: impl Wire2Api for JsValue

impl Wire2Api<String> for JsValue {
    fn wire2api(self) -> String {
        self.as_string().expect("non-UTF-8 string, or not a string")
    }
}
impl Wire2Api<Option<String>> for JsValue {
    fn wire2api(self) -> Option<String> {
        (!self.is_undefined() && !self.is_null()).then(|| self.wire2api())
    }
}
impl Wire2Api<u8> for JsValue {
    fn wire2api(self) -> u8 {
        self.unchecked_into_f64() as _
    }
}
impl Wire2Api<Vec<u8>> for JsValue {
    fn wire2api(self) -> Vec<u8> {
        self.unchecked_into::<js_sys::Uint8Array>().to_vec().into()
    }
}
