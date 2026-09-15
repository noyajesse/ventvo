class VentvoVoice {
  final String? voiceId;
  final String? seedId;
  final String? expression;
  final String? resonance;
  final String? mark;
  final String? name;
  final DateTime createdAt;

  const VentvoVoice({
    this.voiceId,
    this.seedId,
    this.expression,
    this.resonance,
    this.mark,
    this.name,
    required this.createdAt,
  });

  VentvoVoice copyWith({
    String? voiceId,
    String? seedId,
    String? expression,
    String? resonance,
    String? mark,
    String? name,
    DateTime? createdAt,
  }) {
    return VentvoVoice(
      voiceId: voiceId ?? this.voiceId,
      seedId: seedId ?? this.seedId,
      expression: expression ?? this.expression,
      resonance: resonance ?? this.resonance,
      mark: mark ?? this.mark,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
