import '../models/crash_out.dart';
import '../models/experience_representation.dart';

/// Converts a Crash Out into opposition-worthy experience atoms.
///
/// The interpreter looks for the human tension underneath a sentence rather
/// than requiring an exact phrase. It uses small semantic signal groups and
/// simple grammatical cues, keeping the prototype deterministic and auditable.
class CrashOutExperienceInterpreter {
  const CrashOutExperienceInterpreter();

  ExperienceRepresentation interpret(CrashOut crashOut) {
    if (crashOut.type != CrashOutType.text) {
      return const ExperienceRepresentation();
    }

    return interpretText(crashOut.textContent);
  }

  ExperienceRepresentation interpretText(String? rawText) {
    final text = _normalize(rawText);
    if (text.length < 3) {
      return const ExperienceRepresentation();
    }

    final atoms = <ExperienceAtom>[];

    for (final rule in _rules) {
      final left = _evidenceFor(text, rule.leftSignals);
      if (left.isNotEmpty) {
        atoms.add(
          _atom(
            rule.tension,
            rule.leftPosition,
            rule.leftDirection,
            text,
            left,
          ),
        );
      }

      final right = _evidenceFor(text, rule.rightSignals);
      if (right.isNotEmpty) {
        atoms.add(
          _atom(
            rule.tension,
            rule.rightPosition,
            rule.rightDirection,
            text,
            right,
          ),
        );
      }
    }

    return ExperienceRepresentation(
      atoms: _deduplicate(atoms),
      contexts: _extractContexts(text),
    );
  }

  String _normalize(String? rawText) {
    var text = rawText?.trim().toLowerCase() ?? '';
    text = text.replaceAll(RegExp(r"[’‘]"), "'");
    text = text.replaceAll(RegExp(r"\bcan't\b"), 'cannot');
    text = text.replaceAll(RegExp(r"\bwon't\b"), 'will not');
    text = text.replaceAll(RegExp(r"\bdon't\b"), 'do not');
    text = text.replaceAll(RegExp(r"\bdoesn't\b"), 'does not');
    text = text.replaceAll(RegExp(r"\bdidn't\b"), 'did not');
    text = text.replaceAll(RegExp(r"\bcan't\b"), 'cannot');
    text = text.replaceAll(RegExp(r"\bi'm\b"), 'i am');
    text = text.replaceAll(RegExp(r"\bi've\b"), 'i have');
    text = text.replaceAll(RegExp(r"\bi'd\b"), 'i would');
    text = text.replaceAll(RegExp(r"[^a-z0-9']+"), ' ');
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  List<String> _evidenceFor(String text, List<_Signal> signals) {
    final evidence = <String>[];

    for (final signal in signals) {
      final matched = signal.matches(text);
      if (matched) evidence.add(signal.label);
    }

    return evidence;
  }

  ExperienceAtom _atom(
    HumanTension tension,
    ExperiencePosition position,
    ExperienceDirection direction,
    String text,
    List<String> evidence,
  ) {
    final confidence = (0.66 + evidence.length * 0.09)
        .clamp(0.0, 0.96)
        .toDouble();

    var intensity = 0.48 + evidence.length * 0.07;

    const intensifiers = [
      'really',
      'extremely',
      'so tired',
      'always',
      'never',
      'hate',
      'exhausted',
      'constantly',
    ];

    if (intensifiers.any(text.contains)) {
      intensity += 0.10;
    }

    return ExperienceAtom(
      tension: tension,
      position: position,
      direction: direction,
      confidence: confidence,
      intensity: intensity.clamp(0.0, 1.0).toDouble(),
      evidence: evidence,
    );
  }

  List<ExperienceAtom> _deduplicate(List<ExperienceAtom> atoms) {
    final byKey = <String, ExperienceAtom>{};

    for (final atom in atoms) {
      final key =
          '${atom.tension.name}:${atom.direction.name}:${atom.position.name}';
      final existing = byKey[key];

      if (existing == null ||
          atom.confidence + atom.intensity >
              existing.confidence + existing.intensity) {
        byKey[key] = atom;
      }
    }

    return byKey.values.toList();
  }

  Set<String> _extractContexts(String text) {
    const contextGroups = <String, List<String>>{
      'friends': ['friend', 'friendship'],
      'family': ['family', 'mum', 'mom', 'dad', 'parent', 'sibling'],
      'relationship': [
        'relationship',
        'partner',
        'boyfriend',
        'girlfriend',
        'dating',
        'married',
      ],
      'school': ['school', 'university', 'campus', 'class', 'lecture'],
      'work': ['work', 'job', 'office', 'boss', 'coworker'],
      'money': ['money', 'rent', 'bills', 'debt', 'salary'],
    };

    return {
      for (final entry in contextGroups.entries)
        if (entry.value.any(text.contains)) entry.key,
    };
  }

  static final _rules = <_TensionRule>[
    _TensionRule(
      HumanTension.attention,
      ExperiencePosition.protective,
      ExperienceDirection.away,
      [
        _Signal.phrase('leave me alone'),
        _Signal.phrase('want to be alone'),
        _Signal.phrase('need space'),
        _Signal.phrase('give me space'),
        _Signal.phrase('stop checking on me'),
        _Signal.phrase('stop asking me'),
        _Signal.phrase('do not check on me'),
        _Signal.phrase('do not ask me'),
        _Signal.phrase('too much attention'),
        _Signal.phrase('people keep asking'),
      ],
      ExperiencePosition.seeking,
      ExperienceDirection.toward,
      [
        _Signal.phrase('wish someone would check on me'),
        _Signal.phrase('want someone to check on me'),
        _Signal.phrase('wish someone would ask'),
        _Signal.phrase('wish someone would notice'),
        _Signal.phrase('wish someone cared'),
        _Signal.phrase('want someone to notice'),
        _Signal.phrase('wish people noticed'),
        _Signal.pattern(RegExp(r'\b(nobody|no one) (notices|sees)\b'), 'nobody notices'),
        _Signal.phrase('feel invisible'),
        _Signal.phrase('feel unseen'),
        _Signal.phrase('no one sees me'),
      ],
    ),
    _TensionRule(
      HumanTension.dependence,
      ExperiencePosition.seeking,
      ExperienceDirection.toward,
      [
        _Signal.phrase('need someone'),
        _Signal.phrase('need help'),
        _Signal.phrase('wish someone would help'),
        _Signal.phrase('want someone to help'),
        _Signal.phrase('want someone to take care of me'),
        _Signal.phrase('want support'),
        _Signal.phrase('need support'),
        _Signal.phrase('tired of doing everything myself'),
        _Signal.phrase('doing everything myself'),
        _Signal.phrase('wish i did not have to do this alone'),
      ],
      ExperiencePosition.protective,
      ExperienceDirection.away,
      [
        _Signal.phrase('do not need anyone'),
        _Signal.phrase('do not want help'),
        _Signal.phrase('hate depending on people'),
        _Signal.phrase('do not want to depend on anyone'),
        _Signal.phrase('prefer doing everything myself'),
        _Signal.phrase('want to handle everything myself'),
        _Signal.phrase('handle things myself'),
        _Signal.phrase('i can do it myself'),
      ],
    ),
    _TensionRule(
      HumanTension.presence,
      ExperiencePosition.seeking,
      ExperienceDirection.toward,
      [
        _Signal.phrase('afraid they will leave'),
        _Signal.phrase('afraid of being left'),
        _Signal.phrase('do not want them to leave'),
        _Signal.phrase('wish they would stay'),
        _Signal.phrase('want them to stay'),
        _Signal.phrase('need someone to stay'),
        _Signal.phrase('wish you would stay'),
      ],
      ExperiencePosition.protective,
      ExperienceDirection.away,
      [
        _Signal.phrase('need to leave'),
        _Signal.phrase('want to leave'),
        _Signal.phrase('need distance'),
        _Signal.phrase('want distance'),
        _Signal.phrase('need to get away'),
        _Signal.phrase('want to get away'),
        _Signal.phrase('cannot stay'),
        _Signal.phrase('do not want to stay'),
      ],
    ),
    _TensionRule(
      HumanTension.explanation,
      ExperiencePosition.seeking,
      ExperienceDirection.toward,
      [
        _Signal.phrase('want to be understood'),
        _Signal.phrase('wish they understood'),
        _Signal.phrase('wish someone understood'),
        _Signal.phrase('want someone to understand me'),
        _Signal.phrase('i want you to understand'),
        _Signal.phrase('wish people understood'),
      ],
      ExperiencePosition.protective,
      ExperienceDirection.away,
      [
        _Signal.phrase('do not want to explain'),
        _Signal.phrase('tired of explaining'),
        _Signal.phrase('do not know how to explain'),
        _Signal.phrase('do not want to talk about it'),
        _Signal.phrase('do not want to talk'),
        _Signal.phrase('tired of talking about it'),
        _Signal.phrase('do not want to have to explain'),
      ],
    ),
    _TensionRule(
      HumanTension.responsibility,
      ExperiencePosition.lacking,
      ExperienceDirection.toward,
      [
        _Signal.phrase('feel behind'),
        _Signal.phrase('everyone is ahead'),
        _Signal.phrase('falling behind'),
        _Signal.phrase('not doing enough'),
        _Signal.phrase('not good enough'),
        _Signal.phrase('cannot keep up'),
        _Signal.phrase('not keeping up'),
      ],
      ExperiencePosition.overwhelmed,
      ExperienceDirection.away,
      [
        _Signal.phrase('everyone expects me'),
        _Signal.phrase('too much pressure'),
        _Signal.phrase('under pressure'),
        _Signal.phrase('people expect too much'),
        _Signal.phrase('cannot slow down'),
        _Signal.phrase('doing too much'),
        _Signal.phrase('too many responsibilities'),
        _Signal.phrase('everyone relies on me'),
      ],
    ),
    _TensionRule(
      HumanTension.connection,
      ExperiencePosition.seeking,
      ExperienceDirection.toward,
      [
        _Signal.phrase('want to be close'),
        _Signal.phrase('want to feel close'),
        _Signal.phrase('need someone close'),
        _Signal.phrase('miss having someone'),
        _Signal.phrase('feel lonely'),
        _Signal.phrase('wish i had someone'),
        _Signal.phrase('want companionship'),
      ],
      ExperiencePosition.protective,
      ExperienceDirection.away,
      [
        _Signal.phrase('do not want anyone close'),
        _Signal.phrase('do not want to get close'),
        _Signal.phrase('need to keep my distance'),
        _Signal.phrase('want to keep my distance'),
        _Signal.phrase('better off alone'),
        _Signal.phrase('do not want a relationship'),
        _Signal.phrase('do not want to get attached'),
      ],
    ),
    _TensionRule(
      HumanTension.recognition,
      ExperiencePosition.seeking,
      ExperienceDirection.toward,
      [
        _Signal.phrase('want to be appreciated'),
        _Signal.phrase('wish people appreciated me'),
        _Signal.phrase('want recognition'),
        _Signal.phrase('want credit'),
        _Signal.phrase('nobody appreciates what i do'),
        _Signal.phrase('nobody gives me credit'),
      ],
      ExperiencePosition.protective,
      ExperienceDirection.away,
      [
        _Signal.phrase('do not want praise'),
        _Signal.phrase('do not want recognition'),
        _Signal.phrase('do not need credit'),
        _Signal.phrase('stop expecting so much from me'),
        _Signal.phrase('do not want people praising me'),
      ],
    ),
    _TensionRule(
      HumanTension.control,
      ExperiencePosition.seeking,
      ExperienceDirection.toward,
      [
        _Signal.phrase('wish someone would take over'),
        _Signal.phrase('want someone else to handle it'),
        _Signal.phrase('need someone to take over'),
        _Signal.phrase('want someone to decide'),
        _Signal.phrase('wish someone else would decide'),
      ],
      ExperiencePosition.protective,
      ExperienceDirection.away,
      [
        _Signal.phrase('i need to handle it myself'),
        _Signal.phrase('want to decide for myself'),
        _Signal.phrase('do not want anyone deciding for me'),
        _Signal.phrase('let me handle it'),
        _Signal.phrase('i want control'),
        _Signal.phrase('need to be in control'),
      ],
    ),
    _TensionRule(
      HumanTension.belonging,
      ExperiencePosition.seeking,
      ExperienceDirection.toward,
      [
        _Signal.phrase('want to fit in'),
        _Signal.phrase('want to belong'),
        _Signal.phrase('wish i was included'),
        _Signal.phrase('wish they included me'),
        _Signal.phrase('feel left out'),
        _Signal.phrase('feel excluded'),
      ],
      ExperiencePosition.protective,
      ExperienceDirection.away,
      [
        _Signal.phrase('do not want to fit in'),
        _Signal.phrase('do not want to belong'),
        _Signal.phrase('do not want to be included'),
        _Signal.phrase('rather stay out of it'),
        _Signal.phrase('do not want to be part of the group'),
      ],
    ),
    _TensionRule(
      HumanTension.vulnerability,
      ExperiencePosition.seeking,
      ExperienceDirection.toward,
      [
        _Signal.phrase('want to open up'),
        _Signal.phrase('need to open up'),
        _Signal.phrase('want to tell someone'),
        _Signal.phrase('wish i could tell someone'),
        _Signal.phrase('want to be vulnerable'),
        _Signal.phrase('want to let someone in'),
      ],
      ExperiencePosition.protective,
      ExperienceDirection.away,
      [
        _Signal.phrase('do not want to open up'),
        _Signal.phrase('do not want to tell anyone'),
        _Signal.phrase('keep everything to myself'),
        _Signal.phrase('do not want to let anyone in'),
        _Signal.phrase('do not trust people enough to open up'),
        _Signal.phrase('not ready to open up'),
      ],
    ),
  ];
}

class _TensionRule {
  final HumanTension tension;
  final ExperiencePosition leftPosition;
  final ExperienceDirection leftDirection;
  final List<_Signal> leftSignals;
  final ExperiencePosition rightPosition;
  final ExperienceDirection rightDirection;
  final List<_Signal> rightSignals;

  const _TensionRule(
    this.tension,
    this.leftPosition,
    this.leftDirection,
    this.leftSignals,
    this.rightPosition,
    this.rightDirection,
    this.rightSignals,
  );
}

class _Signal {
  final String label;
  final bool Function(String text) _matcher;

  const _Signal._(this.label, this._matcher);

  factory _Signal.phrase(String phrase) {
    return _Signal._(
      phrase,
      (text) => text.contains(phrase),
    );
  }

  factory _Signal.pattern(RegExp pattern, String label) {
    return _Signal._(
      label,
      (text) => pattern.hasMatch(text),
    );
  }

  bool matches(String text) => _matcher(text);
}
