enum VentIntent {
  justListen,
  advice,
  similarExperiences,
  encouragement,
  celebrating,
}

enum VentVisibility {
  public,
  private,
}

enum VentSafetyState {
  pending,
  approved,
  restricted,
}

class Vent {
  final String id;
  final String content;
  final String spaceId;
  final String voiceMark;
  final String? voiceName;
  final DateTime createdAt;
  final VentIntent intent;
  final VentVisibility visibility;
  final VentSafetyState safetyState;
  final String? originatingCrashOutId;

  const Vent({
    required this.id,
    required this.content,
    required this.spaceId,
    required this.voiceMark,
    this.voiceName,
    required this.createdAt,
    this.intent = VentIntent.justListen,
    this.visibility = VentVisibility.public,
    this.safetyState = VentSafetyState.approved,
    this.originatingCrashOutId,
  });

  bool get isDiscoverable =>
      visibility == VentVisibility.public &&
      safetyState == VentSafetyState.approved;

  Vent copyWith({
    String? id,
    String? content,
    String? spaceId,
    String? voiceMark,
    String? voiceName,
    DateTime? createdAt,
    VentIntent? intent,
    VentVisibility? visibility,
    VentSafetyState? safetyState,
    String? originatingCrashOutId,
  }) {
    return Vent(
      id: id ?? this.id,
      content: content ?? this.content,
      spaceId: spaceId ?? this.spaceId,
      voiceMark: voiceMark ?? this.voiceMark,
      voiceName: voiceName ?? this.voiceName,
      createdAt: createdAt ?? this.createdAt,
      intent: intent ?? this.intent,
      visibility: visibility ?? this.visibility,
      safetyState: safetyState ?? this.safetyState,
      originatingCrashOutId:
          originatingCrashOutId ?? this.originatingCrashOutId,
    );
  }
}
