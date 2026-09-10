import '../algorithms/deterministic_resonance_scorer.dart';
import '../models/resonance_candidate.dart';
import '../models/resonance_connection.dart';
import '../models/resonance_query.dart';
import '../repositories/resonance_repository.dart';

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
}

class LocalResonanceEngine implements ResonanceEngine {
  final ResonanceRepository repository;
  final DeterministicResonanceScorer scorer;

  const LocalResonanceEngine({
    required this.repository,
    this.scorer = const DeterministicResonanceScorer(),
  });

  @override
  Future<void> indexCandidate(ResonanceCandidate candidate) {
    return repository.saveCandidate(candidate);
  }

  @override
  Future<List<ResonanceCandidate>> discover(ResonanceQuery query) async {
    final candidates = await repository.findCandidates(query);

    final ranked = candidates
        .where((candidate) =>
            candidate.id != query.sourceId &&
            !query.excludedIds.contains(candidate.id))
        .map(
          (candidate) => candidate.copyWith(
            score: scorer.score(
              sourceSignals: query.signals,
              candidate: candidate,
            ),
          ),
        )
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
}
