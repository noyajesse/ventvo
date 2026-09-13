import '../models/resonance_candidate.dart';
import '../models/resonance_connection.dart';
import '../models/resonance_query.dart';
import '../models/resonance_thread.dart';

/// Storage/discovery boundary for Resonance.
///
/// Feed, Space, and Crash Out should depend on this contract rather than on a
/// concrete storage implementation or matching algorithm.
abstract class ResonanceRepository {
  Future<void> saveCandidate(ResonanceCandidate candidate);

  Future<List<ResonanceCandidate>> findCandidates(ResonanceQuery query);

  Future<void> saveConnection(ResonanceConnection connection);

  Future<void> updateConnection(ResonanceConnection connection);

  Future<ResonanceConnection?> getConnectionBetween(
    String sourceId,
    String targetId,
  );

  Future<List<ResonanceConnection>> getConnectionsFor(String sourceId);

  Future<List<ResonanceConnection>> getConnectionsInvolving(String id);

  Future<void> saveThread(ResonanceThread thread);

  Future<ResonanceThread?> getThread(String threadId);

  Future<List<ResonanceThread>> getThreadsForExperience(String experienceId);

  Future<List<ResonanceThread>> getThreads();
}
