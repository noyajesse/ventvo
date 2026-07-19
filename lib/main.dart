import 'package:flutter/material.dart';
import 'features/auth/welcome_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const VentroApp());
}

class VentroApp extends StatelessWidget {
  const VentroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ventro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const WelcomeScreen(),
    );
  }
}