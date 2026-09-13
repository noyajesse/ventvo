import 'resonance_connection.dart';

class ResonanceThread {
  final String id;
  final String originatingExperienceId;
  final List<String> experienceIds;
  final List<String> voiceMarks;
  final List<ResonanceConnection> connections;
  final DateTime createdAt;

  const ResonanceThread._({
    required this.id,
    required this.originatingExperienceId,
    required this.experienceIds,
    required this.voiceMarks,
    required this.connections,
    required this.createdAt,
  });

  factory ResonanceThread.create({
    required String id,
    required String originatingExperienceId,
    List<String> experienceIds = const [],
    List<String> voiceMarks = const [],
    List<ResonanceConnection> connections = const [],
    required DateTime createdAt,
  }) {
    _validate(
      id: id,
      originatingExperienceId: originatingExperienceId,
      experienceIds: experienceIds,
      connections: connections,
    );

    return ResonanceThread._(
      id: id,
      originatingExperienceId: originatingExperienceId,
      experienceIds: List.unmodifiable(experienceIds),
      voiceMarks: List.unmodifiable(voiceMarks),
      connections: List.unmodifiable(connections),
      createdAt: createdAt,
    );
  }

  ResonanceThread copyWith({
    String? id,
    String? originatingExperienceId,
    List<String>? experienceIds,
    List<String>? voiceMarks,
    List<ResonanceConnection>? connections,
    DateTime? createdAt,
  }) {
    return ResonanceThread.create(
      id: id ?? this.id,
      originatingExperienceId:
          originatingExperienceId ?? this.originatingExperienceId,
      experienceIds: experienceIds ?? this.experienceIds,
      voiceMarks: voiceMarks ?? this.voiceMarks,
      connections: connections ?? this.connections,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool containsExperience(String experienceId) {
    return experienceIds.contains(experienceId);
  }

  bool containsConnection(String connectionId) {
    return connections.any((connection) => connection.id == connectionId);
  }

  static void _validate({
    required String id,
    required String originatingExperienceId,
    required List<String> experienceIds,
    required List<ResonanceConnection> connections,
  }) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Thread id cannot be empty.');
    }

    if (originatingExperienceId.trim().isEmpty) {
      throw ArgumentError.value(
        originatingExperienceId,
        'originatingExperienceId',
        'Originating experience id cannot be empty.',
      );
    }

    if (!experienceIds.contains(originatingExperienceId)) {
      throw ArgumentError.value(
        experienceIds,
        'experienceIds',
        'Originating experience must belong to the thread.',
      );
    }

    final uniqueExperienceIds = experienceIds.toSet();
    if (uniqueExperienceIds.length != experienceIds.length) {
      throw ArgumentError.value(
        experienceIds,
        'experienceIds',
        'A thread cannot contain duplicate experiences.',
      );
    }

    for (final connection in connections) {
      if (!uniqueExperienceIds.contains(connection.sourceId) ||
          !uniqueExperienceIds.contains(connection.targetId)) {
        throw ArgumentError.value(
          connection.id,
          'connections',
          'Every thread connection must involve only thread experiences.',
        );
      }
    }
  }
}
