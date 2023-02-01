import 'package:shared_preferences/shared_preferences.dart';

enum CodeType { QrCode, AztecCode }

class Defaults {
  static int get wordlength => 2;

  static CodeType get codetype => CodeType.QrCode;
}

class Settings {
  static const _wordLength = 'WORDLENGTH';
  static const _code_type = 'CODETYPE';
  static const _code_always_visible = 'CODEALVISIBLE';

  static setWordLength(int? value) async {
    await _setField(value, _wordLength);
  }

  static setCodeType(CodeType type) async {
    await _setField(type == CodeType.QrCode, _code_type);
  }

  static setCodeAlwaysVisible(bool value) async {
    await _setField(value, _code_always_visible);
  }

  static Future<int?> getWordLength() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_wordLength);
  }

  static Future<CodeType> getCodeType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_code_type) ?? true
        ? CodeType.QrCode
        : CodeType.AztecCode;
  }

  static Future<bool> getCodeAlwaysVisible() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_code_always_visible) ?? false;
  }

  static _setField<T>(T? value, String field) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(field);
    } else {
      if (value is int) {
        await prefs.setInt(field, value);
      } else if (value is bool) {
        await prefs.setBool(field, value);
      } else if (value is String) {
        await prefs.setString(field, value);
      }
    }
  }
}
