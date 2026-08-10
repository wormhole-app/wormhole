## 1.1.11
### Added
- Send text directly from the send page. The text is transferred as a `message.txt` file so it stays compatible with other magic-wormhole clients (#171). Thanks @abitrolly for opening the issue!
- Options to send or receive another file right after a transfer finishes, so the app no longer has to be restarted between transfers (#188). Thanks @fuguesoft for opening the issue!
- Setting to turn off haptic feedback (#185). Thanks @pablogila for opening the issue!
- Greek translation. Thanks @[theoasim](https://translate.codeberg.org/user/theoasim/) for the translation!

### Changed
- Rework the send page around a single "Send Anything" action, with the remaining ways to send moved behind "More Options" (#182). Thanks @abitrolly for opening the issue and for the feedback!
- The QR scanner now only vibrates when it detects a valid transmit code, instead of on every barcode.
- Update translations for Chinese (Simplified), Dutch, Estonian, Russian, Spanish, Swedish, and Turkish. Thanks @Vistaus, @bittin, @umitseyhan75, @[Outbreak2096](https://translate.codeberg.org/user/Outbreak2096/), @[jrtcdbrg](https://translate.codeberg.org/user/jrtcdbrg/), @[gallegonovato](https://translate.codeberg.org/user/gallegonovato/), @[marksista](https://translate.codeberg.org/user/marksista/), and @[code_gremlin](https://translate.codeberg.org/user/code_gremlin/) for the translations!
- Update dependencies, including Kotlin, the Android Gradle plugin, androidx.documentfile, and fastlane.

### Fixed
- Support `wss://` rendezvous servers (#186). Thanks @Slayerx96 for opening the issue!
- Fix sharing files into the app on iOS closing the app instead of starting a transfer (#187). Thanks @deviant for opening the issue!
- Fix downloads on Android freezing after a download folder was picked (#181). Thanks @gityhubi for opening the issue!
- Fix the Windows build failing on MSVC coroutine deprecation warnings in permission_handler_windows.

All changes not attributed to a specific person were made by @emmiebyte.

## 1.1.10
### Added
- Transfer notification on Android that keeps the app awake during background transfers, preventing battery savers from interrupting them (#174). Thanks @bigfakelaugh for opening the issue!

### Changed
- Use the Android system photo picker for selecting media (#178). Thanks @pablogila for opening the issue, and @luckmagnet for the feedback!
- Update translations for Chinese (Simplified), Dutch, Estonian, and Spanish. Thanks @Vistaus, @[Outbreak2096](https://translate.codeberg.org/user/Outbreak2096/), @[jrtcdbrg](https://translate.codeberg.org/user/jrtcdbrg/), and @[gallegonovato](https://translate.codeberg.org/user/gallegonovato/) for the translations!
- Update dependencies, including Kotlin, Rust crates, and fastlane.
- Add iOS usage description and demo assets required for App Store submission.

### Fixed
- Fix sharing text to the app (#171). Thanks @abitrolly for opening the issue, and @luckmagnet for the feedback!
- Make the send buttons responsive so their labels are no longer cut off (#177). Thanks @pablogila for opening the issue!

All changes not attributed to a specific person were made by @emmiebyte.

## 1.1.9
### Added
- Transfer progress now shows speed and remaining time estimate. Thanks @valivia for opening the issue!
- Download directory picker in settings. Thanks @valivia for opening the issue!
- F-Droid badge and fastlane metadata links for Android screenshots and icon assets. Thanks @UjuiUjuMandan for the contributions!
- Bulgarian translation. Thanks @trunars for the translation!
- Spanish translation. Thanks @acr994 and @cyanwolfg for the translations, and @Iiridayn for opening the issue!
- Italian translation. Thanks @agguato for the translation!
- Turkish translation. Thanks @umitseyhan for the translation!

### Changed
- Update translations for Chinese (Simplified), Dutch, Estonian, French, German, Portuguese, Russian, Spanish, Swedish, and Turkish. Thanks @Outbreak2096, @Vistaus, @jrtcdbrg, @agguato, @JesterInk, @Otto_Ball, @marksista, @acr994, @cyanwolfg, @bittin, and @umitseyhan for the translations!
- Update dependencies, including Flutter, magic-wormhole, Gradle, Kotlin, fastlane, Ruby, and release actions.
- Rename release assets more consistently

### Fixed
- Preserve active transfers when switching tabs. Thanks @valivia for opening the issue!
- Rescale iOS screenshots to match App Store requirements.

All changes not attributed to a specific person were made by @emmiebyte.

## 1.1.8
### Added
- French translation. Thanks @loutr for the translation!
- Dutch translation. Thanks @Vistaus for the translation!
- Kabyle translation. Thanks @butterflyoffire for the translation!
- Chinese (Simplified) translation. Thanks @Outbreak2096 for the translation!
- Swedish translation. Thanks @bittin for the translation!
- Russian translation and store listing. Thanks JesterInk and Otto_Ball for the translations and @Korb for the store metadata!
- Updated Estonian translation. Thanks Priit Jõerüüt for the contribution!
- Reproducible builds for F-Droid compatibility. Thanks @UjuiUjuMandan for the contribution!
- Automated screenshot generation using golden_screenshot and fastlane frameit. Thanks @Korb for opening the issue!

### Changed
- Update dependencies

### Fixed
- Fix sending folders on iOS. Thanks @JesterInk for opening the issue!
- Fix downloaded files going to wrong directory on Android secondary user profiles. Thanks @NinthRebuild for opening the issue!
- Fix share intent on iOS not working
- Improve QR code scanning reliability. Thanks @UjuiUjuMandan for opening the issue!

## 1.1.7
### Added
- Media picker for selecting photos and videos on mobile (Android SDK >= 33 and iOS)
- Language selection dropdown in settings. Thanks @HeCorr for opening the Issue!
- Estonian translation. Thanks @[jrtcdbrg](https://translate.codeberg.org/user/jrtcdbrg/) for the translation!
- Linux DEB and RPM packages. Thanks @sbstn87 for opening the Issue!
- On the fly theme switching. Thanks @HeCorr for opening the Issue!

### Changed
- Update dependencies

### Fixed
- Fix log export in production mode and on iOS
- Fix total file size display when receiving files (also prevents overflow for large files). Thanks @HeCorr for opening the Issue!
- Code type labels (QR / Aztec) are now translatable. Thanks @loutr for opening the Issue!

## 1.1.6
### Added
- Demo file and transfer simulation for App Store review purposes
- Mobile scanner integration for improved QR code scanning (non-F-Droid / IzzyOnDroid builds)
- Custom log printer that only shows stack traces for errors

### Changed
- Update dependencies
- Improve logging format and export functionality

### Fixed
- Fixed F-Droid/IzzyOnDroid build compatibility
- Fixed macOS entitlements for file access and network permissions

## 1.1.5
### Added
- iOS platform support with TestFlight availability (App Store release coming soon)
- macOS platform support with DMG installer
- Windows platform support with portable Zip file
- Deep link support for `wormhole-transfer://` URI scheme (Android thanks @ubuntuegor and iOS)
- Logging of app events to log files for easier debugging (can be exported from Settings)
- Brazilian Portuguese translation (thanks @lagden)
- Ukrainian translation (thanks @xalt7x)

### Changed
- Update magic-wormhole Rust library to latest version with security improvements
- Improved filename sanitization for received files (replaces invalid characters with '_')
- Make the pages scrollable
- Slight changes to the theme for improved readability
- Update dependencies to latest versions

### Fixed
- Android received files not showing in recent files

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
