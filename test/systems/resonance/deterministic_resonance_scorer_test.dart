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

  test('ignores unrelated signals', () {
    const sourceSignals = [
      ResonanceSignal(
        type: ResonanceSignalType.semantic,
        key: 'university',
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

  test('safety signal reduces resonance score', () {
    const sourceSignals = [
      const ResonanceSignal(
        type: ResonanceSignalType.semantic,
        key: 'stress',
        strength: 1,
      ),
    ];
    const candidate = ResonanceCandidate(
      id: 'vent-4',
      type: ResonanceCandidateType.vent,
      score: 0,
      signals: [
        const ResonanceSignal(
          type: ResonanceSignalType.semantic,
          key: 'stress',
          strength: 1,
        ),
        const ResonanceSignal(
          type: ResonanceSignalType.safety,
          key: 'stress',
          strength: 0.5,
        ),
      ],
    );

    expect(scorer.score(sourceSignals: sourceSignals, candidate: candidate), 0);
  });
}
