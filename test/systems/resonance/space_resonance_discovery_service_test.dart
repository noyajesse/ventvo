import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/features/spaces/models/space.dart';
import 'package:ventvo/features/ventvo_voice/models/vent.dart';
import 'package:ventvo/systems/resonance/models/resonance_candidate.dart';
import 'package:ventvo/systems/resonance/models/resonance_connection.dart';
import 'package:ventvo/systems/resonance/models/resonance_query.dart';
import 'package:ventvo/systems/resonance/services/resonance_engine.dart';
import 'package:ventvo/systems/resonance/services/space_resonance_discovery_service.dart';

void main() {
  test('builds a Vent discovery query from the Space context', () async {
    final engine = _RecordingEngine();
    final service = SpaceResonanceDiscoveryService(engine: engine);

    final originatingVent = Vent(
      id: 'vent_1',
      content: 'I feel alone at university and keep overthinking.',
      spaceId: 'space_1',
      voiceMark: '◇ Nera',
      createdAt: DateTime(2026, 1, 1),
    );

    final space = Space(
      id: 'space_1',
      mode: SpaceMode.openDiscussion,
      originatingVentId: originatingVent.id,
      creatorVoiceMark: originatingVent.voiceMark,
      createdAt: DateTime(2026, 1, 1),
      ventIds: const ['vent_1', 'vent_2'],
    );

    await service.discoverRelatedVents(
      space: space,
      originatingVent: originatingVent,
      limit: 5,
      excludedIds: const {'vent_3'},
    );

    expect(engine.lastQuery, isNotNull);
    expect(engine.lastQuery!.sourceId, 'space_1');
    expect(engine.lastQuery!.sourceType, ResonanceCandidateType.vent);
    expect(engine.lastQuery!.limit, 5);
    expect(
      engine.lastQuery!.excludedIds,
      containsAll(<String>['vent_1', 'vent_2', 'vent_3']),
    );
    expect(
      engine.lastQuery!.signals.any(
        (signal) => signal.key == 'open_discussion',
      ),
      isTrue,
    );
  });

  test('does not discover from a non-discoverable originating Vent', () async {
    final engine = _RecordingEngine();
    final service = SpaceResonanceDiscoveryService(engine: engine);

    final vent = Vent(
      id: 'private_vent',
      content: 'This stays private.',
      spaceId: 'space_1',
      voiceMark: '◇ Nera',
      createdAt: DateTime(2026, 1, 1),
      visibility: VentVisibility.private,
    );

    final space = Space(
      id: 'space_1',
      mode: SpaceMode.justListen,
      originatingVentId: vent.id,
      creatorVoiceMark: vent.voiceMark,
      createdAt: DateTime(2026, 1, 1),
    );

    final result = await service.discoverRelatedVents(
      space: space,
      originatingVent: vent,
    );

    expect(result, isEmpty);
    expect(engine.lastQuery, isNull);
  });
}

class _RecordingEngine implements ResonanceEngine {
  ResonanceQuery? lastQuery;

  @override
  Future<void> indexCandidate(ResonanceCandidate candidate) async {}

  @override
  Future<List<ResonanceCandidate>> discover(
    ResonanceQuery query,
  ) async {
    lastQuery = query;
    return const [];
  }

  @override
  Future<ResonanceConnection> createConnection({
    required String sourceId,
    required String targetId,
    required ResonanceConnectionType type,
    required double strength,
  }) {
    throw UnimplementedError();
  }
}
