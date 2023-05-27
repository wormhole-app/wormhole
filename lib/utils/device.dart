import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

enum DeviceType { phone, tablet }

DeviceType getDeviceType(BuildContext ctx) {
  final double shortSideLength = MediaQuery.of(ctx).size.shortestSide;
  return shortSideLength < 550 ? DeviceType.phone : DeviceType.tablet;
}

/// set default device orientation dependent if phone/tablet
Future<void> setPrefferedAppOrientation({required BuildContext ctx}) async {
  final deviceType = getDeviceType(ctx);
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
