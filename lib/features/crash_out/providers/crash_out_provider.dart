import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/crash_out.dart';
import '../services/crash_out_storage.dart';

class CrashOutNotifier extends AsyncNotifier<List<CrashOut>> {
  final CrashOutStorage _storage = CrashOutStorage();

  // Serialize local mutations so overlapping actions cannot overwrite one
  // another using the same stale snapshot.
  Future<void> _mutationQueue = Future<void>.value();

  Future<T> _runMutation<T>(Future<T> Function() mutation) {
    final result = _mutationQueue.then((_) => mutation());
    // A failed mutation must not permanently block later user actions.
    _mutationQueue = result.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );
    return result;
  }

  @override
  Future<List<CrashOut>> build() async {
    return _storage.load();
  }

  Future<List<CrashOut>> _currentCrashOuts() async {
    final current = state.asData?.value;
    if (current != null) return current;

    // Await this notifier's build result directly. Reading crashOutProvider
    // through ref here would create a forbidden self-dependency.
    return future;
  }

  Future<void> _persist(List<CrashOut> crashOuts) async {
    // Do not publish a state transition until local persistence succeeds.
    await _storage.save(crashOuts);
    state = AsyncData(crashOuts);
  }

  Future<void> addCrashOut(CrashOut crashOut) {
    return _runMutation(() async {
      if (crashOut.id.trim().isEmpty) return;

      final current = await _currentCrashOuts();
      if (current.any((item) => item.id == crashOut.id)) return;
      await _persist([...current, crashOut]);
    });
  }

  /// Keeps the original Crash Out private. Entering a Space never publishes it.
  Future<void> keepPrivate(String id) async {
    if (id.trim().isEmpty) return;

    final current = await _currentCrashOuts();
    // Both keptPrivate and spaceEntered are private lifecycle states.
    // This operation intentionally does not erase the fact that a Space
    // was previously entered.
    if (!current.any((item) => item.id == id)) return;
  }

  /// Records that the owner entered the wider tension Space.
  ///
  /// The Crash Out itself remains private; only its lifecycle marker changes.
  Future<void> markSpaceEntered(
    String id, {
    required String spaceId,
    String? matchedExperienceId,
  }) {
    return _runMutation(() async {
      if (id.trim().isEmpty || spaceId.trim().isEmpty) return;

      final current = await _currentCrashOuts();
      final index = current.indexWhere((item) => item.id == id);
      if (index == -1) return;

      final existing = current[index];
      if (existing.status == CrashOutStatus.spaceEntered &&
          existing.spaceId == spaceId &&
          existing.matchedExperienceId == matchedExperienceId) {
        return;
      }

      final updated = [...current];
      updated[index] = existing.copyWith(
        status: CrashOutStatus.spaceEntered,
        spaceId: spaceId,
        matchedExperienceId: matchedExperienceId,
        clearMatchedExperienceId: matchedExperienceId == null,
      );
      await _persist(updated);
    });
  }

  Future<void> deleteCrashOut(String id) {
    return _runMutation(() async {
      if (id.trim().isEmpty) return;

      final current = await _currentCrashOuts();
      final updated = current.where((item) => item.id != id).toList();
      if (updated.length == current.length) return;
      await _persist(updated);
    });
  }

  Future<void> clearCrashOuts() {
    return _runMutation(() async {
      await _storage.clear();
      state = const AsyncData([]);
    });
  }
}

final crashOutProvider =
    AsyncNotifierProvider<CrashOutNotifier, List<CrashOut>>(
  CrashOutNotifier.new,
);
