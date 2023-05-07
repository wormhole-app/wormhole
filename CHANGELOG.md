## 1.0.4
### Changed
- use FOSS QR Code scanner lib ZXing

### Fixed
- Device orientation on Tablets

## 1.0.3

### Added
- add swedish translation
- add help dialog on code page
### Fixed
- fix storage permission error
- fix border glitch of aztec code
### Changed
- set device orientation based on device type
- prettier code-length selection buttons

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
