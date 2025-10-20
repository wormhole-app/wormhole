# Wormhole

[![Latest Release](https://img.shields.io/github/v/release/wormhole-app/wormhole)](https://github.com/wormhole-app/wormhole/releases)
[![Build Status](https://img.shields.io/github/actions/workflow/status/wormhole-app/wormhole/ci.yml?branch=main)](https://github.com/wormhole-app/wormhole/actions)

An open source Android, iOS, macOS, and Windows App for sending/receiveing files using the magic-wormhole protocol.

[<img src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" alt="Get it on Google Play Store" height="75">](https://play.google.com/store/apps/details?id=eu.heili.wormhole)[<img src="https://gitlab.com/IzzyOnDroid/repo/-/raw/master/assets/IzzyOnDroid.png" alt="Get it on IzzyOnDroid" height="75">](https://apt.izzysoft.de/packages/eu.heili.wormhole)

[<img src="https://img.shields.io/badge/TestFlight-Join_Beta-0D96F6?style=for-the-badge&logo=apple&logoColor=white" alt="Join TestFlight Beta" height="75">](https://testflight.apple.com/join/dUGWPGtc)

## Preview

<p><img src="android/fastlane/metadata/android/en-US/images/phoneScreenshots/screenshot--1705799885.007992.png" width="32%"  alt=""/> 
<img src="android/fastlane/metadata/android/en-US/images/phoneScreenshots/screenshot--1705799886.892108.png" width="32%"  alt=""/> 
<img src="android/fastlane/metadata/android/en-US/images/phoneScreenshots/screenshot--1705799914.5084915.png" width="32%"  alt=""/></p>

## Features

- Open source: Lightweight, clean and secure.
- Send/receive files via the magic-wormhole protocol
- Generate QR code of receive code
- Scan QR-Code of sender
- Dark theme

## Compatible Desktop Applications:

- [Warp](https://apps.gnome.org/app/app.drey.Warp/)

(feel free to add yours)

## Development

### Build app

Install Android SDK, Flutter and rustup.

You might want to set your Java version to <20:\
add to your gradle.properties:\
`org.gradle.java.home=/usr/lib/jvm/java-17-openjdk/`

Install Android ndk version 24.0.8215888:\
`sdkmanager "ndk;24.0.8215888"`

Add rust Android targets:\
`rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android`

Install cargo-ndk:\
`cargo install cargo-ndk`

Build apk+appbundle:\
`make apk`

Dev Linux build:\
`make linux`

### Format/Lint

Format source code:\
`make format`

Lint source code:\
`make lint`

### Code generation

Generate translations:\
`make translation`

Generate Flutter-Rust-Bridge code bindings:\
`make codegen`

### Cleanup 

Clean build files:\
`make clean`

## Contribution

Every kind of contribution is welcome. :) 

If you know other languages than English/German/Swedish feel free to add new translations in `lib/l10n/`.
If you face any issues with the app you can gladly open an issue or fix it via a PR.

## Used libraries

A great thanks to all the maintainers of the used libraries. 
Especially to [magic-wormhole](https://crates.io/crates/magic-wormhole) and [flutter_rust_bridge](https://github.com/fzyzcjy/flutter_rust_bridge).

## Flutter

* [flutter_rust_bridge](https://github.com/fzyzcjy/flutter_rust_bridge)(MIT) - Flutter <-> Rust ffi code generation
* [ffi](https://pub.dev/packages/ffi)(BSD-3-Clause) - call native .so lib code from dart
* [file_picker](https://pub.dev/packages/file_picker)(MIT) - OS Native Filepicker Impl.
* [path_provider](https://pub.dev/packages/path_provider)(BSD-3-Clause) - Get Platforms common paths
* [share_plus](https://pub.dev/packages/share_plus)(BSD-3-Clause) - Open Platforms share dialog
* [open_filex](https://pub.dev/packages/open_filex)(BSD-3-Clause) - Open Platforms file-open dialog
* [barcode_widget](https://pub.dev/packages/barcode_widget)(Apache-2.0) - QR/Aztec code generation
* [flutter_zxing](https://pub.dev/packages/flutter_zxing)(MIT) - QR/Aztec code scanner
* [provider](https://pub.dev/packages/provider)(MIT) - Consumer/Provider patterns
* [shared_preferences](https://pub.dev/packages/shared_preferences)(BSD-3-Clause) - Platform wrapper for key-value pairs
* [share_handler](https://pub.dev/packages/share_handler)(MIT) - receive of platform share intents
* [vibration](https://pub.dev/packages/vibration)(BSD-2-Clause) - control haptic feedbacks
* [intl](https://pub.dev/packages/intl)(BSD-3-Clause) - handle localisation
* [fluttertoast](https://pub.dev/packages/fluttertoast)(MIT) - pretty toast popups
* [toggle_switch](https://pub.dev/packages/toggle_switch)(MIT) - pretty toggle switches
* [permission_handler](https://pub.dev/packages/permission_handler) (MIT) - handle platform permissions
* [url_launcher](https://pub.dev/packages/url_launcher) (BSD-3-Clause) - open urls in platform default browser
* [flutter_close_app](https://github.com/wormhole-app/wormhole/tree/main/packages/flutter_close_app)(MIT) - proper close of app
* [device_info_plus](https://pub.dev/packages/device_info_plus) (BSD-3-Clause) - get device information
* [app_links](https://pub.dev/packages/app_links) (Apache-2.0) - handle deep linking/universal links

## Rust

* [anyhow](https://crates.io/crates/anyhow)(MIT) - Error handling
* [magic-wormhole](https://crates.io/crates/magic-wormhole)(EUPL-1.2) - magic-wormhole client
* [futures](https://crates.io/crates/futures)(MIT) - async/await async programming
* [async-std](https://crates.io/crates/async-std)(MIT) - async std-lib
* [url](https://crates.io/crates/url)(MIT) - url generation lib
* [zip](https://crates.io/crates/zip)(MIT) - ZIP file compression/decompression
* [fastrand](https://crates.io/crates/fastrand)(MIT) - fast random number generation


## License

    Copyright (C) 2025 Lukas Heiligenbrunner

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
