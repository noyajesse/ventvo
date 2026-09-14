import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/features/spaces/models/echo_note.dart';
import 'package:ventvo/systems/resonance/models/resonance_signal.dart';
import 'package:ventvo/systems/resonance/services/echo_note_resonance_signal_generator.dart';

void main() {
  const generator = EchoNoteResonanceSignalGenerator();

  EchoNote note(String content) {
    return EchoNote(
      id: 'note-1',
      echoId: 'echo-1',
      spaceId: 'space-1',
      ventId: 'vent-1',
      voiceMark: '◇',
      content: content,
      createdAt: DateTime(2026, 1, 1),
    );
  }

  ResonanceSignal? find(
    List<ResonanceSignal> signals,
    ResonanceSignalType type,
    String key,
  ) {
    for (final signal in signals) {
      if (signal.type == type && signal.key == key) return signal;
    }
    return null;
  }

  test('every Echo Note produces an Echo Note relationship signal', () {
    final signals = generator.generate(note: note('A small reflection.'));

    expect(
      find(signals, ResonanceSignalType.relationship, 'echo_note'),
      isNotNull,
    );
  });

  test('detects shared experience without making the note a candidate', () {
    final signals = generator.generate(
      note: note('Me too. I went through this last year.'),
    );

    expect(
      find(signals, ResonanceSignalType.experiential, 'shared_experience'),
      isNotNull,
    );
    expect(signals.every((signal) => signal.key != 'echo_note_candidate'), isTrue);
  });

  test('detects personal reflection', () {
    final signals = generator.generate(
      note: note('This reminded me of something I went through.'),
    );

    expect(
      find(signals, ResonanceSignalType.experiential, 'personal_reflection'),
      isNotNull,
    );
  });

  test('detects understanding', () {
    final signals = generator.generate(
      note: note('I understand. I know how this feels.'),
    );

    expect(
      find(signals, ResonanceSignalType.experiential, 'understanding'),
      isNotNull,
    );
  });

  test('detects a different perspective without replacing the relationship signal', () {
    final signals = generator.generate(
      note: note('From my perspective, my experience was different.'),
    );

    expect(
      find(signals, ResonanceSignalType.experiential, 'different_perspective'),
      isNotNull,
    );
    expect(
      find(signals, ResonanceSignalType.relationship, 'echo_note'),
      isNotNull,
    );
  });
}
