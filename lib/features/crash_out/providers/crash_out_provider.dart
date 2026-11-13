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

  /// Returns private records owned by [ownerVoiceId].
  ///
  /// Records without an owner are legacy entries from the single-Voice local
  /// prototype. They remain visible for compatibility until explicitly
  /// claimed by the current local Voice through an owner-scoped mutation.
  List<CrashOut> privateCrashOutsForOwner(String ownerVoiceId) {
    if (ownerVoiceId.trim().isEmpty) return const [];

    final current = state.asData?.value ?? const <CrashOut>[];
    return current
        .where((item) =>
            item.status.isPrivate &&
            (item.ownerVoiceId == ownerVoiceId || item.ownerVoiceId == null))
        .toList();
  }

  bool _belongsToOwner(CrashOut crashOut, String ownerVoiceId) =>
      crashOut.ownerVoiceId == ownerVoiceId || crashOut.ownerVoiceId == null;

  Future<void> addCrashOut(CrashOut crashOut) {
    return _runMutation(() async {
      final ownerVoiceId = crashOut.ownerVoiceId?.trim();
      if (crashOut.id.trim().isEmpty ||
          ownerVoiceId == null ||
          ownerVoiceId.isEmpty) return;

      final current = await _currentCrashOuts();
      if (current.any((item) => item.id == crashOut.id)) return;
      await _persist([...current, crashOut]);
    });
  }

  /// Keeps the original Crash Out private without changing its lifecycle.
  Future<void> keepPrivate(
    String id, {
    required String ownerVoiceId,
  }) async {
    if (id.trim().isEmpty || ownerVoiceId.trim().isEmpty) return;

    final current = await _currentCrashOuts();
    final target = current.where((item) => item.id == id);
    if (target.isEmpty || !_belongsToOwner(target.first, ownerVoiceId)) return;
  }

  /// Records entry into the wider tension Space without publishing the source.
  Future<bool> markSpaceEntered(
    String id, {
    required String ownerVoiceId,
    required String spaceId,
    String? matchedExperienceId,
  }) {
    return _runMutation(() async {
      if (id.trim().isEmpty ||
          ownerVoiceId.trim().isEmpty ||
          spaceId.trim().isEmpty) {
        return false;
      }

      final current = await _currentCrashOuts();
      final index = current.indexWhere((item) => item.id == id);
      if (index == -1) return false;

      final existing = current[index];
      if (!_belongsToOwner(existing, ownerVoiceId)) return false;
      if (existing.status == CrashOutStatus.spaceEntered &&
          existing.spaceId == spaceId &&
          existing.matchedExperienceId == matchedExperienceId &&
          existing.ownerVoiceId == ownerVoiceId) {
        return true;
      }

      final updated = [...current];
      updated[index] = existing.copyWith(
        ownerVoiceId: ownerVoiceId,
        status: CrashOutStatus.spaceEntered,
        spaceId: spaceId,
        matchedExperienceId: matchedExperienceId,
        clearMatchedExperienceId: matchedExperienceId == null,
      );
      await _persist(updated);
      return true;
    });
  }

  Future<bool> deleteCrashOut(
    String id, {
    required String ownerVoiceId,
  }) {
    return _runMutation(() async {
      if (id.trim().isEmpty || ownerVoiceId.trim().isEmpty) return false;

      final current = await _currentCrashOuts();
      final target = current.where((item) => item.id == id);
      if (target.isEmpty || !_belongsToOwner(target.first, ownerVoiceId)) {
        return false;
      }

      final updated = current.where((item) => item.id != id).toList();
      await _persist(updated);
      return true;
    });
  }

  Future<void> clearCrashOuts({required String ownerVoiceId}) {
    return _runMutation(() async {
      if (ownerVoiceId.trim().isEmpty) return;

      final current = await _currentCrashOuts();
      final remaining = current
          .where((item) => !_belongsToOwner(item, ownerVoiceId))
          .toList();
      if (remaining.length == current.length) return;
      await _persist(remaining);
    });
  }
}

final crashOutProvider =
    AsyncNotifierProvider<CrashOutNotifier, List<CrashOut>>(
  CrashOutNotifier.new,
);
