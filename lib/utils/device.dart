import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

enum DeviceType { phone, tablet }

DeviceType getDeviceType(BuildContext? ctx) {
  double shortSideLength;
  // use buildcontext if available
  if (ctx == null) {
    final data = MediaQueryData.fromWindow(
        WidgetsFlutterBinding.ensureInitialized().window);
    shortSideLength = data.size.shortestSide;
  } else {
    shortSideLength = MediaQuery.of(ctx).size.shortestSide;
  }

  return shortSideLength < 550 ? DeviceType.phone : DeviceType.tablet;
}

/// set default device orientation dependent if phone/tablet
Future<void> setPrefferedAppOrientation({BuildContext? ctx}) async {
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
