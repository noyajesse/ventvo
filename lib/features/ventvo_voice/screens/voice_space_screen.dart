import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/voice_provider.dart';
import '../providers/vent_provider.dart';

import '../../feed/screens/feed_screen.dart';
import '../../feed/widgets/vent_card.dart';
import '../../crash_out/screens/crash_out_screen.dart';
import '../../crash_out/screens/private_crash_outs_screen.dart';
import '../../crash_out/models/crash_out.dart';
import '../../crash_out/providers/crash_out_provider.dart';

import 'create_vent_screen.dart';

class VoiceSpaceScreen extends ConsumerWidget {
  const VoiceSpaceScreen({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final voice = ref.watch(ventvoVoiceProvider);
    final vents = ref.watch(ventProvider);
    final crashOuts = ref.watch(crashOutProvider);

    final privateCrashOuts = crashOuts
        .where(
          (crashOut) =>
              crashOut.status == CrashOutStatus.keptPrivate,
        )
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 40,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ─────────────────────────────
                // VOICE IDENTITY
                // ─────────────────────────────
                Container(
                  height: 140,
                  width: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white24,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      voice.mark ?? '◇',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 60,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  voice.name ?? 'Unnamed Voice',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  voice.expression ?? 'Your Voice is waiting.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 50),

                // ─────────────────────────────
                // VOICE STATISTICS
                // ─────────────────────────────
                Text(
                  '0 Moments\n'
                  '${vents.length} Vents\n'
                  '0 Arcs',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 45),

                // ─────────────────────────────
                // YOUR VENTS
                // ─────────────────────────────
                if (vents.isNotEmpty)
                  Column(
                    children: [
                      const Text(
                        'Your Vents',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...vents.map(
                        (vent) => VentCard(vent: vent),
                      ),
                    ],
                  ),

                // ─────────────────────────────
                // PRIVATE CRASH OUTS
                // ─────────────────────────────
                if (privateCrashOuts.isNotEmpty)
                  Column(
                    children: [
                      const SizedBox(height: 35),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white12,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.lock_outline,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Private',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${privateCrashOuts.length} ${privateCrashOuts.length == 1 ? 'Private Crash Out' : 'Private Crash Outs'}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'Things you chose to keep for yourself.',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const PrivateCrashOutsScreen(),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: Colors.white24,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 13,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'View Private Crash Outs',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 50),

                // ─────────────────────────────
                // CREATE A VENT
                // ─────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateVentScreen(),
                        ),
                      );
                    },
                    child: const Text('Create a Vent'),
                  ),
                ),

                const SizedBox(height: 15),

                // ─────────────────────────────
                // CRASH OUT
                // ─────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CrashOutScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(
                        color: Colors.white24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text('Crash Out'),
                  ),
                ),

                const SizedBox(height: 15),

                // ─────────────────────────────
                // EXPLORE FEED
                // ─────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FeedScreen(),
                        ),
                      );
                    },
                    child: const Text('Explore Feed'),
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
