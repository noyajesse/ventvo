import '../models/crash_out.dart';
import '../../ventvo_voice/models/vent.dart';

/// Finds a meaningfully opposite public experience for a Crash Out.
///
/// Crash Out is intentionally different from "Find People Who Understand":
/// this service does not reward shared experience signals. It looks for the
/// other side of a small set of human tensions, then uses context only as
/// supporting evidence.
///
/// This is the first deterministic prototype. The matching boundary is kept
/// here so a richer semantic model can replace it later without changing the
/// Crash Out experience.
class CrashOutOppositeExperienceService {
  const CrashOutOppositeExperienceService();

  CrashOutOppositeMatch? find({
    required CrashOut crashOut,
    required Iterable<Vent> experiences,
    Set<String> excludedIds = const {},
  }) {
    if (crashOut.type != CrashOutType.text) return null;

    final sourceText = crashOut.textContent?.trim().toLowerCase() ?? '';
    if (sourceText.length < 3) return null;

    CrashOutOppositeMatch? best;

    for (final vent in experiences) {
      if (!vent.isDiscoverable || excludedIds.contains(vent.id)) continue;

      final score = _score(sourceText, vent.content.toLowerCase());
      if (score <= 0) continue;

      final candidate = CrashOutOppositeMatch(
        experience: vent,
        score: score,
      );

      if (best == null || candidate.score > best.score) {
        best = candidate;
      }
    }

    return best;
  }

  double _score(String source, String candidate) {
    var score = 0.0;
    var foundOpposite = false;

    for (final pair in _tensions) {
      final sourceSide = _containsAny(source, pair.left);
      final candidateSide = _containsAny(candidate, pair.right);
      final reverseSourceSide = _containsAny(source, pair.right);
      final reverseCandidateSide = _containsAny(candidate, pair.left);

      if (sourceSide && candidateSide) {
        score += pair.strength;
        foundOpposite = true;
      }

      if (reverseSourceSide && reverseCandidateSide) {
        score += pair.strength;
        foundOpposite = true;
      }
    }

    if (!foundOpposite) return 0;

    // Shared context makes an opposite experience more meaningful, but it
    // never creates an opposite match by itself.
    for (final context in _contexts) {
      if (_containsAny(source, context) && _containsAny(candidate, context)) {
        score += 0.12;
      }
    }

    return score.clamp(0.0, 1.0).toDouble();
  }

  bool _containsAny(String content, List<String> phrases) {
    return phrases.any((phrase) => content.contains(phrase));
  }

  static const _contexts = <String>[
    'friend',
    'friendship',
    'family',
    'mum',
    'mom',
    'dad',
    'parent',
    'relationship',
    'partner',
    'boyfriend',
    'girlfriend',
    'dating',
    'school',
    'university',
    'campus',
    'work',
    'job',
    'office',
    'boss',
    'money',
    'rent',
    'bills',
  ];

  static const _tensions = <_OppositeTension>[
    _OppositeTension(
      left: [
        'leave me alone',
        'want to be alone',
        'just want space',
        'need space',
        'give me space',
        'stop checking on me',
        'stop asking me',
        'want people to leave me',
      ],
      right: [
        'wish someone would check on me',
        'wish someone would ask',
        'wish someone would notice',
        'wish someone cared',
        'want someone to check on me',
        'want someone to ask',
        'want someone to notice',
        'want someone to stay',
        'dont want to be alone',
        "don't want to be alone",
      ],
      strength: 0.9,
    ),
    _OppositeTension(
      left: [
        'need someone',
        'need help',
        'wish someone would help',
        'want someone to take care of me',
        'want to depend on someone',
        'tired of doing everything myself',
        'doing everything myself',
      ],
      right: [
        'dont need anyone',
        "don't need anyone",
        'dont want help',
        "don't want help",
        'hate depending on people',
        'dont want to depend on anyone',
        "don't want to depend on anyone",
        'prefer doing everything myself',
        'want to handle everything myself',
      ],
      strength: 0.88,
    ),
    _OppositeTension(
      left: [
        'nobody notices me',
        'feel invisible',
        'feel unseen',
        'no one sees me',
        'wish people noticed me',
        'wish someone noticed me',
      ],
      right: [
        'everyone notices me',
        'people notice me',
        'too much attention',
        'everyone expects',
        'everyone depends on me',
        'everyone relies on me',
        'people always need me',
      ],
      strength: 0.86,
    ),
    _OppositeTension(
      left: [
        'afraid they will leave',
        'afraid of being left',
        'dont want them to leave',
        "don't want them to leave",
        'wish they would stay',
        'want them to stay',
      ],
      right: [
        'need to leave',
        'want to leave',
        'need distance',
        'want distance',
        'need to get away',
        'want to get away',
        'cant stay',
        "can't stay",
      ],
      strength: 0.9,
    ),
    _OppositeTension(
      left: [
        'want to be understood',
        'wish they understood',
        'wish someone understood',
        'want someone to understand me',
      ],
      right: [
        'dont want to explain',
        "don't want to explain",
        'tired of explaining',
        'dont know how to explain',
        "don't know how to explain",
        'dont want to talk about it',
        "don't want to talk about it",
      ],
      strength: 0.84,
    ),
    _OppositeTension(
      left: [
        'feel behind',
        'everyone is ahead',
        'falling behind',
        'not doing enough',
        'not good enough',
      ],
      right: [
        'everyone expects me',
        'too much pressure',
        'under pressure',
        'people expect too much',
        'cant slow down',
        "can't slow down",
        'doing too much',
      ],
      strength: 0.78,
    ),
  ];
}

class CrashOutOppositeMatch {
  final Vent experience;
  final double score;

  const CrashOutOppositeMatch({
    required this.experience,
    required this.score,
  });
}

class _OppositeTension {
  final List<String> left;
  final List<String> right;
  final double strength;

  const _OppositeTension({
    required this.left,
    required this.right,
    required this.strength,
  });
}
