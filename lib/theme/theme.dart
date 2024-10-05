import 'package:flutter/material.dart';

const _primaryColor = Colors.greenAccent;

final lightTheme = ThemeData.light().copyWith(
  scaffoldBackgroundColor: Colors.white,
  colorScheme: const ColorScheme.light(
    primary: _primaryColor,
    surface: Colors.white,
  ),
);

final darkTheme = ThemeData.dark().copyWith(
  colorScheme: const ColorScheme.dark(
    primary: _primaryColor,
  ),
);

extension ThemeExtension on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}
