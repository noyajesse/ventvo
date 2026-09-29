import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/crash_out.dart';
import '../providers/crash_out_provider.dart';
import '../providers/experience_thread_provider.dart';
import 'experience_thread_screen.dart';

class PrivateCrashOutsScreen extends ConsumerWidget {
  const PrivateCrashOutsScreen({super.key});

  Future<void> _letGo(
    BuildContext context,
    WidgetRef ref,
    CrashOut crashOut,
  ) async {
    await ref.read(crashOutProvider.notifier).deleteCrashOut(crashOut.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Let go.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crashOutState = ref.watch(crashOutProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        title: const Text(
          'Private',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: crashOutState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(
            child: Text(
              'Couldn’t load your private Crash Outs.',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          data: (crashOuts) {
            final privateCrashOuts = crashOuts
                .where((crashOut) => crashOut.status == CrashOutStatus.keptPrivate)
                .toList();

            if (privateCrashOuts.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Text(
                    'Nothing is kept here yet.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 17),
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: privateCrashOuts.length,
              itemBuilder: (context, index) {
                final crashOut = privateCrashOuts[index];
                final thread = ref
                    .read(experienceThreadProvider.notifier)
                    .threadForCrashOut(crashOut.id);
                return _PrivateCrashOutCard(
                  crashOut: crashOut,
                  onOpenEncounter: thread == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExperienceThreadScreen(
                                crashOut: crashOut,
                                thread: thread,
                              ),
                            ),
                          );
                        },
                  onLetGo: () => _letGo(context, ref, crashOut),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _PrivateCrashOutCard extends StatelessWidget {
  final CrashOut crashOut;
  final VoidCallback onTurnIntoVent;
  final VoidCallback onLetGo;

  const _PrivateCrashOutCard({
    required this.crashOut,
    required this.onTurnIntoVent,
    required this.onLetGo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lock_outline, color: Colors.white54, size: 18),
              SizedBox(width: 8),
              Text(
                'Private Crash Out',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            crashOut.textContent ?? 'Voice Crash Out',
            style: const TextStyle(color: Colors.white, fontSize: 17, height: 1.5),
          ),
          const SizedBox(height: 20),
          if (onOpenEncounter == null)
            const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: Text(
                'No other side has surfaced yet.',
                style: TextStyle(color: Colors.white38, fontSize: 12.5),
              ),
            ),
          Row(
            children: [
              if (onOpenEncounter != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onOpenEncounter,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Open encounter'),
                  ),
                ),
              if (onOpenEncounter != null) const SizedBox(width: 10),
              IconButton(
                onPressed: onLetGo,
                tooltip: 'Let go',
                icon: const Icon(Icons.delete_outline, color: Colors.white54),
              ),
            ],
          ),
        ],
      ),
    );
  }
}