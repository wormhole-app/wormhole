import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_close_app_platform_interface.dart';

/// An implementation of [FlutterCloseAppPlatform] that uses method channels.
class MethodChannelFlutterCloseApp extends FlutterCloseAppPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_close_app');

  @override
  Future<void> closeAndRemoveApp() async {
    await methodChannel.invokeMethod<void>('closeAndRemoveApp');
  }
}
