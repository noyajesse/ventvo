import 'package:flutter/material.dart';
import '../ventvo_voice/screens/ventvo_voice_welcome_screen.dart';

class AuthChoiceScreen extends StatelessWidget {
  const AuthChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Text(
                'Welcome to Ventvo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Your real identity stays private.\n'
                'Your voice is what people know.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                          const VentvoVoiceWelcomeScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Create an Account',
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}