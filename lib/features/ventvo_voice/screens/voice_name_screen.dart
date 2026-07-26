import 'package:flutter/material.dart';
import 'voice_birth_screen.dart';

class VoiceNameScreen extends StatefulWidget {
  const VoiceNameScreen({super.key});

  @override
  State<VoiceNameScreen> createState() =>
      _VoiceNameScreenState();
}

class _VoiceNameScreenState extends State<VoiceNameScreen> {
  String? selectedName;

  final List<Map<String, String>> names = [
    {
      "name": "VAELOR",
      "meaning": "A Voice shaped by reflection.",
    },
    {
      "name": "NYVEN",
      "meaning": "A Voice shaped by discovery.",
    },
    {
      "name": "AUREN",
      "meaning": "A Voice shaped by connection.",
    },
  ];

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
                "Your Voice has found its name.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Choose the name that feels connected to your Voice.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 17,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              ...names.map((item) {
                final selected =
                    selectedName == item["name"];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedName = item["name"];
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(
                      bottom: 18,
                    ),
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white24
                          : Colors.transparent,
                      borderRadius:
                          BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? Colors.white
                            : Colors.white24,
                      ),
                    ),
                    child: Column(
                      children: [

                        Text(
                          item["name"]!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          item["meaning"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),

                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: selectedName == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const VoiceBirthScreen(),
                            ),
                          );
                        },
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 17,
                    ),
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