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

  test('recognizes additional human-experience patterns', () {
    final vent = Vent(
      id: 'vent-2',
      content: 'I keep comparing myself because everyone is ahead. I feel stuck.',
      spaceId: 'space-2',
      voiceMark: '◇',
      createdAt: DateTime(2026, 1, 1),
    );
    final space = Space(
      id: 'space-2',
      mode: SpaceMode.justListen,
      originatingVentId: 'vent-2',
      creatorVoiceMark: '◇',
      createdAt: DateTime(2026, 1, 1),
    );

    final signals = generator.generate(vent: vent, space: space);

    expect(
      signals.any((signal) => signal.key == 'comparison'),
      isTrue,
    );
    expect(
      signals.any((signal) => signal.key == 'being_stuck'),
      isTrue,
    );
  });

  test('uses Open Discussion as the Vent intent signal', () {
    final vent = Vent(
      id: 'vent-3',
      content: 'I need to talk about starting over.',
      spaceId: 'space-3',
      voiceMark: '◇',
      createdAt: DateTime(2026, 1, 1),
    );
    final space = Space(
      id: 'space-3',
      mode: SpaceMode.openDiscussion,
      originatingVentId: 'vent-3',
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
      id: 'vent-4',
      content: 'I need to let this out.',
      spaceId: 'space-4',
      voiceMark: '△',
      createdAt: DateTime(2026, 1, 1),
      originatingCrashOutId: 'crash-1',
    );
    final space = Space(
      id: 'space-4',
      mode: SpaceMode.justListen,
      originatingVentId: 'vent-4',
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
      id: 'vent-5',
      content: 'I feel uncertain about my future.',
      spaceId: 'space-5',
      voiceMark: '□',
      createdAt: DateTime(2026, 1, 1),
      visibility: VentVisibility.private,
      safetyState: VentSafetyState.pending,
    );
    final space = Space(
      id: 'space-5',
      mode: SpaceMode.justListen,
      originatingVentId: 'vent-5',
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
      id: 'vent-6',
      content: 'My homework is finished, and I feel fine.',
      spaceId: 'space-6',
      voiceMark: '◇',
      createdAt: DateTime(2026, 1, 1),
    );
    final space = Space(
      id: 'space-6',
      mode: SpaceMode.justListen,
      originatingVentId: 'vent-6',
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

  test('does not treat an explicitly negated experience as present', () {
    final vent = Vent(
      id: 'vent-7',
      content: "I don't feel alone anymore. I don't feel stuck either.",
      spaceId: 'space-7',
      voiceMark: '◇',
      createdAt: DateTime(2026, 1, 1),
    );
    final space = Space(
      id: 'space-7',
      mode: SpaceMode.justListen,
      originatingVentId: 'vent-7',
      creatorVoiceMark: '◇',
      createdAt: DateTime(2026, 1, 1),
    );

    final signals = generator.generate(vent: vent, space: space);

    expect(
      signals.any((signal) => signal.key == 'feeling_alone'),
      isFalse,
    );
    expect(
      signals.any((signal) => signal.key == 'being_stuck'),
      isFalse,
    );
  });

  test('keeps a real experience when another clause is negated', () {
    final vent = Vent(
      id: 'vent-8',
      content: "I don't want advice because I feel alone right now.",
      spaceId: 'space-8',
      voiceMark: '◇',
      createdAt: DateTime(2026, 1, 1),
    );
    final space = Space(
      id: 'space-8',
      mode: SpaceMode.openDiscussion,
      originatingVentId: 'vent-8',
      creatorVoiceMark: '◇',
      createdAt: DateTime(2026, 1, 1),
    );

    final signals = generator.generate(vent: vent, space: space);

    expect(
      signals.any((signal) => signal.key == 'feeling_alone'),
      isTrue,
    );
  });

  test('recognizes a positive experience after a negated earlier clause', () {
    final vent = Vent(
      id: 'vent-9',
      content: "I don't feel alone anymore, but I still feel stuck.",
      spaceId: 'space-9',
      voiceMark: '◇',
      createdAt: DateTime(2026, 1, 1),
    );
    final space = Space(
      id: 'space-9',
      mode: SpaceMode.justListen,
      originatingVentId: 'vent-9',
      creatorVoiceMark: '◇',
      createdAt: DateTime(2026, 1, 1),
    );

    final signals = generator.generate(vent: vent, space: space);

    expect(
      signals.any((signal) => signal.key == 'feeling_alone'),
      isFalse,
    );
    expect(
      signals.any((signal) => signal.key == 'being_stuck'),
      isTrue,
    );
  });

  test('gives richer phrases a higher signal strength', () {
    final simpleVent = Vent(
      id: 'vent-10',
      content: 'I feel alone.',
      spaceId: 'space-10',
      voiceMark: '◇',
      createdAt: DateTime(2026, 1, 1),
    );
    final richVent = Vent(
      id: 'vent-11',
      content: 'No one understands what I am going through.',
      spaceId: 'space-11',
      voiceMark: '◇',
      createdAt: DateTime(2026, 1, 1),
    );
    final simpleSpace = Space(
      id: 'space-10',
      mode: SpaceMode.justListen,
      originatingVentId: 'vent-10',
      creatorVoiceMark: '◇',
      createdAt: DateTime(2026, 1, 1),
    );
    final richSpace = Space(
      id: 'space-11',
      mode: SpaceMode.justListen,
      originatingVentId: 'vent-11',
      creatorVoiceMark: '◇',
      createdAt: DateTime(2026, 1, 1),
    );

    final simpleSignal = generator
        .generate(vent: simpleVent, space: simpleSpace)
        .firstWhere((signal) => signal.key == 'feeling_alone');
    final richSignal = generator
        .generate(vent: richVent, space: richSpace)
        .firstWhere((signal) => signal.key == 'feeling_alone');

    expect(richSignal.strength, greaterThan(simpleSignal.strength));
  });

  test('extracts connection difficulty as a distinct experience', () {
    final vent = Vent(
      id: 'vent-12',
      content: "I can't connect with anyone at university.",
      spaceId: 'space-12',
      voiceMark: '◇',
      createdAt: DateTime(2026, 1, 1),
    );
    final space = Space(
      id: 'space-12',
      mode: SpaceMode.justListen,
      originatingVentId: 'vent-12',
      creatorVoiceMark: '◇',
      createdAt: DateTime(2026, 1, 1),
    );

    final signals = generator.generate(vent: vent, space: space);
    final connectionSignal = signals.firstWhere(
      (signal) => signal.key == 'connection_difficulty',
    );

    expect(connectionSignal.type, ResonanceSignalType.experiential);
    expect(connectionSignal.strength, greaterThan(0.95));
    expect(
      signals.any((signal) => signal.key == 'university'),
      isTrue,
    );
  });
}
