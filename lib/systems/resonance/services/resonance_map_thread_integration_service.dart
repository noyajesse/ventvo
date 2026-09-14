import '../models/resonance_connection.dart';
import '../models/resonance_map.dart';
import 'resonance_engine.dart';
import 'resonance_map_integrity_policy.dart';
import 'resonance_map_reconciliation_service.dart';
import 'resonance_map_thread_integration_policy.dart';

class ResonanceMapThreadIntegrationService {
  final ResonanceMapEngine engine;
  final ResonanceMapReconciliationService reconciliationService;
  final ResonanceMapThreadIntegrationPolicy integrationPolicy;
  final ResonanceMapIntegrityPolicy integrityPolicy;

  const ResonanceMapThreadIntegrationService({
    required this.engine,
    required this.reconciliationService,
    this.integrationPolicy = const ResonanceMapThreadIntegrationPolicy(),
    this.integrityPolicy = const ResonanceMapIntegrityPolicy(),
  });

  Future<ResonanceMap?> integrateThread({
    required String mapId,
    required String threadId,
    bool isPrivacyRestricted = false,
    bool isSafetyRestricted = false,
  }) async {
    if (mapId.trim().isEmpty) {
      throw ArgumentError.value(mapId, 'mapId', 'Map id cannot be empty.');
    }

    if (threadId.trim().isEmpty) {
      throw ArgumentError.value(
        threadId,
        'threadId',
        'Thread id cannot be empty.',
      );
    }

    final reconciled = await reconciliationService.reconcile(mapId);
    if (reconciled == null) return null;

    final map = reconciled.map;
    final thread = await engine.getThread(threadId);
    if (thread == null) return null;

    final decision = integrationPolicy.evaluate(
      map: map,
      thread: thread,
      isPrivacyRestricted: isPrivacyRestricted,
      isSafetyRestricted: isSafetyRestricted,
    );

    if (!decision.isEligible) return null;

    final mergedConnections = _mergeConnections(
      map.connections,
      decision.connections,
    );

    final updatedMap = map.copyWith(
      experienceIds: decision.experienceIds,
      threadIds: _addUnique(map.threadIds, thread.id),
      connections: mergedConnections,
    );

    final integrity = integrityPolicy.evaluate(updatedMap);
    if (integrity.isInvalid) return null;

    await engine.saveMap(updatedMap);
    return updatedMap;
  }

  List<String> _addUnique(List<String> existing, String value) {
    if (existing.contains(value)) return existing;
    return [...existing, value];
  }

  List<ResonanceConnection> _mergeConnections(
    List<ResonanceConnection> existing,
    List<ResonanceConnection> incoming,
  ) {
    final byId = <String, ResonanceConnection>{
      for (final connection in existing) connection.id: connection,
    };

    for (final connection in incoming) {
      byId[connection.id] = connection;
    }

    return byId.values.toList(growable: false);
  }
}
