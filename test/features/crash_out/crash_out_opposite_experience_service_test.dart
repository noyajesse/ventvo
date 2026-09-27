import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/features/crash_out/models/crash_out.dart';
import 'package:ventvo/features/crash_out/models/experience_representation.dart';
import 'package:ventvo/features/crash_out/services/crash_out_experience_interpreter.dart';
import 'package:ventvo/features/crash_out/services/crash_out_opposite_experience_service.dart';
import 'package:ventvo/features/ventvo_voice/models/vent.dart';

void main() {
  const interpreter = CrashOutExperienceInterpreter();
  const service = CrashOutOppositeExperienceService(interpreter: interpreter);

  Vent vent(String id, String content) => Vent(
        id: id,
        content: content,
        spaceId: 'space-$id',
        voiceMark: 'Voice $id',
        createdAt: DateTime(2026, 1, 1),
      );

  CrashOut crashOut(String text) => CrashOut(
        id: 'crash-1',
        textContent: text,
        type: CrashOutType.text,
        createdAt: DateTime(2026, 1, 1),
      );

  test('finds the opposite side of a human tension', () {
    final match = service.find(
      crashOut: crashOut('I wish someone would check on me.'),
      experiences: [
        vent('same', 'I wish someone would notice me too.'),
        vent('opposite', 'Please stop checking on me. I just want space.'),
      ],
    );

    expect(match?.experience.id, 'opposite');
  });

  test('does not treat similar experiences as an opposite match', () {
    final match = service.find(
      crashOut: crashOut('I feel invisible. Nobody notices me.'),
      experiences: [
        vent('similar', 'I feel unseen and nobody notices me.'),
      ],
    );

    expect(match, isNull);
  });

  test('matches dependence with independence', () {
    final match = service.find(
      crashOut: crashOut(
        'I am tired of doing everything myself. I need someone to help.',
      ),
      experiences: [
        vent(
          'independent',
          'I do not need anyone. I want to handle everything myself.',
        ),
      ],
    );

    expect(match?.experience.id, 'independent');
  });

  test('does not treat literal antonyms as meaningful opposition', () {
    final match = service.find(
      crashOut: crashOut('I feel sad about what happened.'),
      experiences: [
        vent('literal-antonym', 'I feel happy about what happened.'),
      ],
    );

    expect(match, isNull);
  });

  test('does not force a match from shared context alone', () {
    final match = service.find(
      crashOut: crashOut('My friends have been distant lately.'),
      experiences: [
        vent(
          'same-topic',
          'My friends are always around me and I enjoy that.',
        ),
      ],
    );

    expect(match, isNull);
  });

  test('interpreter can extract multiple experience atoms', () {
    final result = interpreter.interpret(
      crashOut(
        'Nobody notices me, and I am tired of doing everything myself.',
      ),
    );

    expect(result.atoms.length, greaterThanOrEqualTo(2));
    expect(result.isMeaningful, isTrue);
  });

  test('interprets a human tension with direction', () {
    final result = interpreter.interpret(
      crashOut('I wish someone would check on me.'),
    );

    expect(
      result.atoms.any(
        (atom) =>
            atom.tension == HumanTension.attention &&
            atom.direction == ExperienceDirection.toward,
      ),
      isTrue,
    );
  });

  test('ignores private or unsafe experiences', () {
    final privateVent = vent('private', 'Please leave me alone.');
    final unsafeVent = vent('unsafe', 'Please leave me alone.').copyWith(
      safetyState: VentSafetyState.restricted,
    );
    final match = service.find(
      crashOut: crashOut('I wish someone would check on me.'),
      experiences: [privateVent.copyWith(visibility: VentVisibility.private), unsafeVent],
    );

    expect(match, isNull);
  });
}
