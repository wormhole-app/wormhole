import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

enum DeviceType { phone, tablet }

DeviceType getDeviceType() {
  final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
  return data.size.shortestSide < 550 ? DeviceType.phone : DeviceType.tablet;
}

/// set default device orientation dependent if phone/tablet
Future<void> setPrefferedAppOrientation() async {
  final deviceType = getDeviceType();
  debugPrint('Device is a: ${deviceType.name}');

  switch (deviceType) {
    case DeviceType.phone:
      return await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp]);
    case DeviceType.tablet:
      return await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft
      ]);
  }
}
