import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ventvo_voice/providers/vent_provider.dart';
import '../models/crash_out.dart';
import '../services/crash_out_opposite_experience_service.dart';
import '../services/crash_out_experience_interpreter.dart';
import '../models/experience_representation.dart';
import 'crash_out_space_screen.dart';
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

    // The opposite is the doorway, not the destination. Build the broader
    // Space from discoverable experiences connected to the same human tension.
    const interpreter = CrashOutExperienceInterpreter();
    final spaceExperiences = experiences.where((experience) {
      if (!experience.isDiscoverable ||
          experience.originatingCrashOutId == widget.crashOut.id) {
        return false;
      }

      final representation = interpreter.interpretText(experience.content);
      return representation.atoms.any(
        (atom) =>
            atom.tension == match.sourceAtom.tension &&
            atom.confidence >= 0.55 &&
            atom.intensity >= 0.35,
      );
    }).toList()
      ..sort((a, b) {
        if (a.id == match.experience.id) return -1;
        if (b.id == match.experience.id) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => CrashOutSpaceScreen(
          tension: match.sourceAtom.tension,
          experiences: spaceExperiences,
          matchedExperienceId: match.experience.id,
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
