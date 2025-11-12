import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';

import '../settings/settings.dart';

enum ThemeType { dark, light, system }

class ThemeProvider with ChangeNotifier {
  ThemeType _theme = ThemeType.dark;
  late WidgetsBinding _binding;

  ThemeProvider() {
    _binding = WidgetsBinding.instance;
    _binding.platformDispatcher.onPlatformBrightnessChanged =
        _onPlatformBrightnessChanged;
  }

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

  void _onPlatformBrightnessChanged() {
    // Only notify listeners if theme mode is set to system
    // so that system theme changes trigger a rebuild
    if (_theme == ThemeType.system) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _binding.platformDispatcher.onPlatformBrightnessChanged = null;
    super.dispose();
  }
}
