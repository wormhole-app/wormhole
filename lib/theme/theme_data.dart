import 'package:flutter/material.dart';

class Styles {
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    return ThemeData(
        iconTheme:
            IconThemeData(color: isDarkTheme ? Colors.white70 : Colors.black),
        colorScheme: isDarkTheme
            ? const ColorScheme.dark(
                background: Colors.black,
                primary: Colors.blue,
                onPrimary: Colors.white)
            : const ColorScheme.light(
                background: Color(0xffF1F5FB), primary: Colors.blue),
        indicatorColor:
            isDarkTheme ? const Color(0xff0E1D36) : const Color(0xffCBDCF8),
        hintColor:
            isDarkTheme ? const Color(0xff280C0B) : const Color(0xffc0c0c0),
        highlightColor:
            isDarkTheme ? const Color(0xff372901) : const Color(0xffFCE192),
        hoverColor:
            isDarkTheme ? const Color(0xff3A3A3B) : const Color(0xff4285F4),
        focusColor:
            isDarkTheme ? const Color(0xff0b0e25) : const Color(0xffa8b8da),
        disabledColor: Colors.grey,
        cardColor:
            isDarkTheme ? const Color(0xFF151515) : const Color(0xffc0c0c0),
        canvasColor: isDarkTheme ? Colors.black : Colors.grey[50],
        brightness: isDarkTheme ? Brightness.dark : Brightness.light,
        buttonTheme: Theme.of(context).buttonTheme.copyWith(
            colorScheme: isDarkTheme
                ? const ColorScheme.dark()
                : const ColorScheme.light()),
        appBarTheme: const AppBarTheme(
          elevation: 0.0,
        ),
        textSelectionTheme: TextSelectionThemeData(
          selectionColor:
              isDarkTheme ? const Color(0xff3A3A3B) : const Color(0xffc0c0c0),
        ),
        textTheme: const TextTheme(
            headlineLarge: TextStyle(fontWeight: FontWeight.bold)));
  }
}
