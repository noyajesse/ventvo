class Vent {
  static const String justListen = 'Just Listen';
  static const String openDiscussion = 'Open Discussion';

  final String id;
  final String content;
  final String spaceType;
  final String voiceMark;
  final DateTime createdAt;

  const Vent({
    required this.id,
    required this.content,
    required this.spaceType,
    required this.voiceMark,
    required this.createdAt,
  });

  bool get isJustListen => spaceType == justListen;
  bool get isOpenDiscussion => spaceType == openDiscussion;

  Vent copyWith({
    String? id,
    String? content,
    String? spaceType,
    String? voiceMark,
    DateTime? createdAt,
  }) {
    return Vent(
      id: id ?? this.id,
      content: content ?? this.content,
      spaceType: spaceType ?? this.spaceType,
      voiceMark: voiceMark ?? this.voiceMark,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
