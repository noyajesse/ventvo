import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/crash_out.dart';
import '../models/experience_representation.dart';
import '../providers/crash_out_provider.dart';
import '../providers/crash_out_space_experience_provider.dart';
import '../providers/crash_out_space_provider.dart';
import '../providers/experience_thread_provider.dart';
import '../services/crash_out_experience_interpreter.dart';
import 'crash_out_space_screen.dart';
import 'experience_thread_screen.dart';

class PrivateCrashOutsScreen extends ConsumerWidget {
  const PrivateCrashOutsScreen({super.key});

  Future<void> _letGo(
    BuildContext context,
    WidgetRef ref,
    CrashOut crashOut,
  ) async {
    await ref
        .read(experienceThreadProvider.notifier)
        .deleteThreadForCrashOut(crashOut.id);
    await ref.read(crashOutProvider.notifier).deleteCrashOut(crashOut.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Let go.')),
    );
  }

  Future<void> _openSpace(
    BuildContext context,
    WidgetRef ref,
    CrashOut crashOut,
    HumanTension tension,
  ) async {
    await ref.read(crashOutSpaceExperienceProvider.future);
    await ref.read(crashOutSpaceProvider.future);
    if (!context.mounted) return;

    final experiences = ref
        .read(crashOutSpaceExperienceProvider.notifier)
        .experiencesFor(tension.name);
    final matchedExperienceId = crashOut.matchedExperienceId;
    if (matchedExperienceId != null) {
      experiences.sort((a, b) {
        if (a.id == matchedExperienceId) return -1;
        if (b.id == matchedExperienceId) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CrashOutSpaceScreen(
          tension: tension,
          experiences: experiences,
          matchedExperienceId: matchedExperienceId,
        ),
      ),
    );
  }

  HumanTension? _spaceTensionFor(CrashOut crashOut) {
    final spaceId = crashOut.spaceId;
    if (spaceId != null) {
      for (final tension in HumanTension.values) {
        if (tension.name == spaceId) return tension;
      }
    }

    // Earlier local versions recorded Space entry without its destination.
    // Recover the same deterministic tension from the still-private original.
    if (crashOut.status == CrashOutStatus.spaceEntered) {
      final representation =
          const CrashOutExperienceInterpreter().interpret(crashOut);
      for (final atom in representation.atoms) {
        if (atom.confidence >= 0.55 && atom.intensity >= 0.35) {
          return atom.tension;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crashOutState = ref.watch(crashOutProvider);
    ref.watch(experienceThreadProvider);

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
                .where((crashOut) => crashOut.status.isPrivate)
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
                final tension = _spaceTensionFor(crashOut);
                final hasEnteredSpace =
                    crashOut.status == CrashOutStatus.spaceEntered &&
                    tension != null;
                return _PrivateCrashOutCard(
                  crashOut: crashOut,
                  hasEnteredSpace: hasEnteredSpace,
                  onOpen: hasEnteredSpace
                      ? () => _openSpace(context, ref, crashOut, tension!)
                      : thread == null
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
  final bool hasEnteredSpace;
  final VoidCallback? onOpen;
  final VoidCallback onLetGo;

  const _PrivateCrashOutCard({
    required this.crashOut,
    required this.hasEnteredSpace,
    required this.onOpen,
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
            crashOut.textContent ?? 'Crash Out',
            style: const TextStyle(color: Colors.white, fontSize: 17, height: 1.5),
          ),
          const SizedBox(height: 20),
          if (hasEnteredSpace)
            const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: Text(
                'Your original remains private. You can return to the wider experience Space.',
                style: TextStyle(color: Colors.white38, fontSize: 12.5),
              ),
            )
          else if (onOpen == null)
            const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: Text(
                'No other side has surfaced yet.',
                style: TextStyle(color: Colors.white38, fontSize: 12.5),
              ),
            ),
          Row(
            children: [
              if (onOpen != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onOpen,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(hasEnteredSpace ? 'Open Space' : 'Open encounter'),
                  ),
                ),
              if (onOpen != null) const SizedBox(width: 10),
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