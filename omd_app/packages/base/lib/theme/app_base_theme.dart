import 'package:flutter/material.dart';

abstract class AppBaseTheme {
  ThemeData allThemeData();
  ColorScheme? colorScheme({bool isDarkMode = false});
  NavigationBarThemeData? navigationBarTheme({bool isDarkMode = false});
}
