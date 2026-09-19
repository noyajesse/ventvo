class ResonanceConversation {
  final String id;
  final String connectionId;
  final String sourceExperienceId;
  final String targetExperienceId;
  final String sourceVoiceMark;
  final String targetVoiceMark;
  final DateTime createdAt;

  const ResonanceConversation({
    required this.id,
    required this.connectionId,
    required this.sourceExperienceId,
    required this.targetExperienceId,
    required this.sourceVoiceMark,
    required this.targetVoiceMark,
    required this.createdAt,
  });
}
