import 'resonance_connection.dart';

class ResonanceThread {
  final String id;
  final String originatingExperienceId;
  final List<String> experienceIds;
  final List<String> voiceMarks;
  final List<ResonanceConnection> connections;
  final DateTime createdAt;

  const ResonanceThread({
    required this.id,
    required this.originatingExperienceId,
    this.experienceIds = const [],
    this.voiceMarks = const [],
    this.connections = const [],
    required this.createdAt,
  });

  ResonanceThread copyWith({
    String? id,
    String? originatingExperienceId,
    List<String>? experienceIds,
    List<String>? voiceMarks,
    List<ResonanceConnection>? connections,
    DateTime? createdAt,
  }) {
    return ResonanceThread(
      id: id ?? this.id,
      originatingExperienceId:
          originatingExperienceId ?? this.originatingExperienceId,
      experienceIds: experienceIds ?? this.experienceIds,
      voiceMarks: voiceMarks ?? this.voiceMarks,
      connections: connections ?? this.connections,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
