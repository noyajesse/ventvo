import '../../../features/spaces/models/echo.dart';
import '../models/resonance_signal.dart';

/// Extracts deterministic, explainable Resonance signals from an Echo.
///
/// Echoes are responses to experiences, so they should not become independent
/// discovery candidates by default. Their signals instead enrich the human
/// connection layer around the Vent they belong to.
class EchoResonanceSignalGenerator {
  const EchoResonanceSignalGenerator();

  List<ResonanceSignal> generate(Echo echo) {
    final normalized = echo.content.toLowerCase();
    final signals = <ResonanceSignal>[];

    void add(ResonanceSignalType type, String key, {double strength = 1}) {
      signals.add(
        ResonanceSignal(
          type: type,
          key: key,
          strength: strength.clamp(0, 1).toDouble(),
        ),
      );
    }

    for (final pattern in _patterns) {
      if (pattern.phrases.any(normalized.contains)) {
        add(pattern.type, pattern.key, strength: pattern.strength);
      }
    }

    add(ResonanceSignalType.relationship, 'echo_response');

    return List.unmodifiable(signals);
  }

  static const _patterns = <_EchoSignalPattern>[
    _EchoSignalPattern(
      ResonanceSignalType.experiential,
      'shared_experience',
      ['same thing', 'same experience', 'i went through this', 'been there'],
      strength: 0.9,
    ),
    _EchoSignalPattern(
      ResonanceSignalType.experiential,
      'understanding',
      ['i understand', 'i get it', 'i hear you', 'you are not alone'],
      strength: 0.85,
    ),
    _EchoSignalPattern(
      ResonanceSignalType.intent,
      'perspective',
      ['my perspective', 'from my experience', 'what helped me', 'for me'],
      strength: 0.8,
    ),
    _EchoSignalPattern(
      ResonanceSignalType.relationship,
      'connection',
      ['less alone', 'felt understood', 'relate to this', 'relate to you'],
      strength: 0.85,
    ),
  ];
}

class _EchoSignalPattern {
  final ResonanceSignalType type;
  final String key;
  final List<String> phrases;
  final double strength;

  const _EchoSignalPattern(
    this.type,
    this.key,
    this.phrases, {
    required this.strength,
  });
}
