import 'package:flutter/material.dart';

import 'ventvo_colors.dart';
import 'ventvo_typography.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    scaffoldBackgroundColor: VentvoColors.background,

    colorScheme: const ColorScheme.dark(
      primary: VentvoColors.primary,
      secondary: VentvoColors.secondary,
    ),

    textTheme: const TextTheme(
      displayLarge: VentvoTypography.wordmark,
      headlineMedium: VentvoTypography.hero,
      bodyMedium: VentvoTypography.body,
      labelLarge: VentvoTypography.button,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: VentvoTypography.button,
      ),
    ),
  );
}