enum CrashOutType {
  text,
  voice,
}

enum CrashOutStatus {
  keptPrivate,
  spaceEntered,
}

extension CrashOutStatusPrivacy on CrashOutStatus {
  /// Both lifecycle states retain the original Crash Out as private data.
  bool get isPrivate =>
      this == CrashOutStatus.keptPrivate ||
      this == CrashOutStatus.spaceEntered;
}

class CrashOut {
  final String id;

  /// Owning anonymous Voice. Null is retained only for legacy local records.
  final String? ownerVoiceId;

  /// Text content when the user types their Crash Out.
  final String? textContent;

  /// Future path/URL for a recorded Crash Out.
  final String? audioPath;

  final CrashOutType type;

  final DateTime createdAt;

  /// The wider Space entered for this Crash Out, stored as a HumanTension name.
  /// Null for legacy records and Crash Outs that have not entered a Space.
  final String? spaceId;

  /// The eligible opposing experience highlighted when the Space was entered.
  final String? matchedExperienceId;

  /// Current lifecycle state of this Crash Out.
  final CrashOutStatus status;

  const CrashOut({
    required this.id,
    this.ownerVoiceId,
    this.textContent,
    this.audioPath,
    required this.type,
    required this.createdAt,
    this.spaceId,
    this.matchedExperienceId,
    this.status = CrashOutStatus.keptPrivate,
  });

  CrashOut copyWith({
    String? id,
    String? ownerVoiceId,
    String? textContent,
    String? audioPath,
    CrashOutType? type,
    DateTime? createdAt,
    String? spaceId,
    String? matchedExperienceId,
    bool clearMatchedExperienceId = false,
    CrashOutStatus? status,
  }) {
    return CrashOut(
      id: id ?? this.id,
      ownerVoiceId: ownerVoiceId ?? this.ownerVoiceId,
      textContent: textContent ?? this.textContent,
      audioPath: audioPath ?? this.audioPath,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      spaceId: spaceId ?? this.spaceId,
      matchedExperienceId: clearMatchedExperienceId
          ? null
          : matchedExperienceId ?? this.matchedExperienceId,
      status: status ?? this.status,
    );
  }
}