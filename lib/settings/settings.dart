import 'package:shared_preferences/shared_preferences.dart';

class Defaults {
  static int get wordlength => 2;
}

class Settings {
  static const _wordLength = 'WORDLENGTH';

  static setWordLength(int? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_wordLength);
    } else {
      await prefs.setInt(_wordLength, value);
    }
  }

  static Future<int?> getWordLength() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_wordLength);
  }
}
