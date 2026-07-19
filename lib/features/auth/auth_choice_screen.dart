import 'package:flutter/material.dart';
import 'signup_screen.dart';

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
                'VENTRO',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                'Welcome to Ventro',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'Your real identity stays private.\n'
                'Your voice is what people know.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text(
                    'Continue with Google',
                  ),
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text(
                    'Continue with Apple',
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'OR',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const SignupScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Continue with Email',
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {},
                child: const Text(
                  'Already a member? Sign in',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}