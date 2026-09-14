import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/crash_out.dart';
import '../providers/crash_out_provider.dart';
import '../../ventvo_voice/screens/create_vent_screen.dart';
import '../../ventvo_voice/screens/voice_space_screen.dart';

class CrashOutFateScreen extends ConsumerWidget {
  final CrashOut crashOut;

  const CrashOutFateScreen({
    super.key,
    required this.crashOut,
  });

  void _returnToVoiceSpace(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const VoiceSpaceScreen()),
      (route) => false,
    );
  }

  Future<void> _keepPrivate(BuildContext context, WidgetRef ref) async {
    await ref.read(crashOutProvider.notifier).keepPrivate(crashOut.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kept private.')),
    );
    _returnToVoiceSpace(context);
  }

  Future<void> _letGo(BuildContext context, WidgetRef ref) async {
    await ref.read(crashOutProvider.notifier).deleteCrashOut(crashOut.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You let this moment go.')),
    );
    _returnToVoiceSpace(context);
  }

  void _turnIntoVent(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateVentScreen(
          initialContent: crashOut.textContent,
          crashOutId: crashOut.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canTurnIntoVent =
        crashOut.type == CrashOutType.text &&
        (crashOut.textContent?.trim().length ?? 0) >= 3;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        title: const Text(
          'Crash Out',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.cloud_done_outlined, color: Colors.white70, size: 54),
              const SizedBox(height: 30),
              const Text(
                'You let it out.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              const Text(
                'You don’t have to decide what it means right now.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 17, height: 1.5),
              ),
              const Spacer(),
              if (canTurnIntoVent) ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _turnIntoVent(context),
                    child: const Text('Turn into a Vent', style: TextStyle(fontSize: 17)),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => _keepPrivate(context, ref),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                  ),
                  child: const Text('Keep Private', style: TextStyle(fontSize: 17)),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: TextButton(
                  onPressed: () => _letGo(context, ref),
                  style: TextButton.styleFrom(foregroundColor: Colors.white54),
                  child: const Text('Let it go', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}