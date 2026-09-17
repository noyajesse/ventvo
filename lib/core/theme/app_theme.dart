import 'package:flutter/material.dart';

class AppTheme {
  static const background = Color(0xFF0B0B10);
  static const surface = Color(0xFF15151F);
  static const purple = Color(0xFF9B7BFF);
  static const cyan = Color(0xFF5CD6E8);
  static const muted = Color(0xFFAAA8B8);

  static ThemeData get darkTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: purple,
      brightness: Brightness.dark,
      surface: surface,
    );
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: scheme.copyWith(primary: purple, secondary: cyan),
      useMaterial3: true,
      fontFamily: 'sans',
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: purple, width: 1.5),
        ),
      ),
      cardTheme: const CardThemeData(
        color: surface,
        margin: EdgeInsets.zero,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: purple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
