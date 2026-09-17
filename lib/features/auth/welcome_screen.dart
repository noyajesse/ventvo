import 'package:flutter/material.dart';
import '../app_shell.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.waves_rounded, size: 48, color: Color(0xFF9B7BFF)),
                const SizedBox(height: 24),
                Text(
                  'Ventvo',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                ),
                const SizedBox(height: 20),
                Text(
                  'VENT your thoughts.\nFIND your people.\nFEEL understood.',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                ),
                const SizedBox(height: 20),
                Text(
                  'A quieter social space for honest expression and meaningful connection.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFFAAA8B8),
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const AppShell()),
                    ),
                    child: const Text('Enter Ventvo'),
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: Text(
                    'Your identity stays yours.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFAAA8B8),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
