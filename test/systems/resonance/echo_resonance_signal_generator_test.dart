import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/features/spaces/models/echo.dart';
import 'package:ventvo/systems/resonance/models/resonance_signal.dart';
import 'package:ventvo/systems/resonance/services/echo_resonance_signal_generator.dart';

void main() {
  const generator = EchoResonanceSignalGenerator();

  test('adds response relationship signal to every Echo', () {
    final signals = generator.generate(
      Echo(
        id: 'echo-1',
        spaceId: 'space-1',
        ventId: 'vent-1',
        voiceMark: '◇',
        content: 'I understand. I hear you.',
        createdAt: DateTime(2026, 1, 1),
      ),
    );

    expect(
      signals.any(
        (signal) =>
            signal.type == ResonanceSignalType.relationship &&
            signal.key == 'echo_response',
      ),
      isTrue,
    );
  });

  test('detects shared experience and understanding signals', () {
    final signals = generator.generate(
      Echo(
        id: 'echo-2',
        spaceId: 'space-1',
        ventId: 'vent-1',
        voiceMark: '△',
        content: 'I went through this too. I understand how this feels.',
        createdAt: DateTime(2026, 1, 1),
      ),
    );

    expect(
      signals.any((signal) => signal.key == 'shared_experience'),
      isTrue,
    );
    expect(
      signals.any((signal) => signal.key == 'understanding'),
      isTrue,
    );
  });

  test('does not create duplicate signals for repeated phrases', () {
    final signals = generator.generate(
      Echo(
        id: 'echo-3',
        spaceId: 'space-1',
        ventId: 'vent-1',
        voiceMark: '○',
        content: 'I understand. I understand. I hear you.',
        createdAt: DateTime(2026, 1, 1),
      ),
    );

    final understanding =
        signals.where((signal) => signal.key == 'understanding').toList();

    expect(understanding, hasLength(1));
  });
}
