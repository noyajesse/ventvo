import 'package:flutter/material.dart';
import 'voice_created_screen.dart';

class VoiceBirthScreen extends StatefulWidget {
  const VoiceBirthScreen({super.key});

  @override
  State<VoiceBirthScreen> createState() =>
      _VoiceBirthScreenState();
}

class _VoiceBirthScreenState extends State<VoiceBirthScreen> {

  bool revealed = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(seconds: 2),
      () {
        setState(() {
          revealed = true;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
            ),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [

                AnimatedOpacity(
                  opacity: revealed ? 1 : 0.3,
                  duration:
                      const Duration(seconds: 2),
                  child: const Text(
                    "◇",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 80,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  revealed
                      ? "Your Voice has emerged."
                      : "Your Voice is forming...",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 50),

                if (revealed)
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
      ),
    );
  }
}