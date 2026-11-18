import 'package:flutter/material.dart';

import 'ventvo_colors.dart';
import 'ventvo_typography.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: VentvoColors.background,
    colorScheme: const ColorScheme.dark(
      primary: VentvoColors.primary,
      secondary: VentvoColors.secondary,
      surface: VentvoColors.surface,
      onSurface: VentvoColors.textPrimary,
      outline: VentvoColors.border,
      error: VentvoColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: VentvoColors.background,
      foregroundColor: VentvoColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: VentvoColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: VentvoTypography.wordmark,
      headlineMedium: VentvoTypography.hero,
      bodyMedium: VentvoTypography.body,
      labelLarge: VentvoTypography.button,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: VentvoColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: VentvoColors.surfaceElevated,
        disabledForegroundColor: VentvoColors.textMuted,
        elevation: 0,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: VentvoTypography.button,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: VentvoColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: VentvoColors.surfaceElevated,
        disabledForegroundColor: VentvoColors.textMuted,
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: VentvoTypography.button,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: VentvoColors.textPrimary,
        side: const BorderSide(color: VentvoColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: VentvoTypography.button,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: VentvoColors.textSecondary,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: VentvoColors.surfaceElevated,
      contentTextStyle: const TextStyle(
        color: VentvoColors.textPrimary,
        fontSize: 13,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: VentvoColors.border),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: VentvoColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
  );
}