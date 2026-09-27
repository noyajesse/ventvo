import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/features/crash_out/models/crash_out.dart';
import 'package:ventvo/features/crash_out/services/crash_out_opposite_experience_service.dart';
import 'package:ventvo/features/ventvo_voice/models/vent.dart';

void main() {
  const service = CrashOutOppositeExperienceService();

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
