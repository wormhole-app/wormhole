use crate::api::ServerConfig;
use magic_wormhole::transfer::{APPID, AppVersion};
use magic_wormhole::{AppConfig, transit};
use std::borrow::Cow;

/// Character used to replace illegal characters in filenames
const REPLACEMENT_CHAR: char = '-';

/// Helper function to replace invalid characters in a filename
fn replace_invalid_chars(filename: &str, is_valid: fn(char) -> bool) -> String {
    filename
        .chars()
        .map(|c| if is_valid(c) { c } else { REPLACEMENT_CHAR })
        .collect()
}

/// Platform-specific character validation for Android
/// Based on FAT and Ext filesystem restrictions from android.os.FileUtils
/// Source: https://cs.android.com/android/platform/superproject/+/master:frameworks/base/core/java/android/os/FileUtils.java
#[cfg(target_os = "android")]
fn is_valid_filename_char(c: char) -> bool {
    // Control characters (0x00-0x1f)
    if ('\x00'..='\x1f').contains(&c) {
        return false;
    }

    // FAT illegal characters
    !matches!(
        c,
        '"' | '*' | '/' | ':' | '<' | '>' | '?' | '\\' | '|' | '\x7F' | '\0'
    )
}

/// Platform-specific character validation for Windows
/// Source: https://learn.microsoft.com/en-us/windows/win32/fileio/naming-a-file
#[cfg(target_os = "windows")]
fn is_valid_filename_char(c: char) -> bool {
    // Control characters (0x00-0x1f) and DEL (0x7F)
    if ('\x00'..='\x1f').contains(&c) || c == '\x7F' {
        return false;
    }

    // NTFS illegal characters
    !matches!(
        c,
        '<' | '>' | ':' | '"' | '/' | '\\' | '|' | '?' | '*' | '\0'
    )
}

/// Platform-specific character validation for macOS and iOS
/// Source: https://stackoverflow.com/questions/20914649/what-characters-are-illegal-on-the-filename-on-ios-or-os-x
#[cfg(any(target_os = "macos", target_os = "ios"))]
fn is_valid_filename_char(c: char) -> bool {
    !matches!(c, ':' | '/' | '\0')
}

/// Platform-specific character validation for Linux
/// Source: https://unix.stackexchange.com/questions/230291/what-characters-are-valid-to-use-in-filenames
#[cfg(target_os = "linux")]
fn is_valid_filename_char(c: char) -> bool {
    !matches!(c, '/' | '\0')
}

/// Platform-specific character validation for other platforms (fallback)
#[cfg(not(any(
    target_os = "android",
    target_os = "windows",
    target_os = "macos",
    target_os = "ios",
    target_os = "linux"
)))]
fn is_valid_filename_char(c: char) -> bool {
    !matches!(c, '/' | '\0')
}

/// Checks if a filename is a Windows reserved name
#[cfg(target_os = "windows")]
fn is_reserved_name(name: &str) -> bool {
    let base = name.to_uppercase().split('.').next().unwrap_or("");
    #[rustfmt::skip]
    matches!(
        base,
        "CON" | "PRN" | "AUX" | "NUL"
        | "COM1" | "COM2" | "COM3" | "COM4" | "COM5"
        | "COM6" | "COM7" | "COM8" | "COM9"
        | "LPT1" | "LPT2" | "LPT3" | "LPT4" | "LPT5"
        | "LPT6" | "LPT7" | "LPT8" | "LPT9"
    )
}

/// Sanitizes filename by replacing illegal characters based on the target platform
pub fn sanitize_filename(filename: &str) -> String {
    let sanitized = replace_invalid_chars(filename, is_valid_filename_char);

    // On Windows, prepend underscore if it's a reserved name
    #[cfg(target_os = "windows")]
    if is_reserved_name(&sanitized) {
        return format!("_{}", sanitized);
    }

    sanitized
}

/// generate default relay hints
pub fn gen_relay_hints(s_conf: &ServerConfig) -> anyhow::Result<Vec<transit::RelayHint>> {
    Ok(vec![transit::RelayHint::from_urls(
        None,
        [s_conf.transit_url.parse()?],
    )?])
}

/// generate default app config
pub fn gen_app_config(s_conf: &ServerConfig) -> AppConfig<AppVersion> {
    AppConfig {
        id: APPID,
        rendezvous_url: Cow::from(s_conf.rendezvous_url.clone()),
        app_version: AppVersion::default(),
    }
}
