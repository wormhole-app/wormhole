import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_close_app_method_channel.dart';

abstract class FlutterCloseAppPlatform extends PlatformInterface {
  /// Constructs a FlutterCloseAppPlatform.
  FlutterCloseAppPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterCloseAppPlatform _instance = MethodChannelFlutterCloseApp();

  /// The default instance of [FlutterCloseAppPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterCloseApp].
  static FlutterCloseAppPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterCloseAppPlatform] when
  /// they register themselves.
  static set instance(FlutterCloseAppPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> closeAndRemoveApp() {
    throw UnimplementedError('closeAndRemoveApp() has not been implemented.');
  }
}
