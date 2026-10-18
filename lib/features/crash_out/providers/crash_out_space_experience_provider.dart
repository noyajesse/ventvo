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

  List<CrashOutSpaceExperience> experiencesFor(String spaceId) {
    final current = state.asData?.value ?? const <CrashOutSpaceExperience>[];
    final result = current.where((item) => item.spaceId == spaceId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  /// Adds the discovered public opposite as the Space's initial doorway
  /// experience. Further Space content uses this separate local domain model.
  Future<CrashOutSpaceExperience> ensureFromVent({
    required String spaceId,
    required Vent vent,
  }) async {
    final current = state.asData?.value ?? const <CrashOutSpaceExperience>[];
    final id = 'opposing_experience_${vent.id}';
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
    await _persist([...current, experience]);
    return experience;
  }

  /// Adds missing local preview examples without duplicating existing content.
  ///
  /// These examples make the Space's intended multi-experience layout testable
  /// before shared backend data exists. They are visibly identified as samples
  /// in the UI and must never be treated as real user contributions.
  Future<void> ensurePrototypeExperiences(
    List<CrashOutSpaceExperience> prototypes,
  ) async {
    final current = state.asData?.value ?? const <CrashOutSpaceExperience>[];
    final knownIds = current.map((item) => item.id).toSet();
    final additions = <CrashOutSpaceExperience>[];

    // Track IDs as each item is accepted so duplicates inside the same fixture
    // batch cannot be appended twice.
    for (final item in prototypes) {
      if (item.id.trim().isEmpty ||
          item.spaceId.trim().isEmpty ||
          item.content.trim().isEmpty ||
          !knownIds.add(item.id)) {
        continue;
      }
      additions.add(item);
    }

    if (additions.isEmpty) return;
    await _persist([...current, ...additions]);
  }

  Future<void> addExperience(CrashOutSpaceExperience experience) async {
    if (experience.id.trim().isEmpty ||
        experience.spaceId.trim().isEmpty ||
        experience.content.trim().isEmpty) {
      return;
    }
    final current = state.asData?.value ?? const <CrashOutSpaceExperience>[];
    if (current.any((item) =>
        item.id == experience.id && item.spaceId == experience.spaceId)) {
      return;
    }
    await _persist([...current, experience]);
  }

  Future<void> _persist(List<CrashOutSpaceExperience> experiences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(experiences.map((item) => item.toMap()).toList()),
    );
    state = AsyncData(experiences);
  }

  Future<void> clearExperiences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    state = const AsyncData([]);
  }
}

final crashOutSpaceExperienceProvider = AsyncNotifierProvider<
    CrashOutSpaceExperienceNotifier, List<CrashOutSpaceExperience>>(
  CrashOutSpaceExperienceNotifier.new,
);
