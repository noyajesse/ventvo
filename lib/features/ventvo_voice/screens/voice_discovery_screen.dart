import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/voice_seed.dart';
import '../providers/voice_provider.dart';
import '../services/voice_seed_discovery_service.dart';
import '../widgets/voice_seed_manifestation.dart';
import 'voice_resonance_screen.dart';

class VoiceDiscoveryScreen extends ConsumerStatefulWidget {
  const VoiceDiscoveryScreen({super.key});

  @override
  ConsumerState<VoiceDiscoveryScreen> createState() =>
      _VoiceDiscoveryScreenState();
}

class _VoiceDiscoveryScreenState extends ConsumerState<VoiceDiscoveryScreen> {
  bool discovered = false;
  bool starting = false;
  late final VoiceSeed discoveredSeed;

  final VoiceSeedDiscoveryService _discoveryService =
      VoiceSeedDiscoveryService();

  @override
  void initState() {
    super.initState();

    // The Seed is chosen once when the discovery experience begins. The same
    // Seed is then revealed and persisted; tapping the button cannot produce
    // a different identity.
    discoveredSeed = _discoveryService.discoverRandom();

    Future.delayed(
      const Duration(seconds: 3),
      () {
        if (!mounted) return;
        setState(() => discovered = true);
      },
    );
  }

  Future<void> _shapeVoice() async {
    if (starting) return;

    setState(() => starting = true);
    await ref.read(ventvoVoiceProvider.notifier).ensureVoice();

    await ref
        .read(ventvoVoiceProvider.notifier)
        .updateName(discoveredSeed.word);
    await ref
        .read(ventvoVoiceProvider.notifier)
        .updateMark(discoveredSeed.mark.symbol);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VoiceResonanceScreen(),
      ),
    );
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
                VoiceSeedManifestation(
                  seed: discoveredSeed,
                  size: 130,
                  reveal: discovered,
                ),
                const SizedBox(height: 50),
                Text(
                  discovered
                      ? '${discoveredSeed.word} has appeared.'
                      : 'Finding your Voice...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                if (discovered) ...[
                  Text(
                    discoveredSeed.meaning,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 17,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    discoveredSeed.feeling,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ] else
                  const Text(
                    'Listening for a Voice that belongs here.',
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
                      onPressed: starting ? null : _shapeVoice,
                      child: Text(
                        starting ? 'Preparing Your Voice...' : 'Shape My Voice',
                        style: const TextStyle(fontSize: 17),
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
