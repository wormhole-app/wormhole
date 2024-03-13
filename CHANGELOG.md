## 1.1.4
### Changed
- Remove unused audio permission from QR Scanner
- Update screenshots
- Draw white frame around QR/Aztec code in light theme (two avoid qr code inversion issues)

### Improved
- contrast of Send-Info popover

## 1.1.3
### Changed
- use two buttons instead of one split-button
- redesign theme for better contrast
- update magic_wormhole.rs with security fixes

### Fixed
- file_picker cache not cleared correctly

### Added
- Retry Button on error page

## 1.1.2
### Fixed
- fixed invalid textfield behaviour in server settings

## 1.1.1
### Added
- Support for custom server settings

### Changed
- Moved theme switching settings to settings page

## 1.1.0
### Fixed
- invalid Permission error on sdk >= 33

### Added 
- Support for multiple files + folder sharing

## 1.0.5
### Fixed
- Don't allow invalid Code Inputs

### Added
- Deployment to F-Droid

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
