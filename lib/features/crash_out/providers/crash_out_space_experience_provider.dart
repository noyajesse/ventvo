import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ventvo_voice/models/vent.dart';
import '../models/crash_out_space_experience.dart';

/// Local-only source for experiences that have entered a Crash Out Space.
/// This is a frontend prototype store, not shared or realtime community data.
class CrashOutSpaceExperienceNotifier
    extends AsyncNotifier<List<CrashOutSpaceExperience>> {
  static const _storageKey = 'ventvo_crash_out_space_experiences';

  // Serialize mutations so overlapping additions and deletion stay consistent.
  Future<void> _mutationQueue = Future<void>.value();

  Future<T> _runMutation<T>(Future<T> Function() mutation) {
    final result = _mutationQueue.then((_) => mutation());
    _mutationQueue = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );
    return result;
  }

  @override
  Future<List<CrashOutSpaceExperience>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((item) => CrashOutSpaceExperience.fromMap(
                Map<String, dynamic>.from(item),
              ))
          .whereType<CrashOutSpaceExperience>()
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<CrashOutSpaceExperience>> _currentExperiences() async {
    final current = state.asData?.value;
    if (current != null) return current;
    return future;
  }

  List<CrashOutSpaceExperience> experiencesFor(String spaceId) {
    final current = state.asData?.value ?? const <CrashOutSpaceExperience>[];
    final result = current.where((item) => item.spaceId == spaceId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  Future<bool> _persist(
    List<CrashOutSpaceExperience> experiences,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await prefs.setString(
      _storageKey,
      jsonEncode(experiences.map((item) => item.toMap()).toList()),
    );
    if (!saved) return false;
    state = AsyncData(experiences);
    return true;
  }

  /// Adds the discovered public opposite as the Space's initial doorway
  /// experience. Further Space content uses this separate local domain model.
  Future<CrashOutSpaceExperience> ensureFromVent({
    required String spaceId,
    required Vent vent,
  }) {
    return _runMutation(() async {
      final current = await _currentExperiences();
      final id = 'opposing_experience_\${vent.id}';
      for (final existing in current) {
        if (existing.id == id && existing.spaceId == spaceId) return existing;
      }

      final experience = CrashOutSpaceExperience(
        id: id,
        spaceId: spaceId,
        content: vent.content,
        createdAt: vent.createdAt,
        voiceName: vent.voiceName,
        voiceMark: vent.voiceMark,
        sourceExperienceId: vent.id,
      );
      if (!await _persist([...current, experience])) {
        throw StateError(
          'Failed to persist the Crash Out Space doorway locally.',
        );
      }
      return experience;
    });
  }

  /// Adds missing local preview examples without duplicating existing content.
  ///
  /// These examples make the Space's intended multi-experience layout testable
  /// before shared backend data exists. They are visibly identified as samples
  /// in the UI and must never be treated as real user contributions.
  Future<void> ensurePrototypeExperiences(
    List<CrashOutSpaceExperience> prototypes,
  ) {
    if (prototypes.isEmpty) return Future<void>.value();

    return _runMutation(() async {
      final current = await _currentExperiences();
      final knownKeys =
          current.map((item) => '\${item.spaceId}::\${item.id}').toSet();
      final additions = <CrashOutSpaceExperience>[];

      for (final item in prototypes) {
        final key = '\${item.spaceId}::\${item.id}';
        if (item.id.trim().isEmpty ||
            item.spaceId.trim().isEmpty ||
            item.content.trim().isEmpty ||
            !knownKeys.add(key)) {
          continue;
        }
        additions.add(item);
      }

      if (additions.isEmpty) return;
      if (!await _persist([...current, ...additions])) {
        throw StateError(
          'Failed to persist Crash Out Space preview experiences locally.',
        );
      }
    });
  }

  Future<void> addExperience(CrashOutSpaceExperience experience) {
    return _runMutation(() async {
      if (experience.id.trim().isEmpty ||
          experience.spaceId.trim().isEmpty ||
          experience.content.trim().isEmpty) {
        return;
      }
      final current = await _currentExperiences();
      if (current.any((item) =>
          item.id == experience.id && item.spaceId == experience.spaceId)) {
        return;
      }
      if (!await _persist([...current, experience])) {
        throw StateError('Failed to persist Crash Out Space experience locally.');
      }
    });
  }

  Future<void> clearExperiences() {
    return _runMutation(() async {
      await _currentExperiences();
      final prefs = await SharedPreferences.getInstance();
      final existed = prefs.containsKey(_storageKey);
      final removed = await prefs.remove(_storageKey);
      if (existed && !removed) {
        throw StateError('Failed to clear Crash Out Space experiences locally.');
      }
      state = const AsyncData([]);
    });
  }
}

final crashOutSpaceExperienceProvider = AsyncNotifierProvider<
    CrashOutSpaceExperienceNotifier, List<CrashOutSpaceExperience>>(
  CrashOutSpaceExperienceNotifier.new,
);
