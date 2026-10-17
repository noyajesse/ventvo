class CrashOutSpaceExperience {
  final String id;
  final String spaceId;
  final String content;
  final DateTime createdAt;
  final String? voiceName;
  final String voiceMark;
  final String? sourceExperienceId;

  const CrashOutSpaceExperience({
    required this.id,
    required this.spaceId,
    required this.content,
    required this.createdAt,
    this.voiceName,
    this.voiceMark = '',
    this.sourceExperienceId,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'spaceId': spaceId,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'voiceName': voiceName,
        'voiceMark': voiceMark,
        'sourceExperienceId': sourceExperienceId,
      };

  static CrashOutSpaceExperience? fromMap(Map<String, dynamic> map) {
    final id = map['id'];
    final spaceId = map['spaceId'];
    final content = map['content'];
    final createdAt = map['createdAt'];
    if (id is! String ||
        id.trim().isEmpty ||
        spaceId is! String ||
        spaceId.trim().isEmpty ||
        content is! String ||
        content.trim().isEmpty ||
        createdAt is! String) {
      return null;
    }
    final parsedDate = DateTime.tryParse(createdAt);
    if (parsedDate == null) return null;

    return CrashOutSpaceExperience(
      id: id,
      spaceId: spaceId,
      content: content,
      createdAt: parsedDate,
      voiceName: map['voiceName'] is String ? map['voiceName'] as String : null,
      voiceMark: map['voiceMark'] is String ? map['voiceMark'] as String : '',
      sourceExperienceId: map['sourceExperienceId'] is String
          ? map['sourceExperienceId'] as String
          : null,
    );
  }
}
