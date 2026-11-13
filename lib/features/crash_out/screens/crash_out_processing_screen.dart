import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ventvo_voice/providers/vent_provider.dart';
import '../data/crash_out_space_prototype_data.dart';
import '../models/crash_out.dart';
import '../models/experience_representation.dart';
import '../providers/crash_out_provider.dart';
import '../providers/crash_out_space_experience_provider.dart';
import '../providers/crash_out_space_provider.dart';
import '../services/crash_out_experience_interpreter.dart';
import '../services/crash_out_opposite_experience_service.dart';
import 'crash_out_no_encounter_screen.dart';
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
      final experiences = await ref.read(ventProvider.future);
      if (!mounted) return;

      final match = CrashOutOppositeExperienceService().find(
        crashOut: widget.crashOut,
        experiences: experiences,
      );

      // A real opposite is a useful doorway when one exists, but the wider
      // Space is not conditional on finding one. Use the interpreted human
      // tension to open its broader experience collection without claiming a
      // match that the prototype could not establish.
      final representation =
          const CrashOutExperienceInterpreter().interpret(widget.crashOut);
      final sourceAtom = match?.sourceAtom ??
          _firstMeaningfulAtom(representation.atoms);

      if (!mounted) return;

      if (sourceAtom == null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const CrashOutNoEncounterScreen(),
          ),
        );
        return;
      }

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

      String? matchedExperienceId;
      if (match != null) {
        final doorway = await spaceNotifier.ensureFromVent(
          spaceId: tension.name,
          vent: match.experience,
        );
        matchedExperienceId = doorway.id;
      }

      if (!mounted) return;

      final ownerVoiceId = widget.crashOut.ownerVoiceId?.trim();
      if (ownerVoiceId == null || ownerVoiceId.isEmpty) {
        throw StateError('This Crash Out has no owning Voice.');
      }

      await ref
          .read(crashOutProvider.notifier)
          .markSpaceEntered(
            widget.crashOut.id,
            ownerVoiceId: ownerVoiceId,
            spaceId: tension.name,
            matchedExperienceId: matchedExperienceId,
          );

      final spaceExperiences = spaceNotifier.experiencesFor(tension.name);
      if (matchedExperienceId != null) {
        spaceExperiences.sort((a, b) {
          if (a.id == matchedExperienceId) return -1;
          if (b.id == matchedExperienceId) return 1;
          return b.createdAt.compareTo(a.createdAt);
        });
      }

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
      // A failed local read/write must not leave the user on an endless
      // processing screen. The original Crash Out remains in Private.
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

  void _retry() {
    setState(() => _hasProcessingError = false);
    _process();
  }

  void _returnToPrivate() {
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
                    Icons.lock_outline,
                    color: Colors.white70,
                    size: 48,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Your Crash Out is still private.',
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
                    'We couldn’t open the wider Space just now. Nothing from your original Crash Out was shared.',
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
                      onPressed: _returnToPrivate,
                      child: const Text('Return to Private'),
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
                  'Finding the wider space around this experience.',
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
