import 'resonance_connection.dart';

/// A relationship graph discovered by Resonance.
///
/// A Map describes a larger structure of connected experiences. Unlike a
/// Thread, it does not imply a single continuing path. A Map may contain
/// several Threads and other meaningful relationships between experiences.
class ResonanceMap {
  final String id;
  final List<String> experienceIds;
  final List<String> threadIds;
  final List<ResonanceConnection> connections;
  final DateTime createdAt;

  const ResonanceMap._({
    required this.id,
    required this.experienceIds,
    required this.threadIds,
    required this.connections,
    required this.createdAt,
  });

  factory ResonanceMap.create({
    required String id,
    List<String> experienceIds = const [],
    List<String> threadIds = const [],
    List<ResonanceConnection> connections = const [],
    required DateTime createdAt,
  }) {
    _validate(
      id: id,
      experienceIds: experienceIds,
      threadIds: threadIds,
      connections: connections,
    );

    return ResonanceMap._(
      id: id,
      experienceIds: List.unmodifiable(experienceIds),
      threadIds: List.unmodifiable(threadIds),
      connections: List.unmodifiable(connections),
      createdAt: createdAt,
    );
  }

  ResonanceMap copyWith({
    String? id,
    List<String>? experienceIds,
    List<String>? threadIds,
    List<ResonanceConnection>? connections,
    DateTime? createdAt,
  }) {
    return ResonanceMap.create(
      id: id ?? this.id,
      experienceIds: experienceIds ?? this.experienceIds,
      threadIds: threadIds ?? this.threadIds,
      connections: connections ?? this.connections,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool containsExperience(String experienceId) {
    return experienceIds.contains(experienceId);
  }

  bool containsThread(String threadId) {
    return threadIds.contains(threadId);
  }

  bool containsConnection(String connectionId) {
    return connections.any((connection) => connection.id == connectionId);
  }

  static void _validate({
    required String id,
    required List<String> experienceIds,
    required List<String> threadIds,
    required List<ResonanceConnection> connections,
  }) {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'Map id cannot be empty.');
    }

    final uniqueExperienceIds = experienceIds.toSet();
    if (uniqueExperienceIds.length != experienceIds.length) {
      throw ArgumentError.value(
        experienceIds,
        'experienceIds',
        'A map cannot contain duplicate experiences.',
      );
    }

    final uniqueThreadIds = threadIds.toSet();
    if (uniqueThreadIds.length != threadIds.length) {
      throw ArgumentError.value(
        threadIds,
        'threadIds',
        'A map cannot contain duplicate threads.',
      );
    }

    for (final connection in connections) {
      if (connection.sourceId == connection.targetId) {
        throw ArgumentError.value(
          connection.id,
          'connections',
          'A map cannot contain self-links.',
        );
      }

      if (!uniqueExperienceIds.contains(connection.sourceId) ||
          !uniqueExperienceIds.contains(connection.targetId)) {
        throw ArgumentError.value(
          connection.id,
          'connections',
          'Every map connection must involve only map experiences.',
        );
      }
    }
  }
}
