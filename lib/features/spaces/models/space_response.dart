class SpaceResponse {
  final String id;
  final String spaceId;
  final String voiceMark;
  final String content;
  final DateTime createdAt;

  const SpaceResponse({
    required this.id,
    required this.spaceId,
    required this.voiceMark,
    required this.content,
    required this.createdAt,
  });
}
