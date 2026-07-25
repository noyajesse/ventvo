import 'package:flutter/material.dart';
import '../../home/home_screen.dart';
class VoiceCreatedScreen extends StatelessWidget {
  const VoiceCreatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white24,
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Text(
                    "◇",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 65,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              const Text(
                "Your Ventvo Voice is born.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "◇ Kaelor",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Your identity stays yours.\n"
                "Your Voice is what people know.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 17,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 60),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const HomeScreen(),
                      ),
                    );

                  },
                  child: const Text(
                    "Enter Ventvo",
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