import 'package:flutter/cupertino.dart';

import '../settings/settings.dart';

class DarkThemeProvider with ChangeNotifier {
  bool _darkTheme = false;

  bool get darkTheme => _darkTheme;

  set darkTheme(bool value) {
    _darkTheme = value;
    Settings.setDarkTheme(_darkTheme);
    notifyListeners();
  }

  void invertTheme() {
    _darkTheme = !_darkTheme;
    Settings.setDarkTheme(_darkTheme);
    notifyListeners();
  }
}
