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
    final current = state.asData?.value ?? const <ExperienceThread>[];
    await _persist([...current, thread]);
  }

  ExperienceThread? threadForCrashOut(String crashOutId) {
    final current = state.asData?.value ?? const <ExperienceThread>[];
    for (final thread in current) {
      if (thread.originCrashOutId == crashOutId) {
        return thread;
      }
    }
    return null;
  }

  Future<void> addContribution({
    required String threadId,
    required ExperienceContribution contribution,
  }) async {
    final current = state.asData?.value ?? const <ExperienceThread>[];

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
