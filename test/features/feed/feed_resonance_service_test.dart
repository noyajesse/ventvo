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
      Space(
        id: 'source-space',
        mode: SpaceMode.justListen,
        originatingVentId: 'source',
        creatorVoiceMark: '◌ Source',
        createdAt: DateTime(2026, 1, 1),
      ),
      Space(
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
        Space(
          id: 'source-space',
          mode: SpaceMode.justListen,
          originatingVentId: 'source',
          creatorVoiceMark: '◌ Source',
          createdAt: DateTime(2026, 1, 1),
        ),
        Space(
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

  test('orders results by strongest Resonance score', () async {
    final repository = LocalResonanceRepository();
    final discovery = VentResonanceDiscoveryService(
      engine: LocalResonanceEngine(repository: repository),
    );
    final service = FeedResonanceService(discoveryService: discovery);

    final source = Vent(
      id: 'source',
      content: 'I am burned out and overthinking university.',
      spaceId: 'source-space',
      voiceMark: '◌ Source',
      createdAt: DateTime(2026, 1, 1),
    );
    final strong = Vent(
      id: 'strong',
      content: 'University burnout has left me exhausted and overthinking everything.',
      spaceId: 'strong-space',
      voiceMark: '◇ Strong',
      createdAt: DateTime(2026, 1, 2),
    );
    final weaker = Vent(
      id: 'weaker',
      content: 'I am thinking about university.',
      spaceId: 'weaker-space',
      voiceMark: '◇ Weaker',
      createdAt: DateTime(2026, 1, 3),
    );

    final spaces = [
      for (final vent in [source, strong, weaker])
        Space(
          id: vent.spaceId,
          mode: SpaceMode.justListen,
          originatingVentId: vent.id,
          creatorVoiceMark: vent.voiceMark,
          createdAt: vent.createdAt,
        ),
    ];

    final results = await service.discover(
      sources: [source],
      spaces: spaces,
      candidateVents: [weaker, strong],
      limitPerSource: 2,
    );

    expect(results.map((vent) => vent.id).toList(), ['strong', 'weaker']);
  });

  test('excludes source experiences from discovery', () async {
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

    final results = await service.discover(
      sources: [source],
      spaces: [
        Space(
          id: 'source-space',
          mode: SpaceMode.justListen,
          originatingVentId: 'source',
          creatorVoiceMark: '◌ Source',
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
      candidateVents: [source],
    );

    expect(results, isEmpty);
  });

  test('deduplicates a candidate discovered from multiple sources', () async {
    final repository = LocalResonanceRepository();
    final discovery = VentResonanceDiscoveryService(
      engine: LocalResonanceEngine(repository: repository),
    );
    final service = FeedResonanceService(discoveryService: discovery);

    final sourceA = Vent(
      id: 'source-a',
      content: 'I am burned out from university.',
      spaceId: 'space-a',
      voiceMark: '◌ A',
      createdAt: DateTime(2026, 1, 1),
    );
    final sourceB = Vent(
      id: 'source-b',
      content: 'University has been exhausting me.',
      spaceId: 'space-b',
      voiceMark: '◌ B',
      createdAt: DateTime(2026, 1, 2),
    );
    final candidate = Vent(
      id: 'candidate',
      content: 'I feel completely burned out from university too.',
      spaceId: 'candidate-space',
      voiceMark: '◇ Candidate',
      createdAt: DateTime(2026, 1, 3),
    );

    final spaces = [
      for (final vent in [sourceA, sourceB, candidate])
        Space(
          id: vent.spaceId,
          mode: SpaceMode.justListen,
          originatingVentId: vent.id,
          creatorVoiceMark: vent.voiceMark,
          createdAt: vent.createdAt,
        ),
    ];

    final results = await service.discover(
      sources: [sourceA, sourceB],
      spaces: spaces,
      candidateVents: [candidate],
      limitPerSource: 1,
    );

    expect(results.map((vent) => vent.id).toList(), ['candidate']);
  });
}
