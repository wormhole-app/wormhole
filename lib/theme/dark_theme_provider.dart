import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';

import '../settings/settings.dart';

enum ThemeType { dark, light, system }

class DarkThemeProvider with ChangeNotifier {
  ThemeType _theme = ThemeType.dark;

  ThemeType get theme => _theme;

  set theme(ThemeType theme) {
    _theme = theme;
    Settings.setTheme(theme);
    notifyListeners();
  }

  bool isDarkThemeActive() {
    switch (_theme) {
      case ThemeType.system:
        return SchedulerBinding
                .instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
      case ThemeType.dark:
        return true;
      case ThemeType.light:
        return false;
    }
  }
}
