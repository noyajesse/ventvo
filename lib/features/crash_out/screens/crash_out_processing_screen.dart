import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ventvo_voice/providers/vent_provider.dart';
import '../../ventvo_voice/providers/voice_provider.dart';
import '../models/crash_out.dart';
import '../services/crash_out_opposite_experience_service.dart';
import '../providers/experience_thread_provider.dart';
import '../models/experience_thread.dart';
import 'experience_thread_screen.dart';
import 'crash_out_no_encounter_screen.dart';

class CrashOutProcessingScreen extends ConsumerStatefulWidget {
  final CrashOut crashOut;

  const CrashOutProcessingScreen({
    super.key,
    required this.crashOut,
  });

  @override
  ConsumerState<CrashOutProcessingScreen> createState() =>
      _CrashOutProcessingScreenState();
}

class _CrashOutProcessingScreenState
    extends ConsumerState<CrashOutProcessingScreen> {
  @override
  void initState() {
    super.initState();
    _process();
  }

  Future<void> _process() async {
    final experiences = await ref.read(ventProvider.future);
    if (!mounted) return;

    final match = CrashOutOppositeExperienceService().find(
          crashOut: widget.crashOut,
          experiences: experiences,
        );

    if (!mounted) return;

    if (match == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const CrashOutNoEncounterScreen(),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final threadId = 'thread_${now.microsecondsSinceEpoch}';
    final ownVoice = ref.read(ventvoVoiceProvider).asData?.value;

    final thread = ExperienceThread(
      id: threadId,
      originCrashOutId: widget.crashOut.id,
      createdAt: now,
      contributions: [
        ExperienceContribution(
          id: '${threadId}_origin',
          threadId: threadId,
          content: widget.crashOut.textContent ?? '',
          type: ExperienceContributionType.origin,
          createdAt: widget.crashOut.createdAt,
          voiceName: ownVoice?.name,
          voiceMark: ownVoice?.mark,
        ),
        ExperienceContribution(
          id: '${threadId}_opposite_${match.experience.id}',
          threadId: threadId,
          content: match.experience.content,
          type: ExperienceContributionType.opposite,
          createdAt: match.experience.createdAt,
          sourceExperienceId: match.experience.id,
          voiceName: match.experience.voiceName,
          voiceMark: match.experience.voiceMark,
        ),
      ],
    );

    await ref.read(experienceThreadProvider.notifier).createThread(thread);
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ExperienceThreadScreen(
          crashOut: widget.crashOut,
          thread: thread,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF111111),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'You let it out.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  'Let’s see what’s on the other side.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 17,
                    height: 1.5,
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
