import 'package:flutter/material.dart';
import 'voice_mark_screen.dart';

class VoiceDiscoveryScreen extends StatefulWidget {
  const VoiceDiscoveryScreen({super.key});

  @override
  State<VoiceDiscoveryScreen> createState() =>
      _VoiceDiscoveryScreenState();
}

class _VoiceDiscoveryScreenState extends State<VoiceDiscoveryScreen> {

  bool discovered = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        discovered = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Container(
                  height: 130,
                  width: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white24,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      discovered ? "◇" : "◌",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 55,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                Text(
                  discovered
                      ? "Your Voice has emerged."
                      : "Finding your Voice...",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                if (discovered)
                  const Text(
                    "◇ Kaelor",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                else
                  const Text(
                    "Listening for a Voice that belongs here.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),

                const SizedBox(height: 50),

                if (discovered)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const VoiceMarkScreen(),
                          ),
                        );

                      },
                      child: const Text(
                        "Make it mine",
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