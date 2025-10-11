apk: translation
	flutter build apk --split-per-abi --release
	flutter build appbundle

container-apk:
	podman run --name=example \
		--mount type=bind,source=${PWD},target=/root/wormhole/ \
		docker.io/luki42/flutter-rust \
		bash -c "cd /root/wormhole && make apk"

linux: translation
	flutter build linux

windows: translation
	flutter build windows

msix: translation
	flutter build windows --release
	flutter pub run msix:create

codegen:
	/home/lukas/.cargo/bin/flutter_rust_bridge_codegen \
	--rust-input native/src/api.rs \
	--dart-output lib/gen/bridge_generated.dart \
	--c-output ios/Runner/bridge_generated.h \
	--dart-decl-output lib/gen/bridge_definitions.dart \
	--wasm

deploy:
	fastlane deploy

elevate:
	fastlane elevate

translation: get-dep
	flutter gen-l10n

format:
	cd native && cargo fmt
	dart format .

lint:
	cd native && cargo clippy
	flutter analyze .

clean:
	flutter clean
	cd native && cargo clean

.PHONY: all apk linux windows msix get-dep codegen lint clean

# Proto generation (calls terminal proto commands)
get-dep:
	flutter packages get
