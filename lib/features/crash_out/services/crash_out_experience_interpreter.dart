import '../models/crash_out.dart';
import '../models/experience_representation.dart';

/// Converts a Crash Out into a small set of opposition-worthy experience
/// atoms.
///
/// This is intentionally deterministic for the first prototype. The rules
/// describe human tensions rather than emotions, so the system can distinguish
/// meaningful opposition from simple topic overlap.
class CrashOutExperienceInterpreter {
  const CrashOutExperienceInterpreter();

  ExperienceRepresentation interpret(CrashOut crashOut) {
    if (crashOut.type != CrashOutType.text) {
      return const ExperienceRepresentation();
    }

    final text = crashOut.textContent?.trim().toLowerCase() ?? '';
    if (text.length < 3) {
      return const ExperienceRepresentation();
    }

    final atoms = <ExperienceAtom>[];

    for (final rule in _rules) {
      final matches = <String>[];

      for (final phrase in rule.leftEvidence) {
        if (_containsPhrase(text, phrase)) {
          matches.add(phrase);
        }
      }

      if (matches.isNotEmpty) {
        atoms.add(
          ExperienceAtom(
            tension: rule.tension,
            position: rule.leftPosition,
            direction: rule.leftDirection,
            confidence: _confidence(matches.length, rule.leftEvidence.length),
            intensity: _intensity(text, matches.length),
            evidence: matches,
          ),
        );
      }

      final rightMatches = <String>[];
      for (final phrase in rule.rightEvidence) {
        if (_containsPhrase(text, phrase)) {
          rightMatches.add(phrase);
        }
      }

      if (rightMatches.isNotEmpty) {
        atoms.add(
          ExperienceAtom(
            tension: rule.tension,
            position: rule.rightPosition,
            direction: rule.rightDirection,
            confidence:
                _confidence(rightMatches.length, rule.rightEvidence.length),
            intensity: _intensity(text, rightMatches.length),
            evidence: rightMatches,
          ),
        );
      }
    }

    return ExperienceRepresentation(
      atoms: _deduplicate(atoms),
      contexts: _extractContexts(text),
    );
  }

  List<ExperienceAtom> _deduplicate(List<ExperienceAtom> atoms) {
    final seen = <String>{};
    final result = <ExperienceAtom>[];

    for (final atom in atoms) {
      final key =
          '${atom.tension.name}:${atom.direction.name}:${atom.position.name}';
      if (seen.add(key)) {
        result.add(atom);
      }
    }

    return result;
  }

  double _confidence(int matchCount, int evidenceCount) {
    final coverage = matchCount / evidenceCount;
    return (0.72 + (coverage * 0.22)).clamp(0.0, 0.96).toDouble();
  }

  double _intensity(String text, int matchCount) {
    var value = 0.52 + (matchCount * 0.08);

    if (text.contains('really ') ||
        text.contains('so tired') ||
        text.contains('always ') ||
        text.contains('never ') ||
        text.contains('hate ')) {
      value += 0.08;
    }

    return value.clamp(0.0, 1.0).toDouble();
  }

  bool _containsPhrase(String text, String phrase) {
    return text.contains(phrase);
  }

  Set<String> _extractContexts(String text) {
    const contextTerms = <String>[
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

    return {
      for (final term in contextTerms)
        if (text.contains(term)) term,
    };
  }

  static const _rules = <_TensionRule>[
    _TensionRule(
      tension: HumanTension.attention,
      leftEvidence: [
        'leave me alone',
        'want to be alone',
        'just want space',
        'need space',
        'give me space',
        'stop checking on me',
        'stop asking me',
      ],
      leftPosition: ExperiencePosition.protective,
      leftDirection: ExperienceDirection.away,
      rightEvidence: [
        'wish someone would check on me',
        'wish someone would ask',
        'wish someone would notice',
        'wish someone cared',
        'want someone to check on me',
        'want someone to ask',
        'want someone to notice',
        'dont want to be alone',
        "don't want to be alone",
      ],
      rightPosition: ExperiencePosition.seeking,
      rightDirection: ExperienceDirection.toward,
    ),
    _TensionRule(
      tension: HumanTension.dependence,
      leftEvidence: [
        'need someone',
        'need help',
        'wish someone would help',
        'want someone to take care of me',
        'want to depend on someone',
        'tired of doing everything myself',
        'doing everything myself',
      ],
      leftPosition: ExperiencePosition.seeking,
      leftDirection: ExperienceDirection.toward,
      rightEvidence: [
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
      rightPosition: ExperiencePosition.protective,
      rightDirection: ExperienceDirection.away,
    ),
    _TensionRule(
      tension: HumanTension.attention,
      leftEvidence: [
        'nobody notices me',
        'feel invisible',
        'feel unseen',
        'no one sees me',
        'wish people noticed me',
        'wish someone noticed me',
      ],
      leftPosition: ExperiencePosition.lacking,
      leftDirection: ExperienceDirection.toward,
      rightEvidence: [
        'everyone notices me',
        'people notice me',
        'too much attention',
        'everyone depends on me',
        'everyone relies on me',
        'people always need me',
      ],
      rightPosition: ExperiencePosition.overwhelmed,
      rightDirection: ExperienceDirection.away,
    ),
    _TensionRule(
      tension: HumanTension.presence,
      leftEvidence: [
        'afraid they will leave',
        'afraid of being left',
        'dont want them to leave',
        "don't want them to leave",
        'wish they would stay',
        'want them to stay',
      ],
      leftPosition: ExperiencePosition.seeking,
      leftDirection: ExperienceDirection.toward,
      rightEvidence: [
        'need to leave',
        'want to leave',
        'need distance',
        'want distance',
        'need to get away',
        'want to get away',
        'cant stay',
        "can't stay",
      ],
      rightPosition: ExperiencePosition.protective,
      rightDirection: ExperienceDirection.away,
    ),
    _TensionRule(
      tension: HumanTension.explanation,
      leftEvidence: [
        'want to be understood',
        'wish they understood',
        'wish someone understood',
        'want someone to understand me',
      ],
      leftPosition: ExperiencePosition.seeking,
      leftDirection: ExperienceDirection.toward,
      rightEvidence: [
        'dont want to explain',
        "don't want to explain",
        'tired of explaining',
        'dont know how to explain',
        "don't know how to explain",
        'dont want to talk about it',
        "don't want to talk about it",
      ],
      rightPosition: ExperiencePosition.protective,
      rightDirection: ExperienceDirection.away,
    ),
    _TensionRule(
      tension: HumanTension.responsibility,
      leftEvidence: [
        'feel behind',
        'everyone is ahead',
        'falling behind',
        'not doing enough',
        'not good enough',
      ],
      leftPosition: ExperiencePosition.lacking,
      leftDirection: ExperienceDirection.toward,
      rightEvidence: [
        'everyone expects me',
        'too much pressure',
        'under pressure',
        'people expect too much',
        'cant slow down',
        "can't slow down",
        'doing too much',
      ],
      rightPosition: ExperiencePosition.overwhelmed,
      rightDirection: ExperienceDirection.away,
    ),
  ];

}

class _TensionRule {
  final HumanTension tension;
  final List<String> leftEvidence;
  final ExperiencePosition leftPosition;
  final ExperienceDirection leftDirection;
  final List<String> rightEvidence;
  final ExperiencePosition rightPosition;
  final ExperienceDirection rightDirection;

  const _TensionRule({
    required this.tension,
    required this.leftEvidence,
    required this.leftPosition,
    required this.leftDirection,
    required this.rightEvidence,
    required this.rightPosition,
    required this.rightDirection,
  });
}
