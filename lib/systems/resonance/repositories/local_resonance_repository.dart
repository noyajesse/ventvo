import '../models/resonance_candidate.dart';
import '../models/resonance_connection.dart';
import '../models/resonance_query.dart';
import '../models/resonance_signal.dart';
import '../models/resonance_thread.dart';
import 'resonance_repository.dart';

/// In-memory Resonance repository for the local prototype.
///
/// It deliberately sits behind [ResonanceRepository] so the engine and product
/// features do not depend on local storage. A backend repository can replace it
/// later without changing the Resonance engine contract.
class LocalResonanceRepository implements ResonanceRepository {
  final Map<String, ResonanceCandidate> _candidates = {};
  final List<ResonanceConnection> _connections = [];
  final Map<String, ResonanceThread> _threads = {};

  @override
  Future<void> saveCandidate(ResonanceCandidate candidate) async {
    _candidates[candidate.id] = candidate;
  }

  @override
  Future<List<ResonanceCandidate>> findCandidates(ResonanceQuery query) async {
    return _candidates.values
        .where((candidate) => candidate.type == query.sourceType)
        .where(_isDiscoverable)
        .toList(growable: false);
  }

  @override
  Future<void> saveConnection(ResonanceConnection connection) async {
    _connections.removeWhere(
      (item) =>
          item.sourceId == connection.sourceId &&
          item.targetId == connection.targetId,
    );
    _connections.add(connection);
  }

  @override
  Future<void> updateConnection(ResonanceConnection connection) async {
    final index = _connections.indexWhere(
      (item) => item.id == connection.id,
    );
    if (index == -1) return;
    _connections[index] = connection;
  }

  @override
  Future<ResonanceConnection?> getConnectionBetween(
    String sourceId,
    String targetId,
  ) async {
    for (final connection in _connections) {
      if (connection.sourceId == sourceId &&
          connection.targetId == targetId) {
        return connection;
      }
    }
    return null;
  }

  @override
  Future<List<ResonanceConnection>> getConnectionsFor(String sourceId) async {
    return _connections
        .where((connection) => connection.sourceId == sourceId)
        .toList(growable: false);
  }

  @override
  Future<List<ResonanceConnection>> getConnectionsInvolving(String id) async {
    return _connections
        .where(
          (connection) =>
              connection.sourceId == id || connection.targetId == id,
        )
        .toList(growable: false);
  }

  @override
  Future<void> saveThread(ResonanceThread thread) async {
    _threads[thread.id] = thread;
  }

  @override
  Future<ResonanceThread?> getThread(String threadId) async {
    return _threads[threadId];
  }

  @override
  Future<List<ResonanceThread>> getThreadsForExperience(
    String experienceId,
  ) async {
    return _threads.values
        .where((thread) => thread.containsExperience(experienceId))
        .toList(growable: false);
  }

  @override
  Future<List<ResonanceThread>> getThreads() async {
    return _threads.values.toList(growable: false);
  }

  bool _isDiscoverable(ResonanceCandidate candidate) {
    return !candidate.signals.any(
      (signal) =>
          signal.type == ResonanceSignalType.privacy ||
          signal.type == ResonanceSignalType.safety,
    );
  }
}
