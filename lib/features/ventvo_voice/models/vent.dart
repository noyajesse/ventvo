class Vent {
  final String id;
  final String content;
  final String spaceId;
  final String voiceMark;
  final String? voiceName;
  final DateTime createdAt;

  const Vent({
    required this.id,
    required this.content,
    required this.spaceId,
    required this.voiceMark,
    this.voiceName,
    required this.createdAt,
  });

  Vent copyWith({
    String? id,
    String? content,
    String? spaceId,
    String? voiceMark,
    String? voiceName,
    DateTime? createdAt,
  }) {
    return Vent(
      id: id ?? this.id,
      content: content ?? this.content,
      spaceId: spaceId ?? this.spaceId,
      voiceMark: voiceMark ?? this.voiceMark,
      voiceName: voiceName ?? this.voiceName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
