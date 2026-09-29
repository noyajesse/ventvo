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
      if (!vent.isDiscoverable ||
          excludedIds.contains(vent.id) ||
          vent.originatingCrashOutId == crashOut.id) {
        continue;
      }

      final candidate = interpreter.interpretText(vent.content);
      final opposition = _bestOpposition(source, candidate);
      if (opposition == null) continue;

      final score = _score(
        source,
        candidate,
        sourceAtom: opposition.source,
        candidateAtom: opposition.candidate,
      );

      if (score <= 0) continue;

      final match = CrashOutOppositeMatch(
        experience: vent,
        score: score,
        sourceAtom: opposition.source,
        candidateAtom: opposition.candidate,
      );

      if (best == null || match.score > best.score) {
        best = match;
      }
    }

    return best;
  }

  _Opposition? _bestOpposition(
    ExperienceRepresentation source,
    ExperienceRepresentation candidate,
  ) {
    _Opposition? best;

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
        final strength = 0.72 * evidence + 0.28 * intensity;

        if (best == null || strength > best.strength) {
          best = _Opposition(
            source: sourceAtom,
            candidate: candidateAtom,
            strength: strength,
          );
        }
      }
    }

    return best;
  }

  double _score(
    ExperienceRepresentation source,
    ExperienceRepresentation candidate, {
    required ExperienceAtom sourceAtom,
    required ExperienceAtom candidateAtom,
  }) {
    final opposition =
        0.72 *
            (sourceAtom.confidence * candidateAtom.confidence) +
        0.28 *
            ((sourceAtom.intensity + candidateAtom.intensity) / 2);

    if (opposition <= 0) return 0;

    final sharedContexts =
        source.contexts.intersection(candidate.contexts).length;
    final contextBonus = (sharedContexts * 0.04)
        .clamp(0.0, 0.12)
        .toDouble();

    return (opposition + contextBonus).clamp(0.0, 1.0).toDouble();
  }
}

class CrashOutOppositeMatch {
  final Vent experience;
  final double score;
  final ExperienceAtom sourceAtom;
  final ExperienceAtom candidateAtom;

  const CrashOutOppositeMatch({
    required this.experience,
    required this.score,
    required this.sourceAtom,
    required this.candidateAtom,
  });
}

class _Opposition {
  final ExperienceAtom source;
  final ExperienceAtom candidate;
  final double strength;

  const _Opposition({
    required this.source,
    required this.candidate,
    required this.strength,
  });
}
