import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ventvo_voice/providers/vent_provider.dart';
import '../models/crash_out.dart';
import '../providers/crash_out_provider.dart';
import '../providers/experience_thread_provider.dart';
import '../models/experience_thread.dart';
import 'experience_thread_screen.dart';
import '../services/crash_out_opposite_experience_service.dart';
import 'crash_out_fate_screen.dart';

/// The quiet transition between releasing a Crash Out and seeing whether
/// anything meaningful surfaced on the other side.
///
/// This is deliberately not presented as "matching" or an AI loading state.
/// The service is doing real local discovery work; the UI simply gives the
/// release a moment to settle before revealing the result.
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

    final match = ref
        .read(crashOutOppositeExperienceServiceProvider)
        .find(
          crashOut: widget.crashOut,
          experiences: experiences,
        );

    if (!mounted) return;

    if (match == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CrashOutFateScreen(
            crashOut: widget.crashOut,
            match: match,
          ),
        ),
      );
      return;
    }

    final now = DateTime.now();
    final threadId = 'thread_${now.microsecondsSinceEpoch}';
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
        ),
        ExperienceContribution(
          id: '${threadId}_opposite_${match.experience.id}',
          threadId: threadId,
          content: match.experience.content,
          type: ExperienceContributionType.opposite,
          createdAt: match.experience.createdAt,
          sourceExperienceId: match.experience.id,
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
            child: _ProcessingMessage(),
          ),
        ),
      ),
    );
  }
}

class _ProcessingMessage extends StatelessWidget {
  const _ProcessingMessage();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.compare_arrows_rounded,
          color: Colors.white70,
          size: 48,
        ),
        const SizedBox(height: 28),
        const Text(
          'You let it out.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Let’s see what’s on the other side.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.54),
            fontSize: 17,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
