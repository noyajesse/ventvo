import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../../spaces/models/echo_note.dart';
import '../../spaces/providers/space_provider.dart';
import '../../spaces/screens/space_screen.dart';
import '../../spaces/models/space.dart';
import '../../ventvo_voice/models/vent.dart';
import '../../../systems/resonance/models/resonance_thread.dart';
import '../models/resonance_thread_experience.dart';
import '../providers/resonance_thread_experience_provider.dart';

class ResonanceThreadDetailScreen extends ConsumerWidget {
  final ResonanceThread thread;
  final Map<String, Vent> ventsById;

  const ResonanceThreadDetailScreen({
    super.key,
    required this.thread,
    required this.ventsById,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spaces = ref.watch(spaceProvider).asData?.value ?? const <Space>[];
    final spacesById = {for (final space in spaces) space.id: space};
    final resolver = ref.watch(resonanceThreadExperienceResolverProvider);

    return Scaffold(
      backgroundColor: VentvoColors.background,
      appBar: AppBar(
        title: const Text('Resonance Thread'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<ResonanceThreadExperience>>(
        future: resolver.resolve(
          thread: thread,
          ventsById: ventsById,
          spacesById: spacesById,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 1.5),
            );
          }

          final experiences =
              snapshot.data ?? const <ResonanceThreadExperience>[];

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
            children: [
              const Text(
                'RESONANCE THREAD',
                style: TextStyle(
                  color: VentvoColors.textMuted,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                thread.voiceMarks.isEmpty
                    ? 'Different Voices, connected through experience'
                    : thread.voiceMarks.join('  ·  '),
                style: const TextStyle(
                  color: VentvoColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${thread.experienceIds.length} connected experiences',
                style: const TextStyle(
                  color: VentvoColors.textMuted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 26),
              if (experiences.isEmpty)
                const Text(
                  'The connected experiences are no longer available here.',
                  style: TextStyle(
                    color: VentvoColors.textMuted,
                    fontSize: 14,
                    height: 1.5,
                  ),
                )
              else
                ...experiences.asMap().entries.map(
                  (entry) => _ExperienceStep(
                    index: entry.key,
                    experience: entry.value,
                    isLast: entry.key == experiences.length - 1,
                  ),
                ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
                decoration: BoxDecoration(
                  color: VentvoColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: VentvoColors.border),
                ),
                child: const Text(
                  'Sometimes an experience feels less alone when you discover that someone else put something similar into words.',
                  style: TextStyle(
                    color: VentvoColors.textSecondary,
                    fontSize: 13,
                    height: 1.55,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ExperienceStep extends StatelessWidget {
  final int index;
  final ResonanceThreadExperience experience;
  final bool isLast;

  const _ExperienceStep({
    required this.index,
    required this.experience,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: VentvoColors.border),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: VentvoColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 1,
                    height: 54,
                    margin: const EdgeInsets.only(top: 6),
                    color: VentvoColors.border,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
              decoration: BoxDecoration(
                color: VentvoColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: VentvoColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        experience.voiceMark,
                        style: const TextStyle(
                          color: VentvoColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        experience.isEcho ? 'ECHO' : 'VENT',
                        style: const TextStyle(
                          color: VentvoColors.textMuted,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    experience.content,
                    style: const TextStyle(
                      color: VentvoColors.textPrimary,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  if (experience.echoNotes.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    ...experience.echoNotes.map(_EchoNotePreview.new),
                  ],
                  if (experience.space != null) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () =>
                            SpaceScreen.open(context, experience.space!),
                        child: const Text('Open Space'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EchoNotePreview extends StatelessWidget {
  final EchoNote note;

  const _EchoNotePreview(this.note);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: VentvoColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: VentvoColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note.voiceMark,
            style: const TextStyle(
              color: VentvoColors.textMuted,
              fontSize: 10,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              note.content,
              style: const TextStyle(
                color: VentvoColors.textSecondary,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
