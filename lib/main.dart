import 'package:flutter/material.dart';
import 'features/onboarding/welcome_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const VentvoApp());
}

class VentvoApp extends StatelessWidget {
  const VentvoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ventvo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const WelcomeScreen(),
    );
  }
}