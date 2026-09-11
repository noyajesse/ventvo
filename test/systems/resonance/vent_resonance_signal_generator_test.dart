import 'package:flutter_test/flutter_test.dart';
import 'package:ventvo/features/spaces/models/space.dart';
import 'package:ventvo/features/ventvo_voice/models/vent.dart';
import 'package:ventvo/systems/resonance/models/resonance_signal.dart';
import 'package:ventvo/systems/resonance/services/vent_resonance_signal_generator.dart';

void main() {
  const generator = VentResonanceSignalGenerator();

  test('generates experiential and semantic signals from a Vent', () {
    final vent = Vent(
      id: 'vent-1',
      content: 'I feel alone at university and I am exhausted.',
      spaceId: 'space-1',
      voiceMark: '◌',
      createdAt: DateTime(2026, 1, 1),
    );
    final space = Space(
      id: 'space-1',
      mode: SpaceMode.justListen,
      originatingVentId: 'vent-1',
      creatorVoiceMark: '◌',
      createdAt: DateTime(2026, 1, 1),
    );

    final signals = generator.generate(vent: vent, space: space);
    final keys = signals.map((signal) => signal.key).toSet();

    expect(keys, contains('feeling_alone'));
    expect(keys, contains('burnout'));
    expect(keys, contains('university'));
    expect(keys, contains('just_listen'));
  });

  test('uses Open Discussion as the Vent intent signal', () {
    final vent = Vent(
      id: 'vent-2',
      content: 'I need to talk about starting over.',
      spaceId: 'space-2',
      voiceMark: '◇',
      createdAt: DateTime(2026, 1, 1),
    );
    final space = Space(
      id: 'space-2',
      mode: SpaceMode.openDiscussion,
      originatingVentId: 'vent-2',
      creatorVoiceMark: '◇',
      createdAt: DateTime(2026, 1, 1),
    );

    final signals = generator.generate(vent: vent, space: space);

    expect(
      signals.any(
        (signal) =>
            signal.type == ResonanceSignalType.experiential &&
            signal.key == 'starting_over',
      ),
      isTrue,
    );
    expect(
      signals.any(
        (signal) =>
            signal.type == ResonanceSignalType.intent &&
            signal.key == 'open_discussion',
      ),
      isTrue,
    );
  });

  test('marks Crash Out-originated Vents with context', () {
    final vent = Vent(
      id: 'vent-3',
      content: 'I need to let this out.',
      spaceId: 'space-3',
      voiceMark: '△',
      createdAt: DateTime(2026, 1, 1),
      originatingCrashOutId: 'crash-1',
    );
    final space = Space(
      id: 'space-3',
      mode: SpaceMode.justListen,
      originatingVentId: 'vent-3',
      creatorVoiceMark: '△',
      createdAt: DateTime(2026, 1, 1),
    );

    final signals = generator.generate(vent: vent, space: space);

    expect(
      signals.any(
        (signal) =>
            signal.type == ResonanceSignalType.context &&
            signal.key == 'from_crash_out',
      ),
      isTrue,
    );
  });

  test('adds safety and privacy signals without changing Vent state', () {
    final vent = Vent(
      id: 'vent-4',
      content: 'I feel uncertain about my future.',
      spaceId: 'space-4',
      voiceMark: '□',
      createdAt: DateTime(2026, 1, 1),
      visibility: VentVisibility.private,
      safetyState: VentSafetyState.pending,
    );
    final space = Space(
      id: 'space-4',
      mode: SpaceMode.justListen,
      originatingVentId: 'vent-4',
      creatorVoiceMark: '□',
      createdAt: DateTime(2026, 1, 1),
    );

    final signals = generator.generate(vent: vent, space: space);

    expect(
      signals.any((signal) => signal.type == ResonanceSignalType.privacy),
      isTrue,
    );
    expect(
      signals.any((signal) => signal.type == ResonanceSignalType.safety),
      isTrue,
    );
    expect(vent.visibility, VentVisibility.private);
    expect(vent.safetyState, VentSafetyState.pending);
  });

  test('does not match keywords inside larger words', () {
    final vent = Vent(
      id: 'vent-5',
      content: 'My homework is finished, and I feel fine.',
      spaceId: 'space-5',
      voiceMark: '◇',
      createdAt: DateTime(2026, 1, 1),
    );
    final space = Space(
      id: 'space-5',
      mode: SpaceMode.justListen,
      originatingVentId: 'vent-5',
      creatorVoiceMark: '◇',
      createdAt: DateTime(2026, 1, 1),
    );

    final signals = generator.generate(vent: vent, space: space);

    expect(
      signals.any(
        (signal) =>
            signal.type == ResonanceSignalType.semantic &&
            signal.key == 'work',
      ),
      isFalse,
    );
  });
}
