import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/features/crash_out/models/crash_out.dart';
import 'package:ventvo/features/crash_out/models/experience_representation.dart';
import 'package:ventvo/features/crash_out/services/crash_out_experience_interpreter.dart';
import 'package:ventvo/features/crash_out/services/crash_out_opposite_experience_service.dart';
import 'package:ventvo/features/ventvo_voice/models/vent.dart';

void main() {
  const interpreter = CrashOutExperienceInterpreter();
  const service = CrashOutOppositeExperienceService();

  CrashOut crashOut(String text, {String id = 'crash-1'}) {
    return CrashOut(
      id: id,
      textContent: text,
      type: CrashOutType.text,
      createdAt: DateTime(2026, 1, 1),
    );
  }

  Vent vent(
    String text, {
    String id = 'vent-1',
    String? originatingCrashOutId,
    VentVisibility visibility = VentVisibility.public,
    VentSafetyState safetyState = VentSafetyState.approved,
  }) {
    return Vent(
      id: id,
      content: text,
      spaceId: 'space-1',
      voiceMark: '○',
      createdAt: DateTime(2026, 1, 1),
      visibility: visibility,
      safetyState: safetyState,
      originatingCrashOutId: originatingCrashOutId,
    );
  }

  test('interpreter identifies opposite attention directions', () {
    final seeking = interpreter.interpretText(
      'I wish someone would check on me. I feel invisible.',
    );
    final resisting = interpreter.interpretText(
      'I hate when people keep checking on me. Leave me alone.',
    );

    expect(
      seeking.atoms.any(
        (atom) =>
            atom.tension == HumanTension.attention &&
            atom.direction == ExperienceDirection.toward,
      ),
      isTrue,
    );
    expect(
      resisting.atoms.any(
        (atom) =>
            atom.tension == HumanTension.attention &&
            atom.direction == ExperienceDirection.away,
      ),
      isTrue,
    );
  });

  test('service finds a meaningful opposite, not a topic-only match', () {
    final result = service.find(
      crashOut: crashOut(
        'I wish someone would check on me. I feel invisible.',
      ),
      experiences: [
        vent(
          'I wish people would notice me more. Nobody sees what I do.',
          id: 'similar',
        ),
        vent(
          'I hate when people keep checking on me. Sometimes I just want everyone to leave me alone.',
          id: 'opposite',
        ),
      ],
    );

    expect(result, isNotNull);
    expect(result!.experience.id, 'opposite');
    expect(result.sourceAtom.tension, HumanTension.attention);
    expect(result.candidateAtom.tension, HumanTension.attention);
    expect(result.sourceAtom.direction, isNot(result.candidateAtom.direction));
  });

  test('service returns no encounter when there is no meaningful opposition', () {
    final result = service.find(
      crashOut: crashOut('I wish someone would check on me. I feel invisible.'),
      experiences: [
        vent('I also wish someone would notice when I am struggling.'),
        vent('I have been thinking about school and exams lately.'),
      ],
    );

    expect(result, isNull);
  });

  test('private or unsafe candidates cannot surface', () {
    final result = service.find(
      crashOut: crashOut('I wish someone would check on me. I feel invisible.'),
      experiences: [
        vent(
          'I hate when people keep checking on me. Leave me alone.',
          id: 'private',
          visibility: VentVisibility.private,
        ),
        vent(
          'I hate when people keep checking on me. Leave me alone.',
          id: 'unsafe',
          safetyState: VentSafetyState.restricted,
        ),
      ],
    );

    expect(result, isNull);
  });

  test('a legacy Vent derived from the same Crash Out cannot surface', () {
    final result = service.find(
      crashOut(
        'I wish someone would check on me. I feel invisible.',
        id: 'crash-legacy',
      ),
      experiences: [
        vent(
          'I hate when people keep checking on me. Leave me alone.',
          originatingCrashOutId: 'crash-legacy',
        ),
      ],
    );

    expect(result, isNull);
  });
}
