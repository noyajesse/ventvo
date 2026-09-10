import 'resonance_connection.dart';

class ResonanceMap {
  final String id;
  final String rootExperienceId;
  final List<String> experienceIds;
  final List<String> voiceMarks;
  final List<ResonanceConnection> connections;
  final DateTime createdAt;

  const ResonanceMap({
    required this.id,
    required this.rootExperienceId,
    this.experienceIds = const [],
    this.voiceMarks = const [],
    this.connections = const [],
    required this.createdAt,
  });

  ResonanceMap copyWith({
    String? id,
    String? rootExperienceId,
    List<String>? experienceIds,
    List<String>? voiceMarks,
    List<ResonanceConnection>? connections,
    DateTime? createdAt,
  }) {
    return ResonanceMap(
      id: id ?? this.id,
      rootExperienceId: rootExperienceId ?? this.rootExperienceId,
      experienceIds: experienceIds ?? this.experienceIds,
      voiceMarks: voiceMarks ?? this.voiceMarks,
      connections: connections ?? this.connections,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
