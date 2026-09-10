import '../models/resonance_candidate.dart';
import '../models/resonance_connection.dart';
import '../models/resonance_query.dart';

/// Storage/discovery boundary for Resonance.
///
/// Feed, Space, and Crash Out should depend on this contract rather than on a
/// concrete storage implementation or matching algorithm.
abstract class ResonanceRepository {
  Future<List<ResonanceCandidate>> findCandidates(ResonanceQuery query);

  Future<void> saveConnection(ResonanceConnection connection);

  Future<List<ResonanceConnection>> getConnectionsFor(String sourceId);
}
