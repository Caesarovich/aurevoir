import 'dart:ui';

import 'package:flutter/material.dart';

const Color _lightPrimary = Color(0xFF4BA3F2);
const Color _lightSecondary = Color(0xFF7CC8FF);
const Color _lightSurface = Color(0xFFF6FBFF);

/// Light theme for Aurevoir, based on Material 3 design principles.
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: _lightPrimary,
  ).copyWith(
    primary: _lightPrimary,
    secondary: _lightSecondary,
    surface: _lightSurface,
    surfaceTint: _lightPrimary,
  ),
  scaffoldBackgroundColor: _lightSurface,
  appBarTheme: const AppBarTheme(
    backgroundColor: _lightSurface,
    foregroundColor: Colors.black87,
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _lightPrimary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (states) =>
          states.contains(WidgetState.selected) ? _lightPrimary : Colors.grey,
    ),
    trackColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? _lightSecondary.withValues(alpha: 0.5)
          : Colors.grey.shade300,
    ),
  ),
);

/// Dark theme for Aurevoir, based on Material 3 design principles.
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: _lightPrimary,
    brightness: Brightness.dark,
  ).copyWith(
    primary: _lightSecondary,
    secondary: _lightPrimary,
  ),
  cardTheme: CardThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _lightSecondary,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
);
