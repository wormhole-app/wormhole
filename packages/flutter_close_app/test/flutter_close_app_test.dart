import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_close_app/flutter_close_app.dart';
import 'package:flutter_close_app/flutter_close_app_platform_interface.dart';
import 'package:flutter_close_app/flutter_close_app_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterCloseAppPlatform
    with MockPlatformInterfaceMixin
    implements FlutterCloseAppPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterCloseAppPlatform initialPlatform =
      FlutterCloseAppPlatform.instance;

  test('$MethodChannelFlutterCloseApp is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterCloseApp>());
  });

  test('getPlatformVersion', () async {
    FlutterCloseApp flutterCloseAppPlugin = FlutterCloseApp();
    MockFlutterCloseAppPlatform fakePlatform = MockFlutterCloseAppPlatform();
    FlutterCloseAppPlatform.instance = fakePlatform;

    expect(await flutterCloseAppPlugin.getPlatformVersion(), '42');
  });
}
