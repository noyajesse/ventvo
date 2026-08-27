class SpaceResponse {
  final String id;
  final String spaceId;
  final String? ventId;
  final String voiceMark;
  final String content;
  final DateTime createdAt;
  final bool isMoment;

  const SpaceResponse({
    required this.id,
    required this.spaceId,
    this.ventId,
    required this.voiceMark,
    required this.content,
    required this.createdAt,
    this.isMoment = false,
  });
}
