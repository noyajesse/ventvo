import 'package:flutter_test/flutter_test.dart';
import 'package:ventvo/features/feed/services/feed_resonance_service.dart';
import 'package:ventvo/features/spaces/models/space.dart';
import 'package:ventvo/features/ventvo_voice/models/vent.dart';
import 'package:ventvo/systems/resonance/repositories/local_resonance_repository.dart';
import 'package:ventvo/systems/resonance/services/resonance_engine.dart';
import 'package:ventvo/systems/resonance/services/vent_resonance_discovery_service.dart';

void main() {
  test('returns Resonance-discovered candidate experiences', () async {
    final repository = LocalResonanceRepository();
    final discovery = VentResonanceDiscoveryService(
      engine: LocalResonanceEngine(repository: repository),
    );
    final service = FeedResonanceService(discoveryService: discovery);

    final source = Vent(
      id: 'source',
      content: 'I am completely burned out from university.',
      spaceId: 'source-space',
      voiceMark: '◌ Source',
      createdAt: DateTime(2026, 1, 1),
    );
    final candidate = Vent(
      id: 'candidate',
      content: 'I feel exhausted and burned out too.',
      spaceId: 'candidate-space',
      voiceMark: '◇ Other',
      createdAt: DateTime(2026, 1, 2),
    );
    final spaces = [
      const Space(
        id: 'source-space',
        mode: SpaceMode.justListen,
        originatingVentId: 'source',
        creatorVoiceMark: '◌ Source',
        createdAt: DateTime(2026, 1, 1),
      ),
      const Space(
        id: 'candidate-space',
        mode: SpaceMode.justListen,
        originatingVentId: 'candidate',
        creatorVoiceMark: '◇ Other',
        createdAt: DateTime(2026, 1, 2),
      ),
    ];

    final results = await service.discover(
      sources: [source],
      spaces: spaces,
      candidateVents: [candidate],
      limitPerSource: 1,
    );

    expect(results.map((vent) => vent.id), ['candidate']);
  });

  test('does not expose private candidate experiences', () async {
    final repository = LocalResonanceRepository();
    final discovery = VentResonanceDiscoveryService(
      engine: LocalResonanceEngine(repository: repository),
    );
    final service = FeedResonanceService(discoveryService: discovery);

    final source = Vent(
      id: 'source',
      content: 'I am burned out.',
      spaceId: 'source-space',
      voiceMark: '◌ Source',
      createdAt: DateTime(2026, 1, 1),
    );
    final privateCandidate = Vent(
      id: 'private',
      content: 'I am burned out too.',
      spaceId: 'private-space',
      voiceMark: '◇ Private',
      createdAt: DateTime(2026, 1, 2),
      visibility: VentVisibility.private,
    );

    final results = await service.discover(
      sources: [source],
      spaces: [
        const Space(
          id: 'source-space',
          mode: SpaceMode.justListen,
          originatingVentId: 'source',
          creatorVoiceMark: '◌ Source',
          createdAt: DateTime(2026, 1, 1),
        ),
        const Space(
          id: 'private-space',
          mode: SpaceMode.justListen,
          originatingVentId: 'private',
          creatorVoiceMark: '◇ Private',
          createdAt: DateTime(2026, 1, 2),
        ),
      ],
      candidateVents: [privateCandidate],
    );

    expect(results, isEmpty);
  });
}
