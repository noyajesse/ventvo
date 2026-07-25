import 'package:flutter/material.dart';
import 'voice_created_screen.dart';

class VoiceMarkScreen extends StatelessWidget {
  const VoiceMarkScreen({super.key});

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

              const Text(
                "Choose your mark.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Every Voice carries a symbol.\n"
                "Choose the mark that represents yours.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 17,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 50),

              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [

                  _mark("◇"),
                  _mark("◈"),
                  _mark("△"),
                  _mark("○"),
                  _mark("∿"),
                  _mark("✦"),

                ],
              ),

              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const VoiceCreatedScreen(),
                      ),
                    );

                  },
                  child: const Text(
                    "Continue",
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }


  Widget _mark(String symbol) {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white24,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          symbol,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
          ),
        ),
      ),
    );
  }
}