enum VentInteractionMode {
  justListen,
  openDiscussion,
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
  final VentInteractionMode interactionMode;
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
    this.interactionMode = VentInteractionMode.justListen,
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
    VentInteractionMode? interactionMode,
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
      interactionMode: interactionMode ?? this.interactionMode,
      visibility: visibility ?? this.visibility,
      safetyState: safetyState ?? this.safetyState,
      originatingCrashOutId:
          originatingCrashOutId ?? this.originatingCrashOutId,
    );
  }
}
