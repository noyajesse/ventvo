class SpaceResponse {
  final String id;
  final String spaceId;
  final String? ventId;
  final String voiceMark;
  final String? authorVoiceId;
  final String content;
  final DateTime createdAt;
  final bool isMoment;
  final bool isHeard;

  const SpaceResponse({
    required this.id,
    required this.spaceId,
    this.ventId,
    required this.voiceMark,
    this.authorVoiceId,
    required this.content,
    required this.createdAt,
    this.isMoment = false,
    this.isHeard = false,
  });
}
