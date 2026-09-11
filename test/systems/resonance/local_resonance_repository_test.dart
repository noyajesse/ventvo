import 'package:flutter_test/flutter_test.dart';
import 'package:ventvo/systems/resonance/models/resonance_candidate.dart';
import 'package:ventvo/systems/resonance/models/resonance_connection.dart';
import 'package:ventvo/systems/resonance/models/resonance_query.dart';
import 'package:ventvo/systems/resonance/models/resonance_signal.dart';
import 'package:ventvo/systems/resonance/repositories/local_resonance_repository.dart';

void main() {
  test('returns only candidates of the requested source type', () async {
    final repository = LocalResonanceRepository();
    await repository.saveCandidate(
      const ResonanceCandidate(
        id: 'vent-1',
        type: ResonanceCandidateType.vent,
        score: 0,
      ),
    );
    await repository.saveCandidate(
      const ResonanceCandidate(
        id: 'voice-1',
        type: ResonanceCandidateType.voice,
        score: 0,
      ),
    );

    final results = await repository.findCandidates(
      const ResonanceQuery(
        sourceId: 'source',
        sourceType: ResonanceCandidateType.vent,
      ),
    );

    expect(results.map((candidate) => candidate.id), ['vent-1']);
  });

  test('does not expose private or unsafe candidates for discovery', () async {
    final repository = LocalResonanceRepository();
    await repository.saveCandidate(
      const ResonanceCandidate(
        id: 'private',
        type: ResonanceCandidateType.vent,
        score: 0,
        signals: [
          ResonanceSignal(
            type: ResonanceSignalType.privacy,
            key: 'private',
            strength: 1,
          ),
        ],
      ),
    );
    await repository.saveCandidate(
      const ResonanceCandidate(
        id: 'unsafe',
        type: ResonanceCandidateType.vent,
        score: 0,
        signals: [
          ResonanceSignal(
            type: ResonanceSignalType.safety,
            key: 'restricted',
            strength: 1,
          ),
        ],
      ),
    );
    await repository.saveCandidate(
      const ResonanceCandidate(
        id: 'safe',
        type: ResonanceCandidateType.vent,
        score: 0,
      ),
    );

    final results = await repository.findCandidates(
      const ResonanceQuery(
        sourceId: 'source',
        sourceType: ResonanceCandidateType.vent,
      ),
    );

    expect(results.map((candidate) => candidate.id), ['safe']);
  });

  test('saveCandidate replaces an existing candidate', () async {
    final repository = LocalResonanceRepository();
    await repository.saveCandidate(
      const ResonanceCandidate(
        id: 'vent-1',
        type: ResonanceCandidateType.vent,
        score: 0,
      ),
    );
    await repository.saveCandidate(
      const ResonanceCandidate(
        id: 'vent-1',
        type: ResonanceCandidateType.vent,
        score: 0,
        signals: [
          ResonanceSignal(
            type: ResonanceSignalType.experiential,
            key: 'burnout',
            strength: 1,
          ),
        ],
      ),
    );

    final results = await repository.findCandidates(
      const ResonanceQuery(
        sourceId: 'source',
        sourceType: ResonanceCandidateType.vent,
      ),
    );

    expect(results.single.signals.single.key, 'burnout');
  });

  test('replaces an existing connection between the same pair', () async {
    final repository = LocalResonanceRepository();
    const first = ResonanceConnection(
      id: 'old',
      sourceId: 'vent-1',
      targetId: 'vent-2',
      type: ResonanceConnectionType.similarity,
      strength: 0.4,
      createdAt: DateTime(2026, 1, 1),
    );
    const second = ResonanceConnection(
      id: 'new',
      sourceId: 'vent-1',
      targetId: 'vent-2',
      type: ResonanceConnectionType.sharedExperience,
      strength: 0.9,
      createdAt: DateTime(2026, 1, 2),
    );

    await repository.saveConnection(first);
    await repository.saveConnection(second);

    final results = await repository.getConnectionsFor('vent-1');

    expect(results, hasLength(1));
    expect(results.single.id, 'new');
    expect(results.single.strength, 0.9);
  });
}
