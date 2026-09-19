import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/systems/resonance/models/resonance_candidate.dart';
import 'package:ventvo/systems/resonance/models/resonance_connection.dart';
import 'package:ventvo/systems/resonance/models/resonance_map.dart';
import 'package:ventvo/systems/resonance/models/resonance_query.dart';
import 'package:ventvo/systems/resonance/models/resonance_thread.dart';
import 'package:ventvo/systems/resonance/services/resonance_engine.dart';
import 'package:ventvo/systems/resonance/services/resonance_map_reconciliation_service.dart';
import 'package:ventvo/systems/resonance/services/resonance_map_thread_integration_service.dart';

class FakeResonanceEngine implements ResonanceEngine, ResonanceMapEngine {
  final Map<String, ResonanceThread> threads = {};
  final Map<String, ResonanceMap> maps = {};
  final Map<String, List<ResonanceConnection>> connectionsByExperience = {};

  @override
  Future<void> indexCandidate(ResonanceCandidate candidate) async {}

  @override
  Future<List<ResonanceCandidate>> discover(ResonanceQuery query) async {
    return const [];
  }

  @override
  Future<ResonanceConnection> createConnection({
    required String sourceId,
    required String targetId,
    String? sourceVoiceId,
    String? targetVoiceId,
    required ResonanceConnectionType type,
    required double strength,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<ResonanceConnection?> getConnectionBetween(
    String sourceId,
    String targetId,
  ) async => null;

  @override
  Future<List<ResonanceConnection>> getConnectionsInvolving(String id) async {
    return connectionsByExperience[id] ?? const [];
  }

  @override
  Future<void> updateConnection(ResonanceConnection connection) async {}

  @override
  Future<void> saveThread(ResonanceThread thread) async {
    threads[thread.id] = thread;
  }

  @override
  Future<ResonanceThread?> getThread(String threadId) async {
    return threads[threadId];
  }

  @override
  Future<List<ResonanceThread>> getThreadsForExperience(
    String experienceId,
  ) async {
    return threads.values
        .where((thread) => thread.containsExperience(experienceId))
        .toList(growable: false);
  }

  @override
  Future<List<ResonanceThread>> getThreads() async {
    return threads.values.toList(growable: false);
  }

  @override
  Future<void> saveMap(ResonanceMap map) async {
    maps[map.id] = map;
  }

  @override
  Future<ResonanceMap?> getMap(String mapId) async => maps[mapId];

  @override
  Future<List<ResonanceMap>> getMapsForExperience(String experienceId) async {
    return maps.values
        .where((map) => map.containsExperience(experienceId))
        .toList(growable: false);
  }

  @override
  Future<List<ResonanceMap>> getMaps() async {
    return maps.values.toList(growable: false);
  }
}

final createdAt = DateTime(2026, 1, 1);

ResonanceConnection connection({
  required String id,
  required String sourceId,
  required String targetId,
  ResonanceConnectionState state = ResonanceConnectionState.active,
  ResonanceConnectionType type = ResonanceConnectionType.sharedExperience,
  double strength = 0.8,
}) {
  return ResonanceConnection(
    id: id,
    sourceId: sourceId,
    targetId: targetId,
    type: type,
    strength: strength,
    state: state,
    createdAt: createdAt,
  );
}

ResonanceMap map({List<ResonanceConnection> connections = const []}) {
  return ResonanceMap.create(
    id: 'map-1',
    experienceIds: const [
      'experience-1',
      'experience-2',
      'experience-3',
    ],
    connections: connections,
    createdAt: createdAt,
  );
}

ResonanceThread thread({
  String id = 'thread-1',
  List<String> experienceIds = const [
    'experience-2',
    'experience-4',
    'experience-5',
  ],
  List<ResonanceConnection> connections = const [],
}) {
  return ResonanceThread.create(
    id: id,
    originatingExperienceId: experienceIds.first,
    experienceIds: experienceIds,
    connections: connections,
    createdAt: createdAt,
  );
}

ResonanceMapThreadIntegrationService service(FakeResonanceEngine engine) {
  return ResonanceMapThreadIntegrationService(
    resonanceEngine: engine,
    mapEngine: engine,
    reconciliationService: ResonanceMapReconciliationService(engine: engine),
  );
}

void main() {
  test('integrates an active overlapping Thread into a Map', () async {
    final existingMapConnection = connection(
      id: 'map-connection',
      sourceId: 'experience-1',
      targetId: 'experience-2',
    );
    final threadConnection = connection(
      id: 'thread-connection',
      sourceId: 'experience-2',
      targetId: 'experience-4',
    );
    final engine = FakeResonanceEngine();
    engine.maps['map-1'] = map(connections: [existingMapConnection]);
    engine.connectionsByExperience['experience-1'] = [existingMapConnection];
    engine.threads['thread-1'] = thread(connections: [threadConnection]);

    final result = await service(engine).integrateThread(
      mapId: 'map-1',
      threadId: 'thread-1',
    );

    expect(result, isNotNull);
    expect(result!.threadIds, contains('thread-1'));
    expect(result.experienceIds, containsAll(['experience-4', 'experience-5']));
    expect(result.containsConnection('map-connection'), isTrue);
    expect(result.containsConnection('thread-connection'), isTrue);
    expect(engine.maps['map-1'], result);
  });

  test('rejects a Thread with no experience overlap', () async {
    final engine = FakeResonanceEngine();
    engine.maps['map-1'] = map();
    engine.threads['thread-1'] = thread(
      experienceIds: const ['experience-4', 'experience-5', 'experience-6'],
      connections: [
        connection(
          id: 'thread-connection',
          sourceId: 'experience-4',
          targetId: 'experience-5',
        ),
      ],
    );

    final result = await service(engine).integrateThread(
      mapId: 'map-1',
      threadId: 'thread-1',
    );

    expect(result, isNull);
    expect(engine.maps['map-1']!.threadIds, isEmpty);
  });

  test('rejects a dormant Thread', () async {
    final engine = FakeResonanceEngine();
    engine.maps['map-1'] = map();
    engine.threads['thread-1'] = thread(
      connections: [
        connection(
          id: 'thread-connection',
          sourceId: 'experience-2',
          targetId: 'experience-4',
          state: ResonanceConnectionState.closed,
        ),
      ],
    );

    final result = await service(engine).integrateThread(
      mapId: 'map-1',
      threadId: 'thread-1',
    );

    expect(result, isNull);
  });

  test('rejects integration when privacy is restricted', () async {
    final engine = FakeResonanceEngine();
    engine.maps['map-1'] = map();
    engine.threads['thread-1'] = thread(
      connections: [
        connection(
          id: 'thread-connection',
          sourceId: 'experience-2',
          targetId: 'experience-4',
        ),
      ],
    );

    final result = await service(engine).integrateThread(
      mapId: 'map-1',
      threadId: 'thread-1',
      isPrivacyRestricted: true,
    );

    expect(result, isNull);
  });

  test('integration is idempotent for the same Thread', () async {
    final threadConnection = connection(
      id: 'thread-connection',
      sourceId: 'experience-2',
      targetId: 'experience-4',
    );
    final engine = FakeResonanceEngine();
    engine.maps['map-1'] = map();
    engine.connectionsByExperience['experience-1'] = [];
    engine.threads['thread-1'] = thread(connections: [threadConnection]);

    final first = await service(engine).integrateThread(
      mapId: 'map-1',
      threadId: 'thread-1',
    );
    final second = await service(engine).integrateThread(
      mapId: 'map-1',
      threadId: 'thread-1',
    );

    expect(first, isNotNull);
    expect(second, isNotNull);
    expect(second!.threadIds.where((id) => id == 'thread-1'), hasLength(1));
    expect(
      second.connections.where((connection) => connection.id == 'thread-connection'),
      hasLength(1),
    );
  });

  test('returns null when the Map does not exist', () async {
    final engine = FakeResonanceEngine();
    engine.threads['thread-1'] = thread(
      connections: [
        connection(
          id: 'thread-connection',
          sourceId: 'experience-2',
          targetId: 'experience-4',
        ),
      ],
    );

    final result = await service(engine).integrateThread(
      mapId: 'missing-map',
      threadId: 'thread-1',
    );

    expect(result, isNull);
  });

  test('rejects blank Map and Thread ids', () async {
    final engine = FakeResonanceEngine();
    final integrationService = service(engine);

    expect(
      () => integrationService.integrateThread(
        mapId: '   ',
        threadId: 'thread-1',
      ),
      throwsArgumentError,
    );

    expect(
      () => integrationService.integrateThread(
        mapId: 'map-1',
        threadId: '   ',
      ),
      throwsArgumentError,
    );
  });
}
