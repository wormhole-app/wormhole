import 'package:shared_preferences/shared_preferences.dart';

enum CodeType { qrCode, aztecCode }

class Defaults {
  static int get wordlength => 2;

  static CodeType get codetype => CodeType.qrCode;

  static bool get codeAlwaysVisible => false;
}

class Settings {
  static const _wordLength = 'WORDLENGTH';
  static const _codeType = 'CODETYPE';
  static const _codeAlwaysVisible = 'CODEALVISIBLE';
  static const themeStatus = 'THEMESTATUS';

  static setWordLength(int? value) async {
    await _setField(value, _wordLength);
  }

  static setCodeType(CodeType type) async {
    await _setField(type == CodeType.qrCode, _codeType);
  }

  static setCodeAlwaysVisible(bool value) async {
    await _setField(value, _codeAlwaysVisible);
  }

  static setDarkTheme(bool value) async {
    await _setField(value, themeStatus);
  }

  static Future<int?> getWordLength() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_wordLength);
  }

  static Future<CodeType> getCodeType() async {
    final prefs = await SharedPreferences.getInstance();

    final type = prefs.getBool(_codeType);
    if (type == null) {
      return Defaults.codetype;
    } else {
      return type ? CodeType.qrCode : CodeType.aztecCode;
    }
  }

  static Future<bool> getCodeAlwaysVisible() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_codeAlwaysVisible) ?? Defaults.codeAlwaysVisible;
  }

  /// get current theme : true if darkmode
  static Future<bool> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(themeStatus) ?? true;
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
