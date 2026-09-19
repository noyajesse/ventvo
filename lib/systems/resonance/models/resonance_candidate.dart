import 'resonance_profile.dart';
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
  final String? voiceId;
  final double score;
  final List<ResonanceSignal> signals;
  final ResonanceProfile? profile;

  const ResonanceCandidate({
    required this.id,
    required this.type,
    this.voiceMark,
    this.voiceId,
    required this.score,
    this.signals = const [],
    this.profile,
  });

  ResonanceCandidate copyWith({
    String? id,
    ResonanceCandidateType? type,
    String? voiceMark,
    String? voiceId,
    double? score,
    List<ResonanceSignal>? signals,
    ResonanceProfile? profile,
  }) {
    return ResonanceCandidate(
      id: id ?? this.id,
      type: type ?? this.type,
      voiceMark: voiceMark ?? this.voiceMark,
      voiceId: voiceId ?? this.voiceId,
      score: score ?? this.score,
      signals: signals ?? this.signals,
      profile: profile ?? this.profile,
    );
  }
}
