class Vent {
  static const String justListen = 'Just Listen';
  static const String openDiscussion = 'Open Discussion';

  final String id;
  final String content;
  final String responseIntent;
  final String voiceMark;
  final DateTime createdAt;

  const Vent({
    required this.id,
    required this.content,
    required this.responseIntent,
    required this.voiceMark,
    required this.createdAt,
  });

  bool get isJustListen => responseIntent == justListen;
  bool get isOpenDiscussion => responseIntent == openDiscussion;

  Vent copyWith({
    String? id,
    String? content,
    String? responseIntent,
    String? voiceMark,
    DateTime? createdAt,
  }) {
    return Vent(
      id: id ?? this.id,
      content: content ?? this.content,
      responseIntent: responseIntent ?? this.responseIntent,
      voiceMark: voiceMark ?? this.voiceMark,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
