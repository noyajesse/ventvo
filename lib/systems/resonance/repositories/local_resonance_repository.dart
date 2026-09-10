import '../models/resonance_candidate.dart';
import '../models/resonance_connection.dart';
import '../models/resonance_query.dart';
import '../models/resonance_signal.dart';
import 'resonance_repository.dart';

/// In-memory Resonance repository for the local prototype.
///
/// It deliberately sits behind [ResonanceRepository] so the engine and product
/// features do not depend on local storage. A backend repository can replace it
/// later without changing the Resonance engine contract.
class LocalResonanceRepository implements ResonanceRepository {
  final Map<String, ResonanceCandidate> _candidates = {};
  final List<ResonanceConnection> _connections = [];

  void upsertCandidate(ResonanceCandidate candidate) {
    _candidates[candidate.id] = candidate;
  }

  void removeCandidate(String candidateId) {
    _candidates.remove(candidateId);
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
  Future<List<ResonanceConnection>> getConnectionsFor(String sourceId) async {
    return _connections
        .where((connection) => connection.sourceId == sourceId)
        .toList(growable: false);
  }

  bool _isDiscoverable(ResonanceCandidate candidate) {
    return !candidate.signals.any(
      (signal) =>
          signal.type == ResonanceSignalType.privacy ||
          signal.type == ResonanceSignalType.safety,
    );
  }
}
