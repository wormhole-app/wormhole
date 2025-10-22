import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.grey[200]!,
    primary: Colors.grey[400]!,
    secondary: Colors.grey[300]!,
    onPrimary: Colors.grey[900]!,
    onSecondary: Colors.grey[800]!,
  ),
  appBarTheme: AppBarTheme(backgroundColor: Colors.grey[200]),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.grey[900],
    ),
  ),
);
