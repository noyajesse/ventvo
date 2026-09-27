import 'package:flutter_test/flutter_test.dart';

import '../lib/features/crash_out/models/crash_out.dart';
import '../lib/features/crash_out/services/crash_out_experience_interpreter.dart';
import '../lib/features/crash_out/services/crash_out_opposite_experience_service.dart';
import '../lib/features/ventvo_voice/models/vent.dart';

void main() {
  const interpreter = CrashOutExperienceInterpreter();
  const service = CrashOutOppositeExperienceService(
    interpreter: interpreter,
  );

  Vent vent(String id, String content) {
    return Vent(
      id: id,
      content: content,
      spaceId: 'general',
      voiceMark: 'anonymous',
      createdAt: DateTime(2026, 9, 27),
    );
  }

  CrashOut crashOut(String text) {
    return CrashOut(
      id: 'crash',
      textContent: text,
      type: CrashOutType.text,
      createdAt: DateTime(2026, 9, 27),
    );
  }

  group('Crash Out experience interpretation', () {
    test('recognizes wanting care as a direction toward attention', () {
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

    test('can extract multiple experience atoms from one Crash Out', () {
      final result = interpreter.interpret(
        crashOut(
          'Nobody notices me, and I am tired of doing everything myself.',
        ),
      );

      expect(result.atoms.length, greaterThanOrEqualTo(2));
    });
  });

  group('Crash Out opposition', () {
    test('matches care with space on the same human tension', () {
      final result = service.find(
        crashOut: crashOut('I wish someone would check on me.'),
        experiences: [
          vent('space', 'I hate when people keep checking on me.'),
        ],
      );

      expect(result, isNotNull);
      expect(result!.experience.id, 'space');
      expect(result.score, greaterThan(0.55));
    });

    test('matches dependence with independence', () {
      final result = service.find(
        crashOut: crashOut(
          'I am tired of doing everything myself. I need someone to help.',
        ),
        experiences: [
          vent('independent', 'I do not need anyone. I want to handle everything myself.'),
        ],
      );

      expect(result, isNotNull);
      expect(result!.experience.id, 'independent');
    });

    test('does not match the same side of a tension', () {
      final result = service.find(
        crashOut: crashOut('I wish someone would check on me.'),
        experiences: [
          vent('same-side', 'I wish someone would notice when I am struggling.'),
        ],
      );

      expect(result, isNull);
    });

    test('does not treat literal antonyms as meaningful opposition', () {
      final result = service.find(
        crashOut: crashOut('I feel sad about what happened.'),
        experiences: [
          vent('literal-antonym', 'I feel happy about what happened.'),
        ],
      );

      expect(result, isNull);
    });

    test('does not force a match from shared context alone', () {
      final result = service.find(
        crashOut: crashOut('My friends have been distant lately.'),
        experiences: [
          vent('same-topic', 'My friends are always around me and I enjoy that.'),
        ],
      );

      expect(result, isNull);
    });

    test('ignores undiscoverable experiences', () {
      final result = service.find(
        crashOut: crashOut('I wish someone would check on me.'),
        experiences: [
          vent('private', 'I want everyone to leave me alone.').copyWith(
            visibility: VentVisibility.private,
          ),
        ],
      );

      expect(result, isNull);
    });
  });
}
