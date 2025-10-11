import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Colors.black,
    primary: Colors.grey[900]!,
    secondary: Colors.grey[800]!,
    onPrimary: Colors.grey[300]!,
    onSecondary: Colors.grey[200]!,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[900],
  ),
);
