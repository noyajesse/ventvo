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
        ResonanceSignal(type: type, key: key, strength: strength.clamp(0, 1).toDouble()),
      );
    }

    for (final entry in _experientialPatterns.entries) {
      if (_containsAny(normalized, entry.value)) {
        add(ResonanceSignalType.experiential, entry.key);
      }
    }

    for (final entry in _semanticPatterns.entries) {
      if (_containsAny(normalized, entry.value)) {
        add(ResonanceSignalType.semantic, entry.key, strength: 0.8);
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

  bool _containsAny(String content, List<String> patterns) =>
      patterns.any(content.contains);

  static const _experientialPatterns = <String, List<String>>{
    'starting_over': ['starting over', 'start over', 'new beginning'],
    'feeling_alone': ['feel alone', 'feeling alone', 'lonely', 'no one understands'],
    'burnout': ['burned out', 'burnt out', 'burnout', 'exhausted'],
    'overthinking': ['overthinking', 'overthink', 'mind won\'t stop'],
    'uncertainty': ['uncertain', 'don\'t know what to do', 'not sure what to do'],
    'loss': ['lost someone', 'lost a friend', 'lost my', 'grief'],
    'pressure': ['under pressure', 'so much pressure', 'pressured'],
    'rejection': ['rejected', 'rejection', 'turned me down'],
    'change': ['everything changed', 'things changed', 'big change'],
  };

  static const _semanticPatterns = <String, List<String>>{
    'university': ['university', 'campus', 'lecture', 'assignment', 'course'],
    'work': ['work', 'job', 'boss', 'coworker', 'office'],
    'family': ['family', 'mum', 'mom', 'dad', 'parent', 'brother', 'sister'],
    'friendship': ['friend', 'friendship', 'bestie'],
    'relationship': ['relationship', 'partner', 'boyfriend', 'girlfriend'],
    'money': ['money', 'rent', 'bills', 'debt', 'salary'],
    'future': ['future', 'career', 'what next', 'my life'],
  };
}
