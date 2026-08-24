import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'voice_space_screen.dart';
import '../providers/voice_provider.dart';

class VoiceCreatedScreen extends ConsumerWidget {
  const VoiceCreatedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voice = ref.watch(ventvoVoiceProvider).asData?.value;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      voice?.mark ?? '◇',
                      style: const TextStyle(color: Colors.white, fontSize: 65),
                    ),
                  ),
                ),
                const SizedBox(height: 45),
                const Text(
                  'Your Ventvo Voice is born.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 25),
                Text(
                  '${voice?.mark ?? '◇'} ${voice?.name ?? 'Unnamed Voice'}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 35),
                if (voice?.expression != null)
                  Text(
                    'Presence\n${voice!.expression}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 17, height: 1.5),
                  ),
                const SizedBox(height: 20),
                if (voice?.resonance != null)
                  Text(
                    'Resonance\n${voice!.resonance}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 17, height: 1.5),
                  ),
                const SizedBox(height: 35),
                const Text(
                  'Your identity stays yours.\nYour Voice is what people know.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 45),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const VoiceSpaceScreen()),
                      );
                    },
                    child: const Text('Enter Ventvo', style: TextStyle(fontSize: 17)),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
