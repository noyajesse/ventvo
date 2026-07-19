import 'package:flutter/material.dart';
import 'features/auth/welcome_screen.dart';

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
      home: const WelcomeScreen(),
    );
  }
}