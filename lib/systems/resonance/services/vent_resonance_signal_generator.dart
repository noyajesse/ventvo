import '../../../features/spaces/models/space.dart';
import '../../../features/ventvo_voice/models/vent.dart';
import '../models/resonance_signal.dart';

/// Converts a Vent into explainable Resonance signals without AI or embeddings.
///
/// This is deliberately feature-independent so Feed, Space, and Crash Out can
/// all use the same interpretation of an experience.
class VentResonanceSignalGenerator {
  const VentResonanceSignalGenerator();

  List<ResonanceSignal> generate({
    required Vent vent,
    required Space space,
  }) {
    final signals = <ResonanceSignal>[];
    final normalized = vent.content.toLowerCase();

    void add(
      ResonanceSignalType type,
      String key, {
      double strength = 1,
    }) {
      signals.add(
        ResonanceSignal(
          type: type,
          key: key,
          strength: strength.clamp(0, 1).toDouble(),
        ),
      );
    }

    for (final pattern in _experientialPatterns) {
      final strength = _bestMatchStrength(normalized, pattern);
      if (strength > 0) {
        add(
          ResonanceSignalType.experiential,
          pattern.key,
          strength: strength,
        );
      }
    }

    for (final pattern in _semanticPatterns) {
      final strength = _bestMatchStrength(normalized, pattern);
      if (strength > 0) {
        add(
          ResonanceSignalType.semantic,
          pattern.key,
          strength: strength,
        );
      }
    }

    add(
      ResonanceSignalType.intent,
      space.mode == SpaceMode.justListen ? 'just_listen' : 'open_discussion',
    );

    if (vent.originatingCrashOutId != null) {
      add(ResonanceSignalType.context, 'from_crash_out');
    }

    if (vent.visibility == VentVisibility.private) {
      add(ResonanceSignalType.privacy, 'private', strength: 1);
    }

    if (vent.safetyState == VentSafetyState.restricted) {
      add(ResonanceSignalType.safety, 'restricted', strength: 1);
    } else if (vent.safetyState == VentSafetyState.pending) {
      add(ResonanceSignalType.safety, 'pending', strength: 0.7);
    }

    return List.unmodifiable(signals);
  }

  /// Returns the strongest phrase match for a signal pattern.
  ///
  /// Longer, more specific phrases receive a small deterministic bonus. This
  /// lets the engine distinguish a broad phrase such as "alone" from a richer
  /// expression such as "no one understands" without using AI.
  double _bestMatchStrength(String content, _SignalPattern pattern) {
    var bestStrength = 0.0;

    for (final phrase in pattern.phrases) {
      final regex = RegExp(
        r'(^|[^a-z0-9])' + RegExp.escape(phrase) + r'([^a-z0-9]|$)',
      );

      for (final match in regex.allMatches(content)) {
        if (_isNegated(content, match.start)) continue;

        final wordCount = phrase.split(' ').length;
        final specificityBonus = ((wordCount - 1) * 0.05).clamp(0, 0.15);
        final strength =
            (pattern.strength + specificityBonus).clamp(0, 1).toDouble();

        if (strength > bestStrength) bestStrength = strength;
      }
    }

    return bestStrength;
  }

  /// Checks a small window before a matched phrase for common negation forms.
  ///
  /// This is intentionally conservative and deterministic. It prevents clear
  /// cases such as "I don't feel alone" from being treated as the same
  /// experience as "I feel alone", without attempting full NLP parsing.
  bool _isNegated(String content, int matchStart) {
    final prefix = content.substring(0, matchStart).trimRight();

    return RegExp(
      r"(?:\b(?:not|never|don't|do not|isn't|is not|aren't|are not|no longer)\b)(?:\W+\w+){0,2}\W*$",
    ).hasMatch(prefix);
  }

  static const _experientialPatterns = <_SignalPattern>[
    _SignalPattern('starting_over', [
      'starting over',
      'start over',
      'new beginning',
      'begin again',
    ]),
    _SignalPattern('feeling_alone', [
      'no one understands',
      'feel alone',
      'feeling alone',
      'feel lonely',
      'feeling lonely',
      'lonely',
      'alone',
    ], strength: 0.9),
    _SignalPattern('burnout', [
      'burned out',
      'burnt out',
      'burnout',
      'completely exhausted',
      'mentally exhausted',
      'exhausted',
    ]),
    _SignalPattern('overthinking', [
      'mind won\'t stop',
      'can\'t stop thinking',
      'overthinking',
      'overthink',
      'thinking about it constantly',
    ]),
    _SignalPattern('uncertainty', [
      'don\'t know what to do',
      'not sure what to do',
      'have no idea what to do',
      'uncertain',
      'unsure',
    ]),
    _SignalPattern('loss', [
      'lost someone',
      'lost a friend',
      'grieving',
      'grief',
    ]),
    _SignalPattern('pressure', [
      'under pressure',
      'so much pressure',
      'too much pressure',
      'pressured',
    ]),
    _SignalPattern('rejection', [
      'turned me down',
      'got rejected',
      'rejected',
      'rejection',
    ]),
    _SignalPattern('change', [
      'everything changed',
      'things changed',
      'big change',
      'life changed',
    ]),
    _SignalPattern('being_stuck', [
      'feel stuck',
      'feeling stuck',
      'stuck in my life',
      'going nowhere',
    ]),
    _SignalPattern('comparison', [
      'compare myself',
      'comparing myself',
      'everyone is ahead',
      'feel behind',
      'feeling behind',
    ]),
    _SignalPattern('belonging', [
      'where i belong',
      'fit in',
      'feel like i belong',
      'don\'t belong',
    ]),
    _SignalPattern('connection_difficulty', [
      'can\'t connect with anyone',
      'can\'t connect',
      'hard to connect with anyone',
      'hard to connect',
      'feel disconnected',
      'feeling disconnected',
      'disconnected from everyone',
    ], strength: 0.95),
  ];

  static const _semanticPatterns = <_SignalPattern>[
    _SignalPattern('university', [
      'university',
      'campus',
      'lecture',
      'assignment',
      'course',
    ], strength: 0.8),
    _SignalPattern('work', [
      'workplace',
      'job',
      'boss',
      'coworker',
      'office',
      'work',
    ], strength: 0.8),
    _SignalPattern('family', [
      'family',
      'mum',
      'mom',
      'dad',
      'parent',
      'brother',
      'sister',
    ], strength: 0.8),
    _SignalPattern('friendship', [
      'friendship',
      'bestie',
      'friend',
    ], strength: 0.8),
    _SignalPattern('relationship', [
      'relationship',
      'partner',
      'boyfriend',
      'girlfriend',
      'dating',
    ], strength: 0.8),
    _SignalPattern('money', [
      'money',
      'rent',
      'bills',
      'debt',
      'salary',
      'financial',
    ], strength: 0.8),
    _SignalPattern('future', [
      'future',
      'career',
      'what next',
      'my life',
    ], strength: 0.8),
    _SignalPattern('health', [
      'health',
      'sick',
      'illness',
      'hospital',
      'doctor',
    ], strength: 0.8),
  ];
}

class _SignalPattern {
  final String key;
  final List<String> phrases;
  final double strength;

  const _SignalPattern(
    this.key,
    this.phrases, {
    this.strength = 1,
  });
}
