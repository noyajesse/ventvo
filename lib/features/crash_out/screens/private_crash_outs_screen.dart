
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/crash_out.dart';
import '../providers/crash_out_provider.dart';

class PrivateCrashOutsScreen extends ConsumerWidget {
  const PrivateCrashOutsScreen({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final crashOuts = ref.watch(crashOutProvider);

    final privateCrashOuts = crashOuts
        .where(
          (crashOut) =>
              crashOut.status ==
              CrashOutStatus.keptPrivate,
        )
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF111111),

      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,

        title: const Text(
          "Private",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: privateCrashOuts.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Text(
                    "Nothing is kept here yet.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 17,
                    ),
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: privateCrashOuts.length,

                itemBuilder: (
                  context,
                  index,
                ) {
                  final crashOut =
                      privateCrashOuts[index];

                  return Container(
                    margin:
                        const EdgeInsets.only(
                      bottom: 16,
                    ),

                    padding:
                        const EdgeInsets.all(20),

                    decoration:
                        BoxDecoration(
                      color: Colors.white10,

                      borderRadius:
                          BorderRadius.circular(
                        22,
                      ),

                      border: Border.all(
                        color: Colors.white12,
                      ),
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.lock_outline,
                              color: Colors.white54,
                              size: 18,
                            ),

                            SizedBox(width: 8),

                            Text(
                              "Private Crash Out",
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Text(
                          crashOut.textContent ??
                              "Voice Crash Out",

                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 14),

                        Text(
                          "Kept private",
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

