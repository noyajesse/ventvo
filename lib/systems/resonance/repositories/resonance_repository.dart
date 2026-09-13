import '../models/resonance_candidate.dart';
import '../models/resonance_connection.dart';
import '../models/resonance_query.dart';
import '../models/resonance_thread.dart';

/// Storage/discovery boundary for core Resonance capabilities.
///
/// Feed, Space, Crash Out, Threads, and connection features depend on this
/// contract rather than on a concrete storage implementation or matching
/// algorithm. Map persistence lives behind [ResonanceMapRepository] so core
/// test doubles do not need to implement Map operations.
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
