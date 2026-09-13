import '../algorithms/deterministic_resonance_scorer.dart';
import '../models/resonance_candidate.dart';
import '../models/resonance_connection.dart';
import '../models/resonance_map.dart';
import '../models/resonance_query.dart';
import '../models/resonance_thread.dart';
import '../repositories/resonance_map_repository.dart';
import '../repositories/resonance_repository.dart';
import 'resonance_signal_composer.dart';

/// Shared Resonance service consumed by product features.
abstract class ResonanceEngine {
  Future<void> indexCandidate(ResonanceCandidate candidate);

  Future<List<ResonanceCandidate>> discover(ResonanceQuery query);

  Future<ResonanceConnection> createConnection({
    required String sourceId,
    required String targetId,
    required ResonanceConnectionType type,
    required double strength,
  });

  Future<ResonanceConnection?> getConnectionBetween(
    String sourceId,
    String targetId,
  );

  Future<List<ResonanceConnection>> getConnectionsInvolving(String id);

  Future<void> updateConnection(ResonanceConnection connection);

  Future<void> saveThread(ResonanceThread thread);

  Future<ResonanceThread?> getThread(String threadId);

  Future<List<ResonanceThread>> getThreadsForExperience(String experienceId);

  Future<List<ResonanceThread>> getThreads();
}

/// Map-specific engine capability.
///
/// Kept separate from [ResonanceEngine] so existing Resonance consumers and
/// their test doubles do not need to implement Map operations they never use.
abstract class ResonanceMapEngine {
  Future<void> saveMap(ResonanceMap map);

  Future<ResonanceMap?> getMap(String mapId);

  Future<List<ResonanceMap>> getMapsForExperience(String experienceId);

  Future<List<ResonanceMap>> getMaps();
}

class LocalResonanceEngine implements ResonanceEngine, ResonanceMapEngine {
  final ResonanceRepository repository;
  final ResonanceMapRepository? mapRepository;
  final DeterministicResonanceScorer scorer;
  final ResonanceSignalComposer composer;

  LocalResonanceEngine({
    required this.repository,
    ResonanceMapRepository? mapRepository,
    this.scorer = const DeterministicResonanceScorer(),
    this.composer = const ResonanceSignalComposer(),
  }) : mapRepository = mapRepository ??
            (repository is ResonanceMapRepository
                ? repository as ResonanceMapRepository
                : null);

  ResonanceMapRepository _requireMapRepository() {
    final repository = mapRepository;
    if (repository == null) {
      throw StateError('The configured Resonance repository does not support Maps.');
    }
    return repository;
  }

  @override
  Future<void> indexCandidate(ResonanceCandidate candidate) {
    final profile = candidate.profile ?? composer.compose(candidate.signals);
    return repository.saveCandidate(
      candidate.copyWith(profile: profile),
    );
  }

  @override
  Future<List<ResonanceCandidate>> discover(ResonanceQuery query) async {
    final candidates = await repository.findCandidates(query);
    final sourceProfile = composer.compose(query.signals);

    final ranked = candidates
        .where(
          (candidate) =>
              candidate.id != query.sourceId &&
              !query.excludedIds.contains(candidate.id),
        )
        .map((candidate) {
          final candidateProfile =
              candidate.profile ?? composer.compose(candidate.signals);
          return candidate.copyWith(
            score: scorer.scoreProfiles(
              source: sourceProfile,
              candidateProfile: candidateProfile,
              candidate: candidate,
            ),
            profile: candidateProfile,
          );
        })
        .where((candidate) => candidate.score > 0)
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    return ranked.take(query.limit).toList(growable: false);
  }

  @override
  Future<ResonanceConnection> createConnection({
    required String sourceId,
    required String targetId,
    required ResonanceConnectionType type,
    required double strength,
  }) async {
    final existing = await repository.getConnectionBetween(sourceId, targetId);
    if (existing != null) {
      return existing;
    }

    final connection = ResonanceConnection(
      id: '${sourceId}_$targetId',
      sourceId: sourceId,
      targetId: targetId,
      type: type,
      strength: strength,
      createdAt: DateTime.now(),
    );

    await repository.saveConnection(connection);
    return connection;
  }

  @override
  Future<ResonanceConnection?> getConnectionBetween(
    String sourceId,
    String targetId,
  ) {
    return repository.getConnectionBetween(sourceId, targetId);
  }

  @override
  Future<List<ResonanceConnection>> getConnectionsInvolving(String id) {
    return repository.getConnectionsInvolving(id);
  }

  @override
  Future<void> updateConnection(ResonanceConnection connection) {
    return repository.updateConnection(connection);
  }

  @override
  Future<void> saveThread(ResonanceThread thread) {
    return repository.saveThread(thread);
  }

  @override
  Future<ResonanceThread?> getThread(String threadId) {
    return repository.getThread(threadId);
  }

  @override
  Future<List<ResonanceThread>> getThreadsForExperience(String experienceId) {
    return repository.getThreadsForExperience(experienceId);
  }

  @override
  Future<List<ResonanceThread>> getThreads() {
    return repository.getThreads();
  }

  @override
  Future<void> saveMap(ResonanceMap map) {
    return _requireMapRepository().saveMap(map);
  }

  @override
  Future<ResonanceMap?> getMap(String mapId) {
    return _requireMapRepository().getMap(mapId);
  }

  @override
  Future<List<ResonanceMap>> getMapsForExperience(String experienceId) {
    return _requireMapRepository().getMapsForExperience(experienceId);
  }

  @override
  Future<List<ResonanceMap>> getMaps() {
    return _requireMapRepository().getMaps();
  }
}
