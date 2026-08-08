
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/voice_provider.dart';
import '../providers/vent_provider.dart';
import '../../feed/screens/feed_screen.dart';
import '../../crash_out/screens/crash_out_screen.dart';
import 'create_vent_screen.dart';

class VoiceSpaceScreen extends ConsumerWidget {
  const VoiceSpaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voice = ref.watch(ventvoVoiceProvider);
    final vents = ref.watch(ventProvider);

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

                // Voice identity
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
                      voice.mark ?? "◇",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 60,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  voice.name ?? "Unnamed Voice",
                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  voice.expression ??
                      "Your Voice is waiting.",
                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 50),

                // Voice statistics
                Text(
                  "0 Moments\n"
                  "${vents.length} Vents\n"
                  "0 Arcs",

                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 45),

                // Your Vents
                if (vents.isNotEmpty)
                  Column(
                    children: [
                      const Text(
                        "Your Vents",

                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      ...vents.map(
                        (vent) {
                          return Container(
                            margin:
                                const EdgeInsets.only(
                              bottom: 15,
                            ),

                            padding:
                                const EdgeInsets.all(18),

                            width: double.infinity,

                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius:
                                  BorderRadius.circular(
                                20,
                              ),
                            ),

                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [
                                Text(
                                  vent.content,

                                  style:
                                      const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),

                                const SizedBox(
                                  height: 12,
                                ),

                                Text(
                                  "Space: ${vent.responseIntent}",

                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.white54,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                const SizedBox(height: 50),

                // Create a Vent
                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const CreateVentScreen(),
                        ),
                      );
                    },

                    child: const Text(
                      "Create a Vent",
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Crash Out
                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const CrashOutScreen(),
                        ),
                      );
                    },

                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor:
                          Colors.white,

                      side: const BorderSide(
                        color: Colors.white24,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                      ),
                    ),

                    child: const Text(
                      "Crash Out",
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // Explore Feed
                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const FeedScreen(),
                        ),
                      );
                    },

                    child: const Text(
                      "Explore Feed",
                    ),
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

