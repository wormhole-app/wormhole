use macros::version_str;

pub struct BuildInfo {
    pub dev_build: bool,
    pub version: String,
}

impl Default for BuildInfo {
    fn default() -> Self {
        Self::new()
    }
}

impl BuildInfo {
    pub fn new() -> BuildInfo {
        BuildInfo {
            dev_build: cfg!(debug_assertions),
            version: version_str!().to_string(),
        }
    }
}
