import 'package:flutter/cupertino.dart';

import 'dark_theme_preference.dart';

class DarkThemeProvider with ChangeNotifier {
  final DarkThemePreference darkThemePreference = DarkThemePreference();
  bool _darkTheme = false;

  bool get darkTheme => _darkTheme;

  set darkTheme(bool value) {
    _darkTheme = value;
    darkThemePreference.setDarkTheme(_darkTheme);
    notifyListeners();
  }

  void invertTheme() {
    _darkTheme = !_darkTheme;
    darkThemePreference.setDarkTheme(_darkTheme);
    notifyListeners();
  }
}