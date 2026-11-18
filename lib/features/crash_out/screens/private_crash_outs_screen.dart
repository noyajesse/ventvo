import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../../ventvo_voice/providers/voice_provider.dart';
import '../models/crash_out.dart';
import '../models/experience_representation.dart';
import '../providers/crash_out_provider.dart';
import '../providers/crash_out_space_experience_provider.dart';
import '../providers/crash_out_space_provider.dart';
import '../providers/experience_thread_provider.dart';
import '../services/crash_out_experience_interpreter.dart';
import 'crash_out_space_screen.dart';

class PrivateCrashOutsScreen extends ConsumerWidget {
  const PrivateCrashOutsScreen({super.key});

  Future<void> _letGo(
    BuildContext context,
    WidgetRef ref,
    CrashOut crashOut,
    String ownerVoiceId,
  ) async {
    final deleted = await ref.read(crashOutProvider.notifier).deleteCrashOut(
          crashOut.id,
          ownerVoiceId: ownerVoiceId,
        );
    if (!deleted) return;

    await ref
        .read(experienceThreadProvider.notifier)
        .deleteThreadForCrashOut(crashOut.id);
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
    final voiceState = ref.watch(ventvoVoiceProvider);

    return Scaffold(
      backgroundColor: VentvoColors.background,
      appBar: AppBar(
        backgroundColor: VentvoColors.background,
        elevation: 0,
        title: const Text(
          'Private',
          style: TextStyle(color: VentvoColors.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: voiceState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(
            child: Text(
              'Couldn\u2019t load your Voice.',
              style: TextStyle(color: VentvoColors.textSecondary),
            ),
          ),
          data: (voice) {
            final ownerVoiceId = voice?.voiceId?.trim();
            if (ownerVoiceId == null || ownerVoiceId.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Text(
                    'Create your Voice before opening Private Crash Outs.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: VentvoColors.textSecondary, fontSize: 17),
                  ),
                ),
              );
            }

            final crashOutState = ref.watch(crashOutProvider);
            return crashOutState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Center(
                child: Text(
                  'Couldn’t load your private Crash Outs.',
                  style: TextStyle(color: VentvoColors.textSecondary),
                ),
              ),
              data: (_) {
                final privateCrashOuts = ref
                    .read(crashOutProvider.notifier)
                    .privateCrashOutsForOwner(ownerVoiceId);

                if (privateCrashOuts.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Text(
                        'Nothing is kept here yet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: VentvoColors.textSecondary, fontSize: 17),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: privateCrashOuts.length,
                  itemBuilder: (context, index) {
                    final crashOut = privateCrashOuts[index];
                    final tension = _spaceTensionFor(crashOut);
                    final hasEnteredSpace =
                        crashOut.status == CrashOutStatus.spaceEntered &&
                        tension != null;
                    return _PrivateCrashOutCard(
                      crashOut: crashOut,
                      hasEnteredSpace: hasEnteredSpace,
                      onOpen: hasEnteredSpace
                          ? () => _openSpace(context, ref, crashOut, tension)
                          : null,
                      onLetGo: () => _letGo(
                        context,
                        ref,
                        crashOut,
                        ownerVoiceId,
                      ),
                    );
                  },
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
        color: VentvoColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: VentvoColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lock_outline, color: VentvoColors.textSecondary, size: 18),
              SizedBox(width: 8),
              Text(
                'Private Crash Out',
                style: TextStyle(
                  color: VentvoColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            crashOut.textContent ?? 'Crash Out',
            style: const TextStyle(color: VentvoColors.textPrimary, fontSize: 17, height: 1.5),
          ),
          const SizedBox(height: 20),
          if (hasEnteredSpace)
            const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: Text(
                'Your original remains private. You can return to the wider experience Space.',
                style: TextStyle(color: VentvoColors.textMuted, fontSize: 12.5),
              ),
            )
          else if (onOpen == null)
            const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: Text(
                'No wider Space has been entered yet.',
                style: TextStyle(color: VentvoColors.textMuted, fontSize: 12.5),
              ),
            ),
          Row(
            children: [
              if (onOpen != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onOpen,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: VentvoColors.textPrimary,
                      side: const BorderSide(color: VentvoColors.border),
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
                icon: const Icon(Icons.delete_outline, color: VentvoColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}