import 'package:flutter_test/flutter_test.dart';
import 'package:ventvo/features/spaces/models/space.dart';
import 'package:ventvo/features/ventvo_voice/models/vent.dart';
import 'package:ventvo/systems/resonance/models/resonance_candidate.dart';
import 'package:ventvo/systems/resonance/models/resonance_signal.dart';
import 'package:ventvo/systems/resonance/repositories/local_resonance_repository.dart';
import 'package:ventvo/systems/resonance/services/resonance_engine.dart';
import 'package:ventvo/systems/resonance/services/vent_resonance_discovery_service.dart';

void main() {
  test('converts a discoverable Vent into a Resonance discovery request', () async {
    final repository = LocalResonanceRepository();
    await repository.saveCandidate(
      const ResonanceCandidate(
        id: 'vent-2',
        type: ResonanceCandidateType.vent,
        score: 0,
        signals: [
          ResonanceSignal(
            type: ResonanceSignalType.experiential,
            key: 'burnout',
            strength: 1,
          ),
        ],
      ),
    );

    final service = VentResonanceDiscoveryService(
      engine: LocalResonanceEngine(repository: repository),
    );
    final vent = Vent(
      id: 'vent-1',
      content: 'I am exhausted from everything at university.',
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

    final results = await service.discoverForVent(
      vent: vent,
      space: space,
      limit: 1,
    );

    expect(results, hasLength(1));
    expect(results.single.id, 'vent-2');
    expect(results.single.score, 1);
  });

  test('does not discover from a private or unsafe Vent', () async {
    final repository = LocalResonanceRepository();
    await repository.saveCandidate(
      const ResonanceCandidate(
        id: 'vent-2',
        type: ResonanceCandidateType.vent,
        score: 0,
        signals: [
          ResonanceSignal(
            type: ResonanceSignalType.experiential,
            key: 'burnout',
            strength: 1,
          ),
        ],
      ),
    );

    final service = VentResonanceDiscoveryService(
      engine: LocalResonanceEngine(repository: repository),
    );
    final vent = Vent(
      id: 'vent-1',
      content: 'I am exhausted.',
      spaceId: 'space-1',
      voiceMark: '◌',
      createdAt: DateTime(2026, 1, 1),
      visibility: VentVisibility.private,
    );
    final space = Space(
      id: 'space-1',
      mode: SpaceMode.justListen,
      originatingVentId: 'vent-1',
      creatorVoiceMark: '◌',
      createdAt: DateTime(2026, 1, 1),
    );

    final results = await service.discoverForVent(vent: vent, space: space);

    expect(results, isEmpty);
  });
}
