apk: get-dep
	flutter build apk --target-platform android-arm64
	flutter build appbundle

linux: get-dep
	flutter build linux

codegen:
	flutter_rust_bridge_codegen \
	--rust-input native/src/api.rs \
	--dart-output lib/gen/bridge_generated.dart \
	--c-output ios/Runner/bridge_generated.h \
	--dart-decl-output lib/gen/bridge_definitions.dart \
	--wasm

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
