class VentvoVoice {
  final String? voiceId;
  final String? expression;
  final String? resonance;
  final String? mark;
  final String? name;
  final DateTime createdAt;
  final int evolutionCount;
  final DateTime? lastEvolvedAt;

  const VentvoVoice({
    this.voiceId,
    this.expression,
    this.resonance,
    this.mark,
    this.name,
    required this.createdAt,
    this.evolutionCount = 0,
    this.lastEvolvedAt,
  });

  VentvoVoice copyWith({
    String? voiceId,
    String? expression,
    String? resonance,
    String? mark,
    String? name,
    DateTime? createdAt,
    int? evolutionCount,
    DateTime? lastEvolvedAt,
  }) {
    return VentvoVoice(
      voiceId: voiceId ?? this.voiceId,
      expression: expression ?? this.expression,
      resonance: resonance ?? this.resonance,
      mark: mark ?? this.mark,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      evolutionCount: evolutionCount ?? this.evolutionCount,
      lastEvolvedAt: lastEvolvedAt ?? this.lastEvolvedAt,
    );
  }
}
