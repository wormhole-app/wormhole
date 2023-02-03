
import 'flutter_close_app_platform_interface.dart';

class FlutterCloseApp {
  Future<void> closeAndRemoveApp() {
    return FlutterCloseAppPlatform.instance.closeAndRemoveApp();
  }
}
