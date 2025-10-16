apk: translation
	flutter build apk --split-per-abi --release
	flutter build appbundle

linux: translation
	flutter build linux

windows: translation
	flutter build windows

msix: translation
	flutter build windows --release
	flutter pub run msix:create

codegen:
    ~/.cargo/bin/flutter_rust_bridge_codegen generate --no-web

deploy:
	fastlane deploy

elevate:
	fastlane elevate

translation: get-dep
	flutter gen-l10n

format:
	cd rust && cargo fmt
	dart format .

lint:
	cd rust && cargo clippy
	flutter analyze .

clean:
	flutter clean
	cd native && cargo clean

get-dep:
	flutter packages get