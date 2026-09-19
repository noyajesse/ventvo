enum ResonanceConnectionType {
  similarity,
  sharedExperience,
  perspective,
  response,
  discovery,
}

enum ResonanceConnectionState {
  suggested,
  accepted,
  active,
  closed,
  blocked,
}

class ResonanceConnection {
  final String id;
  final String sourceId;
  final String targetId;
  final String? sourceVoiceId;
  final String? targetVoiceId;
  final ResonanceConnectionType type;
  final double strength;
  final ResonanceConnectionState state;
  final DateTime createdAt;

  const ResonanceConnection({
    required this.id,
    required this.sourceId,
    required this.targetId,
    this.sourceVoiceId,
    this.targetVoiceId,
    required this.type,
    required this.strength,
    this.state = ResonanceConnectionState.suggested,
    required this.createdAt,
  });

  ResonanceConnection copyWith({
    String? id,
    String? sourceId,
    String? targetId,
    String? sourceVoiceId,
    String? targetVoiceId,
    ResonanceConnectionType? type,
    double? strength,
    ResonanceConnectionState? state,
    DateTime? createdAt,
  }) {
    return ResonanceConnection(
      id: id ?? this.id,
      sourceId: sourceId ?? this.sourceId,
      targetId: targetId ?? this.targetId,
      sourceVoiceId: sourceVoiceId ?? this.sourceVoiceId,
      targetVoiceId: targetVoiceId ?? this.targetVoiceId,
      type: type ?? this.type,
      strength: strength ?? this.strength,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
