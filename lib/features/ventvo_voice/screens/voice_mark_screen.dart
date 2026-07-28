import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'voice_name_screen.dart';
import '../providers/voice_provider.dart';

class VoiceMarkScreen extends ConsumerStatefulWidget {
  const VoiceMarkScreen({super.key});

  @override
  ConsumerState<VoiceMarkScreen> createState() =>
      _VoiceMarkScreenState();
}

class _VoiceMarkScreenState
    extends ConsumerState<VoiceMarkScreen> {

  String? selectedMark;

  final List<String> marks = [
    "◇",
    "◈",
    "△",
    "○",
    "∿",
    "✦",
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
                children: marks.map((mark) {
                  return _mark(mark);
                }).toList(),
              ),

              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: selectedMark == null
                      ? null
                      : () {

                          ref
                              .read(
                                ventvoVoiceProvider.notifier,
                              )
                              .updateMark(selectedMark!);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const VoiceNameScreen(),
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

    final selected = selectedMark == symbol;

    return GestureDetector(
      onTap: () {

        setState(() {
          selectedMark = symbol;
        });

      },
      child: Container(
        height: 70,
        width: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected
              ? Colors.white24
              : Colors.transparent,
          border: Border.all(
            color: selected
                ? Colors.white
                : Colors.white24,
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
      ),
    );
  }
}