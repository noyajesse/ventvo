enum ExperienceContributionType {
  origin,
  opposite,
  response,
  related,
}

class ExperienceContribution {
  final String id;
  final String threadId;
  final String content;
  final ExperienceContributionType type;
  final DateTime createdAt;
  final String? replyToId;
  final String? sourceExperienceId;
  final String? voiceName;
  final String? voiceMark;

  const ExperienceContribution({
    required this.id,
    required this.threadId,
    required this.content,
    required this.type,
    required this.createdAt,
    this.replyToId,
    this.sourceExperienceId,
    this.voiceName,
    this.voiceMark,
  });
}

class ExperienceThread {
  final String id;
  final String originCrashOutId;
  final List<ExperienceContribution> contributions;
  final DateTime createdAt;

  const ExperienceThread({
    required this.id,
    required this.originCrashOutId,
    this.contributions = const [],
    required this.createdAt,
  });

  ExperienceThread copyWith({
    String? id,
    String? originCrashOutId,
    List<ExperienceContribution>? contributions,
    DateTime? createdAt,
  }) {
    return ExperienceThread(
      id: id ?? this.id,
      originCrashOutId: originCrashOutId ?? this.originCrashOutId,
      contributions: contributions ?? this.contributions,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
