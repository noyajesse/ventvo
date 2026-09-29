import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/experience_thread.dart';
import '../services/experience_thread_storage.dart';

class ExperienceThreadNotifier
    extends AsyncNotifier<List<ExperienceThread>> {
  final ExperienceThreadStorage _storage = ExperienceThreadStorage();

  @override
  Future<List<ExperienceThread>> build() async {
    return _storage.load();
  }

  Future<void> _persist(List<ExperienceThread> threads) async {
    state = AsyncData(threads);
    await _storage.save(threads);
  }

  Future<void> createThread(ExperienceThread thread) async {
    if (thread.id.trim().isEmpty || thread.originCrashOutId.trim().isEmpty) {
      return;
    }

    final current = state.asData?.value ?? const <ExperienceThread>[];

    // A Crash Out owns at most one encounter thread. This also makes
    // re-entry safe if processing is triggered more than once.
    if (current.any(
      (item) =>
          item.id == thread.id ||
          item.originCrashOutId == thread.originCrashOutId,
    )) {
      return;
    }

    await _persist([...current, thread]);
  }

  ExperienceThread? threadForCrashOut(String crashOutId) {
    if (crashOutId.trim().isEmpty) return null;

    final current = state.asData?.value ?? const <ExperienceThread>[];
    for (final thread in current) {
      if (thread.originCrashOutId == crashOutId) {
        return thread;
      }
    }
    return null;
  }

  Future<void> deleteThreadForCrashOut(String crashOutId) async {
    if (crashOutId.trim().isEmpty) return;

    final current = state.asData?.value ?? const <ExperienceThread>[];
    final next = current
        .where((thread) => thread.originCrashOutId != crashOutId)
        .toList();

    if (next.length == current.length) return;
    await _persist(next);
  }

  Future<void> addContribution({
    required String threadId,
    required ExperienceContribution contribution,
  }) async {
    if (threadId.trim().isEmpty ||
        contribution.id.trim().isEmpty ||
        contribution.threadId != threadId ||
        contribution.content.trim().isEmpty) {
      return;
    }

    final current = state.asData?.value ?? const <ExperienceThread>[];
    final targetExists = current.any((thread) => thread.id == threadId);
    if (!targetExists) return;

    // Contribution IDs are unique within the local thread store.
    if (current.any(
      (thread) =>
          thread.contributions.any((item) => item.id == contribution.id),
    )) {
      return;
    }

    final updated = [
      for (final thread in current)
        if (thread.id == threadId)
          thread.copyWith(
            contributions: [...thread.contributions, contribution],
          )
        else
          thread,
    ];

    await _persist(updated);
  }

  Future<void> clearThreads() async {
    await _storage.clear();
    state = const AsyncData([]);
  }
}

final experienceThreadProvider =
    AsyncNotifierProvider<ExperienceThreadNotifier, List<ExperienceThread>>(
  ExperienceThreadNotifier.new,
);
