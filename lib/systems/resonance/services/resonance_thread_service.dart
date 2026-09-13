import '../models/resonance_connection.dart';
import '../models/resonance_thread.dart';
import 'resonance_engine.dart';

/// Governs creation and extension of Resonance Threads.
///
/// Product features should use this service instead of mutating Threads
/// directly. The service owns Thread business rules while the engine owns
/// Resonance persistence and discovery operations.
class ResonanceThreadService {
  final ResonanceEngine engine;

  const ResonanceThreadService({required this.engine});

  Future<ResonanceThread> createThread({
    required String threadId,
    required String originatingExperienceId,
    String? originatingVoiceMark,
    required DateTime createdAt,
  }) async {
    if (threadId.trim().isEmpty) {
      throw ArgumentError.value(
        threadId,
        'threadId',
        'Thread id cannot be empty.',
      );
    }

    if (originatingExperienceId.trim().isEmpty) {
      throw ArgumentError.value(
        originatingExperienceId,
        'originatingExperienceId',
        'Originating experience id cannot be empty.',
      );
    }

    final existing = await engine.getThread(threadId);
    if (existing != null) {
      return existing;
    }

    final voiceMarks = originatingVoiceMark == null ||
            originatingVoiceMark.trim().isEmpty
        ? const <String>[]
        : <String>[originatingVoiceMark];

    final thread = ResonanceThread.create(
      id: threadId,
      originatingExperienceId: originatingExperienceId,
      experienceIds: [originatingExperienceId],
      voiceMarks: voiceMarks,
      createdAt: createdAt,
    );

    await engine.saveThread(thread);
    return thread;
  }

  /// Creates a Thread from an approved formation event.
  ///
  /// Unlike [createThread], this path requires the evidence that justified
  /// formation: at least two experiences and the connections that join them.
  /// That prevents the formation flow from creating a meaningless
  /// single-experience Thread.
  Future<ResonanceThread> createThreadFromFormation({
    required String threadId,
    required String originatingExperienceId,
    String? originatingVoiceMark,
    required List<String> experienceIds,
    List<String> voiceMarks = const [],
    required List<ResonanceConnection> connections,
    required DateTime createdAt,
  }) async {
    if (threadId.trim().isEmpty) {
      throw ArgumentError.value(
        threadId,
        'threadId',
        'Thread id cannot be empty.',
      );
    }

    if (originatingExperienceId.trim().isEmpty) {
      throw ArgumentError.value(
        originatingExperienceId,
        'originatingExperienceId',
        'Originating experience id cannot be empty.',
      );
    }

    final normalizedExperienceIds = experienceIds
        .where((id) => id.trim().isNotEmpty)
        .toList(growable: false);

    if (normalizedExperienceIds.length < 3) {
      throw ArgumentError.value(
        experienceIds,
        'experienceIds',
        'A formed Thread requires the originating experience and at least two connected experiences.',
      );
    }

    if (!normalizedExperienceIds.contains(originatingExperienceId)) {
      throw ArgumentError.value(
        experienceIds,
        'experienceIds',
        'Originating experience must belong to the Thread.',
      );
    }

    if (normalizedExperienceIds.toSet().length !=
        normalizedExperienceIds.length) {
      throw ArgumentError.value(
        experienceIds,
        'experienceIds',
        'A Thread cannot contain duplicate experiences.',
      );
    }

    final normalizedVoiceMarks = <String>[
      ...voiceMarks.where((mark) => mark.trim().isNotEmpty),
    ];
    if (originatingVoiceMark != null &&
        originatingVoiceMark.trim().isNotEmpty &&
        !normalizedVoiceMarks.contains(originatingVoiceMark)) {
      normalizedVoiceMarks.insert(0, originatingVoiceMark);
    }

    final uniqueConnectionIds = <String>{};
    for (final connection in connections) {
      if (!normalizedExperienceIds.contains(connection.sourceId) ||
          !normalizedExperienceIds.contains(connection.targetId)) {
        throw ArgumentError.value(
          connection.id,
          'connections',
          'Every formation connection must involve only Thread experiences.',
        );
      }

      if (connection.sourceId == connection.targetId) {
        throw ArgumentError.value(
          connection.id,
          'connections',
          'A Thread connection cannot connect an experience to itself.',
        );
      }

      if (!uniqueConnectionIds.add(connection.id)) {
        throw ArgumentError.value(
          connection.id,
          'connections',
          'A Thread cannot contain duplicate connections.',
        );
      }
    }

    final existing = await engine.getThread(threadId);
    if (existing != null) {
      return existing;
    }

    final thread = ResonanceThread.create(
      id: threadId,
      originatingExperienceId: originatingExperienceId,
      experienceIds: normalizedExperienceIds,
      voiceMarks: List.unmodifiable(normalizedVoiceMarks),
      connections: List.unmodifiable(connections),
      createdAt: createdAt,
    );

    await engine.saveThread(thread);
    return thread;
  }

  Future<ResonanceThread?> extendThread({
    required ResonanceThread thread,
    required String experienceId,
    String? voiceMark,
    required ResonanceConnection connection,
  }) async {
    if (experienceId.trim().isEmpty) {
      return null;
    }

    if (thread.containsExperience(experienceId)) {
      return thread;
    }

    final connectsToThread =
        thread.containsExperience(connection.sourceId) &&
                connection.targetId == experienceId ||
            thread.containsExperience(connection.targetId) &&
                connection.sourceId == experienceId;

    if (!connectsToThread) {
      return null;
    }

    final experienceIds = [
      ...thread.experienceIds,
      experienceId,
    ];
    final voiceMarks = [...thread.voiceMarks];
    if (voiceMark != null && voiceMark.trim().isNotEmpty) {
      if (!voiceMarks.contains(voiceMark)) {
        voiceMarks.add(voiceMark);
      }
    }

    final connections = [
      ...thread.connections,
    ];
    if (!thread.containsConnection(connection.id)) {
      connections.add(connection);
    }

    final updated = thread.copyWith(
      experienceIds: experienceIds,
      voiceMarks: voiceMarks,
      connections: connections,
    );

    await engine.saveThread(updated);
    return updated;
  }

  Future<ResonanceThread?> getThread(String threadId) {
    return engine.getThread(threadId);
  }

  Future<List<ResonanceThread>> getThreadsForExperience(
    String experienceId,
  ) {
    return engine.getThreadsForExperience(experienceId);
  }

  Future<List<ResonanceThread>> getThreads() {
    return engine.getThreads();
  }
}
