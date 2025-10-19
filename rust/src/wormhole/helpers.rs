use crate::api::ServerConfig;
use magic_wormhole::transfer::{APPID, AppVersion};
use magic_wormhole::{AppConfig, transit};
use std::borrow::Cow;

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

/// Sanitizes filename for Android filesystems by replacing illegal characters with "-"
/// Based on FAT and Ext filesystem restrictions from android.os.FileUtils
/// Source: https://cs.android.com/android/platform/superproject/+/master:frameworks/base/core/java/android/os/FileUtils.java
#[cfg(target_os = "android")]
pub fn sanitize_filename(filename: &str) -> String {
    fn is_valid_char(c: char) -> bool {
        // Control characters (0x00-0x1f)
        if ('\x00'..='\x1f').contains(&c) {
            return false;
        }

        // FAT illegal characters
        match c {
            '"' | '*' | '/' | ':' | '<' | '>' | '?' | '\\' | '|' | '\x7F' => false,
            '\0' => false, // Ext filesystem illegal character
            _ => true,
        }
    }

    filename
        .chars()
        .map(|c| if is_valid_char(c) { c } else { '-' })
        .collect()
}

/// Sanitizes filename for Windows NTFS filesystem by replacing illegal characters with "-"
/// Source: https://learn.microsoft.com/en-us/windows/win32/fileio/naming-a-file
#[cfg(target_os = "windows")]
pub fn sanitize_filename(filename: &str) -> String {
    fn is_valid_char(c: char) -> bool {
        // Control characters (0x00-0x1f) and DEL (0x7F)
        if ('\x00'..='\x1f').contains(&c) || c == '\x7F' {
            return false;
        }

        // NTFS illegal characters
        match c {
            '<' | '>' | ':' | '"' | '/' | '\\' | '|' | '?' | '*' => false,
            '\0' => false,
            _ => true,
        }
    }

    fn is_reserved_name(name: &str) -> bool {
        let name_upper = name.to_uppercase();
        let base = name_upper.split('.').next().unwrap_or("");

        matches!(
            base,
            "CON" | "PRN" | "AUX" | "NUL"
            | "COM1" | "COM2" | "COM3" | "COM4" | "COM5"
            | "COM6" | "COM7" | "COM8" | "COM9"
            | "LPT1" | "LPT2" | "LPT3" | "LPT4" | "LPT5"
            | "LPT6" | "LPT7" | "LPT8" | "LPT9"
        )
    }

    let sanitized: String = filename
        .chars()
        .map(|c| if is_valid_char(c) { c } else { '-' })
        .collect();

    // Prepend underscore if it's a reserved name
    if is_reserved_name(&sanitized) {
        format!("_{}", sanitized)
    } else {
        sanitized
    }
}

/// Sanitizes filename for macOS (APFS/HFS+) and iOS filesystems by replacing illegal characters with "-"
/// Source: https://stackoverflow.com/questions/20914649/what-characters-are-illegal-on-the-filename-on-ios-or-os-x
#[cfg(any(target_os = "macos", target_os = "ios"))]
pub fn sanitize_filename(filename: &str) -> String {
    fn is_valid_char(c: char) -> bool {
        !matches!(c, ':' | '/' | '\0')
    }

    filename
        .chars()
        .map(|c| if is_valid_char(c) { c } else { '-' })
        .collect()
}

/// Sanitizes filename for Linux ext4 filesystem by replacing illegal characters with "-"
/// Source: https://unix.stackexchange.com/questions/230291/what-characters-are-valid-to-use-in-filenames
#[cfg(target_os = "linux")]
pub fn sanitize_filename(filename: &str) -> String {
    fn is_valid_char(c: char) -> bool {
        !matches!(c, '/' | '\0')
    }

    filename
        .chars()
        .map(|c| if is_valid_char(c) { c } else { '-' })
        .collect()
}

/// Fallback sanitization for other platforms - minimal character replacement
#[cfg(not(any(
    target_os = "android",
    target_os = "windows",
    target_os = "macos",
    target_os = "ios",
    target_os = "linux"
)))]
pub fn sanitize_filename(filename: &str) -> String {
    fn is_valid_char(c: char) -> bool {
        !matches!(c, '/' | '\0')
    }

    filename
        .chars()
        .map(|c| if is_valid_char(c) { c } else { '-' })
        .collect()
}
