import 'resonance_signal.dart';

enum ResonanceCandidateType {
  vent,
  voice,
  space,
}

class ResonanceCandidate {
  final String id;
  final ResonanceCandidateType type;
  final String? voiceMark;
  final double score;
  final List<ResonanceSignal> signals;

  const ResonanceCandidate({
    required this.id,
    required this.type,
    this.voiceMark,
    required this.score,
    this.signals = const [],
  });

  ResonanceCandidate copyWith({
    String? id,
    ResonanceCandidateType? type,
    String? voiceMark,
    double? score,
    List<ResonanceSignal>? signals,
  }) {
    return ResonanceCandidate(
      id: id ?? this.id,
      type: type ?? this.type,
      voiceMark: voiceMark ?? this.voiceMark,
      score: score ?? this.score,
      signals: signals ?? this.signals,
    );
  }
}
