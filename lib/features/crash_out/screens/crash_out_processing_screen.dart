import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ventvo_voice/providers/vent_provider.dart';
import '../../ventvo_voice/providers/voice_provider.dart';
import '../data/crash_out_space_prototype_data.dart';
import '../models/crash_out.dart';
import '../models/experience_representation.dart';
import '../providers/crash_out_provider.dart';
import '../providers/crash_out_space_experience_provider.dart';
import '../providers/crash_out_space_provider.dart';
import '../services/crash_out_experience_interpreter.dart';
import '../services/crash_out_opposite_experience_service.dart';
import 'crash_out_space_screen.dart';
import 'private_crash_outs_screen.dart';

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
  bool _hasProcessingError = false;

  @override
  void initState() {
    super.initState();
    _process();
  }

  Future<void> _process() async {
    try {
      final activeVoice = await ref.read(ventvoVoiceProvider.future);
      final activeVoiceId = activeVoice?.voiceId?.trim();
      final ownerVoiceId = widget.crashOut.ownerVoiceId?.trim();
      if (activeVoiceId == null ||
          activeVoiceId.isEmpty ||
          ownerVoiceId == null ||
          ownerVoiceId.isEmpty ||
          activeVoiceId != ownerVoiceId) {
        throw StateError('This Crash Out belongs to another Voice.');
      }

      final experiences = await ref.read(ventProvider.future);
      if (!mounted) return;

      final match = CrashOutOppositeExperienceService().find(
        crashOut: widget.crashOut,
        experiences: experiences,
      );

      final representation =
          const CrashOutExperienceInterpreter().interpret(widget.crashOut);
      final sourceAtom = match?.sourceAtom ??
          _firstMeaningfulAtom(representation.atoms) ??
          const ExperienceAtom(
            tension: HumanTension.explanation,
            position: ExperiencePosition.seeking,
            direction: ExperienceDirection.toward,
            confidence: 0.65,
            intensity: 0.5,
          );

      if (!mounted) return;

      final tension = sourceAtom.tension;
      await ref.read(crashOutSpaceExperienceProvider.future);
      final spaceNotifier = ref.read(crashOutSpaceExperienceProvider.notifier);

      await spaceNotifier.ensurePrototypeExperiences(
        CrashOutSpacePrototypeData.forTension(tension),
      );

      await ref.read(crashOutSpaceProvider.future);
      await ref.read(crashOutSpaceProvider.notifier).ensurePrototypeReplies(
            spaceId: tension.name,
            prototypes: CrashOutSpacePrototypeData.repliesForTension(tension),
          );

      final String matchedExperienceId;
      if (match != null) {
        final doorway = await spaceNotifier.ensureFromVent(
          spaceId: tension.name,
          vent: match.experience,
        );
        matchedExperienceId = doorway.id;
      } else {
        matchedExperienceId = _oppositePrototypeId(tension, sourceAtom);
      }

      if (!mounted) return;

      final entered = await ref
          .read(crashOutProvider.notifier)
          .markSpaceEntered(
            widget.crashOut.id,
            ownerVoiceId: ownerVoiceId,
            spaceId: tension.name,
            matchedExperienceId: matchedExperienceId,
          );
      if (!entered) {
        throw StateError('This Voice cannot update the Crash Out threshold.');
      }

      final spaceExperiences = spaceNotifier.experiencesFor(tension.name);
      spaceExperiences.sort((a, b) {
        if (a.id == matchedExperienceId) return -1;
        if (b.id == matchedExperienceId) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CrashOutSpaceScreen(
            tension: tension,
            experiences: spaceExperiences,
            matchedExperienceId: matchedExperienceId,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _hasProcessingError = true);
    }
  }

  ExperienceAtom? _firstMeaningfulAtom(List<ExperienceAtom> atoms) {
    for (final atom in atoms) {
      if (atom.confidence >= 0.55 && atom.intensity >= 0.35) {
        return atom;
      }
    }
    return null;
  }

  String _oppositePrototypeId(HumanTension tension, ExperienceAtom sourceAtom) {
    final prototypes = CrashOutSpacePrototypeData.forTension(tension);
    const interpreter = CrashOutExperienceInterpreter();

    for (final candidate in prototypes) {
      final parsed = interpreter.interpretText(candidate.content);
      for (final atom in parsed.atoms) {
        if (sourceAtom.opposes(atom)) {
          return candidate.id;
        }
      }
    }
    return prototypes.length > 1 ? prototypes[1].id : prototypes.first.id;
  }

  void _retry() {
    setState(() => _hasProcessingError = false);
    _process();
  }

  void _returnToThresholdSpaces() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const PrivateCrashOutsScreen(),
      ),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hasProcessingError) {
      return Scaffold(
        backgroundColor: const Color(0xFF111111),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.waves_rounded,
                    color: Colors.white70,
                    size: 48,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Your words stayed unshared.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'We couldn\u2019t cross into the opposite-side Space just now. Nothing from your Crash Out was broadcast.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _retry,
                      child: const Text('Try again'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _returnToThresholdSpaces,
                      child: const Text('View Crash Out Spaces'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

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
                  'Crossing into the other side of this experience...',
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

