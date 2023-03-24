# Wormhole

[![Latest Release](https://gitlab.com/lukas-heiligenbrunner/wormhole/-/badges/release.svg)](https://gitlab.com/lukas-heiligenbrunner/wormhole/-/releases)
[![pipeline status](https://gitlab.com/lukas-heiligenbrunner/wormhole/badges/main/pipeline.svg)](https://gitlab.com/lukas-heiligenbrunner/wormhole/-/commits/main)

An open source Android App for sending/receiveing files using the magic-wormhole protocol.

[<img src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png" alt="Get it on Google Play Store" height="75">](https://play.google.com/store/apps/details?id=eu.heili.wormhole)

## Preview

<p><img src="android/fastlane/metadata/android/en-US/images/phoneScreenshots/Screenshot_2023-01-15-14-32-55-338_eu.heili.wormhole.jpg" width="32%"  alt=""/> 
<img src="android/fastlane/metadata/android/en-US/images/phoneScreenshots/Screenshot_2023-01-15-14-32-21-204_eu.heili.wormhole.jpg" width="32%"  alt=""/> 
<img src="android/fastlane/metadata/android/en-US/images/phoneScreenshots/Screenshot_2023-01-15-14-32-23-995_eu.heili.wormhole.jpg" width="32%"  alt=""/></p>

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

Install Android ndk version 22.1.7171670:\
`sdkmanager "ndk;22.1.7171670"`

Add rust Android targets:\
`rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android`

Install cargo-ndk:\
`cargo install cargo-ndk --version 2.6.0`

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

## License

    Copyright (C) 2023 Lukas Heiligenbrunner

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
