import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/voice_provider.dart';
import 'voice_mark_screen.dart';

class VoiceResonanceScreen extends ConsumerStatefulWidget {
  const VoiceResonanceScreen({super.key});

  @override
  ConsumerState<VoiceResonanceScreen> createState() => _VoiceResonanceScreenState();
}

class _VoiceResonanceScreenState extends ConsumerState<VoiceResonanceScreen> {
  String? selectedResonance;

  final List<String> resonances = [
    'Stillness',
    'Spark',
    'Flow',
    'Horizon',
    'Depth',
  ];

  Future<void> _continue() async {
    final resonance = selectedResonance;
    if (resonance == null) return;

    await ref.read(ventvoVoiceProvider.notifier).updateResonance(resonance);
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VoiceMarkScreen(),
      ),
    );
  }

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
                'Choose your resonance.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'What feeling should your Voice leave behind?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 17,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              Wrap(
                spacing: 15,
                runSpacing: 15,
                alignment: WrapAlignment.center,
                children: resonances.map((item) {
                  final selected = selectedResonance == item;

                  return GestureDetector(
                    onTap: () => setState(() => selectedResonance = item),
                    child: Container(
                      width: 120,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: selected ? Colors.white24 : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? Colors.white : Colors.white24,
                        ),
                      ),
                      child: Text(
                        item,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: selectedResonance == null ? null : _continue,
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
