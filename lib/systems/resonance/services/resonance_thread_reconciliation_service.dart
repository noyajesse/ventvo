import '../models/resonance_connection.dart';
import '../models/resonance_thread.dart';
import 'resonance_engine.dart';
import 'resonance_thread_integrity_policy.dart';

class ResonanceThreadReconciliationResult {
  final ResonanceThread thread;
  final ResonanceThreadIntegrityDecision decision;

  const ResonanceThreadReconciliationResult({
    required this.thread,
    required this.decision,
  });
}

/// Reconciles a persisted Thread with the latest connection state.
///
/// A Thread keeps its historical connections. When a connection changes
/// state, reconciliation refreshes the connection objects from Resonance,
/// preserves historical links that are no longer returned by storage, and
/// derives current discoverability through the integrity policy.
class ResonanceThreadReconciliationService {
  final ResonanceEngine engine;
  final ResonanceThreadIntegrityPolicy integrityPolicy;

  const ResonanceThreadReconciliationService({
    required this.engine,
    this.integrityPolicy = const ResonanceThreadIntegrityPolicy(),
  });

  Future<ResonanceThreadReconciliationResult?> reconcile(String threadId) async {
    if (threadId.trim().isEmpty) {
      throw ArgumentError.value(
        threadId,
        'threadId',
        'Thread id cannot be empty.',
      );
    }

    final existingThread = await engine.getThread(threadId);
    if (existingThread == null) {
      return null;
    }

    final latestConnections = await _getLatestConnections(existingThread);
    final reconciledThread = existingThread.copyWith(
      connections: _mergeConnections(
        historical: existingThread.connections,
        latest: latestConnections,
      ),
    );

    final decision = integrityPolicy.evaluate(reconciledThread);
    await engine.saveThread(reconciledThread);

    return ResonanceThreadReconciliationResult(
      thread: reconciledThread,
      decision: decision,
    );
  }

  Future<List<ResonanceConnection>> _getLatestConnections(
    ResonanceThread thread,
  ) async {
    final connectionsById = <String, ResonanceConnection>{};

    for (final experienceId in thread.experienceIds) {
      final connections = await engine.getConnectionsInvolving(experienceId);
      for (final connection in connections) {
        if (thread.containsExperience(connection.sourceId) &&
            thread.containsExperience(connection.targetId)) {
          connectionsById[connection.id] = connection;
        }
      }
    }

    return connectionsById.values.toList(growable: false);
  }

  List<ResonanceConnection> _mergeConnections({
    required List<ResonanceConnection> historical,
    required List<ResonanceConnection> latest,
  }) {
    final latestById = {
      for (final connection in latest) connection.id: connection,
    };

    final merged = <ResonanceConnection>[];
    final seenIds = <String>{};

    for (final connection in historical) {
      final refreshed = latestById[connection.id] ?? connection;
      merged.add(refreshed);
      seenIds.add(refreshed.id);
    }

    for (final connection in latest) {
      if (seenIds.add(connection.id)) {
        merged.add(connection);
      }
    }

    return List.unmodifiable(merged);
  }
}
