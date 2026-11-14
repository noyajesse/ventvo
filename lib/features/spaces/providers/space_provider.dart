import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/space.dart';
import '../services/space_storage.dart';

final spaceStorageProvider = Provider<SpaceStorage>((ref) {
  return SpaceStorage();
});

final spaceProvider =
    AsyncNotifierProvider<SpaceNotifier, List<Space>>(SpaceNotifier.new);

class SpaceNotifier extends AsyncNotifier<List<Space>> {
  SpaceStorage get _storage => ref.read(spaceStorageProvider);
  Future<void> _mutationQueue = Future<void>.value();

  @override
  Future<List<Space>> build() async => _storage.load();

  Future<T> _enqueueMutation<T>(Future<T> Function() action) {
    final completer = Completer<T>();

    _mutationQueue = _mutationQueue.then((_) async {
      try {
        final result = await action();
        if (!completer.isCompleted) {
          completer.complete(result);
        }
      } catch (error, stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      }
    });

    return completer.future;
  }

  Future<List<Space>> _currentSpaces() async {
    final existing = state.asData?.value;
    if (existing != null) {
      return List<Space>.from(existing);
    }
    return List<Space>.from(await future);
  }

  Future<void> _persist(List<Space> spaces) async {
    await _storage.save(spaces);
    state = AsyncData(List<Space>.unmodifiable(spaces));
  }

  Future<void> addSpace(Space space) {
    return _enqueueMutation(() async {
      final current = await _currentSpaces();
      await _persist([...current, space]);
    });
  }

  Future<void> updateSpace(Space space) {
    return _enqueueMutation(() async {
      final current = await _currentSpaces();
      final spaces = [
        for (final existing in current)
          if (existing.id == space.id) space else existing,
      ];
      await _persist(spaces);
    });
  }

  Future<void> addMoment(String spaceId, String ventId) {
    return _enqueueMutation(() async {
      final current = await _currentSpaces();
      final spaces = [
        for (final space in current)
          if (space.id == spaceId && !space.allVentIds.contains(ventId))
            Space(
              id: space.id,
              mode: space.mode,
              originatingVentId: space.originatingVentId,
              creatorVoiceMark: space.creatorVoiceMark,
              createdAt: space.createdAt,
              ventIds: [...space.allVentIds, ventId],
            )
          else
            space,
      ];
      await _persist(spaces);
    });
  }

  Future<void> removeSpace(String id) {
    return _enqueueMutation(() async {
      final current = await _currentSpaces();
      await _persist(current.where((space) => space.id != id).toList());
    });
  }

  Future<void> clearSpaces() {
    return _enqueueMutation(() async {
      await _storage.clear();
      state = const AsyncData([]);
    });
  }
}
