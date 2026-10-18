import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ventvo_voice/providers/vent_provider.dart';
import '../data/crash_out_space_prototype_data.dart';
import '../models/crash_out.dart';
import '../models/experience_representation.dart';
import '../providers/crash_out_space_experience_provider.dart';
import '../providers/crash_out_space_provider.dart';
import '../services/crash_out_experience_interpreter.dart';
import '../services/crash_out_opposite_experience_service.dart';
import 'crash_out_no_encounter_screen.dart';
import 'crash_out_space_screen.dart';

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
  }

  ExperienceAtom? _firstMeaningfulAtom(List<ExperienceAtom> atoms) {
    for (final atom in atoms) {
      if (atom.confidence >= 0.55 && atom.intensity >= 0.35) {
        return atom;
      }
    }
    return null;
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
