apk: translation
	flutter build apk --target-platform android-arm64
	flutter build appbundle

linux: translation
	flutter build linux

codegen:
	flutter_rust_bridge_codegen \
	--rust-input native/src/api.rs \
	--dart-output lib/gen/bridge_generated.dart \
	--c-output ios/Runner/bridge_generated.h \
	--dart-decl-output lib/gen/bridge_definitions.dart \
	--wasm

deploy:
	cd android && fastlane deploy

elevate:
	cd android && fastlane elevate

translation: get-dep
	flutter gen-l10n

lint:
	cd native && cargo fmt
	dart format .

clean:
	flutter clean
	cd native && cargo clean

.PHONY: all apk linux get-dep codegen lint clean

# Proto generation (calls terminal proto commands)
get-dep:
	flutter packages get
