import 'package:flutter_test/flutter_test.dart';
import 'package:ventvo/systems/resonance/algorithms/deterministic_resonance_scorer.dart';
import 'package:ventvo/systems/resonance/models/resonance_candidate.dart';
import 'package:ventvo/systems/resonance/models/resonance_signal.dart';

void main() {
  const scorer = DeterministicResonanceScorer();

  test('rewards matching experiential signals', () {
    const sourceSignals = [
      ResonanceSignal(
        type: ResonanceSignalType.experiential,
        key: 'starting_over',
        strength: 1,
      ),
    ];
    const candidate = ResonanceCandidate(
      id: 'vent-2',
      type: ResonanceCandidateType.vent,
      score: 0,
      signals: [
        ResonanceSignal(
          type: ResonanceSignalType.experiential,
          key: 'starting_over',
          strength: 1,
        ),
      ],
    );

    expect(
      scorer.score(sourceSignals: sourceSignals, candidate: candidate),
      1,
    );
  });

  test('does not match the same key when signal types differ', () {
    const sourceSignals = [
      ResonanceSignal(
        type: ResonanceSignalType.experiential,
        key: 'work',
        strength: 1,
      ),
    ];
    const candidate = ResonanceCandidate(
      id: 'vent-3',
      type: ResonanceCandidateType.vent,
      score: 0,
      signals: [
        ResonanceSignal(
          type: ResonanceSignalType.semantic,
          key: 'work',
          strength: 1,
        ),
      ],
    );

    expect(scorer.score(sourceSignals: sourceSignals, candidate: candidate), 0);
  });

  test('rewards resonance across multiple signal dimensions', () {
    final sourceSignals = [
      ResonanceSignal(
        type: ResonanceSignalType.experiential,
        key: 'burnout',
        strength: 0.4,
      ),
      ResonanceSignal(
        type: ResonanceSignalType.semantic,
        key: 'university',
        strength: 0.4,
      ),
    ];
    final candidate = ResonanceCandidate(
      id: 'vent-4',
      type: ResonanceCandidateType.vent,
      score: 0,
      signals: [
        ResonanceSignal(
          type: ResonanceSignalType.experiential,
          key: 'burnout',
          strength: 0.4,
        ),
        ResonanceSignal(
          type: ResonanceSignalType.semantic,
          key: 'university',
          strength: 0.4,
        ),
      ],
    );

    final multiDimensionScore = scorer.score(
      sourceSignals: sourceSignals,
      candidate: candidate,
    );
    final singleDimensionScore = scorer.score(
      sourceSignals: const [
        ResonanceSignal(
          type: ResonanceSignalType.experiential,
          key: 'burnout',
          strength: 0.4,
        ),
      ],
      candidate: const ResonanceCandidate(
        id: 'vent-5',
        type: ResonanceCandidateType.vent,
        score: 0,
        signals: [
          ResonanceSignal(
            type: ResonanceSignalType.experiential,
            key: 'burnout',
            strength: 0.4,
          ),
        ],
      ),
    );

    expect(multiDimensionScore, greaterThan(singleDimensionScore));
  });

  test('safety signal reduces resonance score', () {
    final sourceSignals = [
      ResonanceSignal(
        type: ResonanceSignalType.semantic,
        key: 'stress',
        strength: 1,
      ),
    ];
    final candidate = ResonanceCandidate(
      id: 'vent-6',
      type: ResonanceCandidateType.vent,
      score: 0,
      signals: [
        ResonanceSignal(
          type: ResonanceSignalType.semantic,
          key: 'stress',
          strength: 1,
        ),
        ResonanceSignal(
          type: ResonanceSignalType.safety,
          key: 'stress',
          strength: 0.5,
        ),
      ],
    );

    expect(scorer.score(sourceSignals: sourceSignals, candidate: candidate), 0);
  });
}
