import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/features/spaces/models/echo.dart';
import 'package:ventvo/systems/resonance/services/echo_resonance_experience_service.dart';

void main() {
  const service = EchoResonanceExperienceService();

  Echo echo(String id) {
    return Echo(
      id: id,
      spaceId: 'space-1',
      ventId: 'vent-1',
      voiceMark: '◇',
      content: 'A reflection.',
      createdAt: DateTime(2026, 1, 1),
    );
  }

  test('namespaces an Echo as a Resonance experience', () {
    expect(service.experienceIdFor(echo('echo-1')), 'echo:echo-1');
  });

  test('trims the Echo id before creating its internal identity', () {
    expect(service.experienceIdFor(echo(' echo-1 ')), 'echo:echo-1');
  });

  test('rejects a blank Echo id', () {
    expect(service.experienceIdFor(echo(' ')), isNull);
  });
}
