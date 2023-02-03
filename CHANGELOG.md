## 1.0.2

### Added 
- display transfer type
- support Aztec Code
- Settings entry to always show QR code
### Fixed
- fix transfer-error when file has no extension
- fix wrong fallback-language when system language is not supported
### Changed
- use darktheme on first start instead of system default
- app auto closes after successful file transfer if trigger was share intent
### Improved
- switch to better maintained qr-gen + intent-share lib
- improve frb type codestyle 
- rust code cleanups

## 1.0.1

- update transitive dependencies
- QR scan error Toasts
- copy code info Toast
- Back-stack to navigate from sub-pages
