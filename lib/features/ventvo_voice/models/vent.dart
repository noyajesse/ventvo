enum VentVisibility {
  public,
  private,
}

enum VentSafetyState {
  pending,
  approved,
  restricted,
}

enum VentLifecycleState {
  active,
  archived,
}

class Vent {
  final String id;
  final String content;
  final String spaceId;
  final String voiceMark;
  final String? ownerVoiceId;
  final String? voiceName;
  final String? voiceSeedId;
  final DateTime createdAt;
  final VentVisibility visibility;
  final VentSafetyState safetyState;
  final VentLifecycleState lifecycleState;
  final String? originatingCrashOutId;

  const Vent({
    required this.id,
    required this.content,
    required this.spaceId,
    required this.voiceMark,
    this.ownerVoiceId,
    this.voiceName,
    this.voiceSeedId,
    required this.createdAt,
    this.visibility = VentVisibility.public,
    this.safetyState = VentSafetyState.approved,
    this.lifecycleState = VentLifecycleState.active,
    this.originatingCrashOutId,
  });

  bool get isActive => lifecycleState == VentLifecycleState.active;

  bool get isDiscoverable =>
      isActive &&
      visibility == VentVisibility.public &&
      safetyState == VentSafetyState.approved;

  Vent copyWith({
    String? id,
    String? content,
    String? spaceId,
    String? voiceMark,
    String? ownerVoiceId,
    String? voiceName,
    String? voiceSeedId,
    DateTime? createdAt,
    VentVisibility? visibility,
    VentSafetyState? safetyState,
    VentLifecycleState? lifecycleState,
    String? originatingCrashOutId,
  }) {
    return Vent(
      id: id ?? this.id,
      content: content ?? this.content,
      spaceId: spaceId ?? this.spaceId,
      voiceMark: voiceMark ?? this.voiceMark,
      ownerVoiceId: ownerVoiceId ?? this.ownerVoiceId,
      voiceName: voiceName ?? this.voiceName,
      voiceSeedId: voiceSeedId ?? this.voiceSeedId,
      createdAt: createdAt ?? this.createdAt,
      visibility: visibility ?? this.visibility,
      safetyState: safetyState ?? this.safetyState,
      lifecycleState: lifecycleState ?? this.lifecycleState,
      originatingCrashOutId:
          originatingCrashOutId ?? this.originatingCrashOutId,
    );
  }
}
