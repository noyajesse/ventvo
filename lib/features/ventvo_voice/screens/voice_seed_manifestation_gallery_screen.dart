import 'package:flutter/material.dart';

import '../services/voice_identity_catalog.dart';
import '../widgets/voice_seed_manifestation.dart';

/// Internal visual review surface for all Ventvo Voice Seed manifestations.
///
/// This is intentionally isolated from the first-time discovery flow so the
/// canonical VAELOR experience is never replaced while the other Seed
/// manifestations are being refined.
class VoiceSeedManifestationGalleryScreen extends StatelessWidget {
  const VoiceSeedManifestationGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final seeds = VoiceIdentityCatalog.seeds;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        foregroundColor: Colors.white,
        title: const Text('Voice Seed Manifestations'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        itemCount: seeds.length,
        separatorBuilder: (_, _) => const SizedBox(height: 24),
        itemBuilder: (context, index) {
          final seed = seeds[index];
          final manifestation =
              VoiceIdentityCatalog.manifestationBySeedId(seed.id);

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                VoiceSeedManifestation(
                  key: ValueKey(seed.id),
                  seed: seed,
                  size: 170,
                ),
                const SizedBox(height: 18),
                Text(
                  '${seed.word} ${seed.mark.symbol}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  seed.essence,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.70),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${manifestation.motion.name} · ${manifestation.reveal.name}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 11,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
