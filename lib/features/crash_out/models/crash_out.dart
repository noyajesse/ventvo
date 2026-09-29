enum CrashOutType {
  text,
  voice,
}

enum CrashOutStatus {
  keptPrivate,
}

class CrashOut {
  final String id;

  /// Text content when the user types their Crash Out.
  final String? textContent;

  /// Future path/URL for a recorded Crash Out.
  final String? audioPath;

  final CrashOutType type;

  final DateTime createdAt;

  /// Current lifecycle state of this Crash Out.
  final CrashOutStatus status;

  const CrashOut({
    required this.id,
    this.textContent,
    this.audioPath,
    required this.type,
    required this.createdAt,
    this.status = CrashOutStatus.keptPrivate,
  });

  CrashOut copyWith({
    String? id,
    String? textContent,
    String? audioPath,
    CrashOutType? type,
    DateTime? createdAt,
    CrashOutStatus? status,
  }) {
    return CrashOut(
      id: id ?? this.id,
      textContent: textContent ?? this.textContent,
      audioPath: audioPath ?? this.audioPath,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}