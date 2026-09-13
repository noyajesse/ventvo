import '../algorithms/deterministic_resonance_scorer.dart';
import '../models/resonance_candidate.dart';
import '../models/resonance_connection.dart';
import '../models/resonance_query.dart';
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
}

class LocalResonanceEngine implements ResonanceEngine {
  final ResonanceRepository repository;
  final DeterministicResonanceScorer scorer;
  final ResonanceSignalComposer composer;

  const LocalResonanceEngine({
    required this.repository,
    this.scorer = const DeterministicResonanceScorer(),
    this.composer = const ResonanceSignalComposer(),
  });

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
