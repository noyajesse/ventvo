import '../models/crash_out.dart';
import '../models/experience_representation.dart';
import 'crash_out_experience_interpreter.dart';
import '../../ventvo_voice/models/vent.dart';

/// Finds a meaningfully opposite public experience for a Crash Out.
///
/// This service deliberately matches experiences, not people. It requires
/// opposing directions on the same human tension. Shared context can make
/// the encounter more meaningful, but can never create opposition by itself.
class CrashOutOppositeExperienceService {
  final CrashOutExperienceInterpreter interpreter;

  const CrashOutOppositeExperienceService({
    this.interpreter = const CrashOutExperienceInterpreter(),
  });

  CrashOutOppositeMatch? find({
    required CrashOut crashOut,
    required Iterable<Vent> experiences,
    Set<String> excludedIds = const {},
  }) {
    final source = interpreter.interpret(crashOut);
    if (!source.isMeaningful) return null;

    CrashOutOppositeMatch? best;

    for (final vent in experiences) {
      if (!vent.isDiscoverable || excludedIds.contains(vent.id)) continue;

      final candidate = interpreter.interpretText(vent.content);
      final score = _score(source, candidate);
      if (score <= 0) continue;

      final match = CrashOutOppositeMatch(
        experience: vent,
        score: score,
      );

      if (best == null || match.score > best.score) {
        best = match;
      }
    }

    return best;
  }

  double _score(
    ExperienceRepresentation source,
    ExperienceRepresentation candidate,
  ) {
    if (!candidate.isMeaningful) return 0;

    var bestOpposition = 0.0;
    var bestContextBonus = 0.0;

    for (final sourceAtom in source.atoms) {
      if (sourceAtom.confidence < 0.55 || sourceAtom.intensity < 0.35) {
        continue;
      }

      for (final candidateAtom in candidate.atoms) {
        if (!sourceAtom.opposes(candidateAtom)) continue;

        final evidence =
            sourceAtom.confidence * candidateAtom.confidence;
        final intensity =
            (sourceAtom.intensity + candidateAtom.intensity) / 2;

        // The semantic opposition is the gate. Context is only a small
        // supporting signal after that gate has been satisfied.
        final opposition = 0.72 * evidence + 0.28 * intensity;
        if (opposition > bestOpposition) {
          bestOpposition = opposition;
        }
      }
    }

    if (bestOpposition <= 0) return 0;

    final sharedContexts =
        source.contexts.intersection(candidate.contexts).length;
    bestContextBonus = (sharedContexts * 0.04).clamp(0.0, 0.12).toDouble();

    return (bestOpposition + bestContextBonus)
        .clamp(0.0, 1.0)
        .toDouble();
  }
}

class CrashOutOppositeMatch {
  final Vent experience;
  final double score;

  const CrashOutOppositeMatch({
    required this.experience,
    required this.score,
  });
}
