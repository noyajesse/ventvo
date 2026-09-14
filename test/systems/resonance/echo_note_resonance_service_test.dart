import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/features/spaces/models/echo_note.dart';
import 'package:ventvo/systems/resonance/models/resonance_signal.dart';
import 'package:ventvo/systems/resonance/services/echo_note_resonance_service.dart';

void main() {
  const service = EchoNoteResonanceService();

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

  test('composes Echo Note signals into the shared ResonanceProfile', () {
    final profile = service.profileFor(
      note('Me too. This reminded me of what I went through.'),
    );

    expect(profile.signals, isNotEmpty);
    expect(profile.relationships, hasLength(1));
    expect(profile.relationships.single.key, 'echo_note');
    expect(
      profile.experiences.map((signal) => signal.key),
      containsAll(<String>['shared_experience', 'personal_reflection']),
    );
  });

  test('keeps Echo Note relationship separate from experiential signals', () {
    final profile = service.profileFor(note('A small reflection.'));

    expect(
      profile.relationships.every(
        (signal) => signal.type == ResonanceSignalType.relationship,
      ),
      isTrue,
    );
    expect(profile.experiences, isEmpty);
  });

  test('does not create privacy or safety restrictions by default', () {
    final profile = service.profileFor(
      note('I understand and I went through this too.'),
    );

    expect(profile.isPrivate, isFalse);
    expect(profile.isSafetyRestricted, isFalse);
  });
}
