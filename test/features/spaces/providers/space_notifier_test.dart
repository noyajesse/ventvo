import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ventvo/features/spaces/models/space.dart';
import 'package:ventvo/features/spaces/providers/space_provider.dart';
import 'package:ventvo/features/spaces/services/space_storage.dart';

class FakeSpaceStorage extends SpaceStorage {
  FakeSpaceStorage({
    List<Space> initialSpaces = const [],
    this.loadCompleter,
    this.failOnSave = false,
    this.failOnClear = false,
  }) : _spaces = List<Space>.from(initialSpaces);

  List<Space> _spaces;
  final Completer<void>? loadCompleter;
  bool failOnSave;
  bool failOnClear;

  List<Space> get persistedSpaces => List<Space>.unmodifiable(_spaces);

  @override
  Future<List<Space>> load() async {
    if (loadCompleter != null) {
      await loadCompleter!.future;
    }
    return List<Space>.from(_spaces);
  }

  @override
  Future<void> save(List<Space> spaces) async {
    await Future<void>.delayed(const Duration(milliseconds: 5));
    if (failOnSave) {
      throw StateError('Simulated storage write failure');
    }
    _spaces = List<Space>.from(spaces);
  }

  @override
  Future<void> clear() async {
    await Future<void>.delayed(const Duration(milliseconds: 5));
    if (failOnClear) {
      throw StateError('Simulated storage clear failure');
    }
    _spaces = [];
  }
}

Space _buildSpace(
  String id, {
  SpaceMode mode = SpaceMode.openDiscussion,
  List<String> ventIds = const [],
}) {
  return Space(
    id: id,
    mode: mode,
    originatingVentId: 'vent-$id',
    creatorVoiceMark: '◇',
    createdAt: DateTime.utc(2026, 11, 14),
    ventIds: ventIds,
  );
}

void main() {
  group('SpaceNotifier data integrity', () {
    test('waits for initial async load before mutating so existing spaces are preserved', () async {
      final loadCompleter = Completer<void>();
      final existing = _buildSpace('space-existing');
      final storage = FakeSpaceStorage(
        initialSpaces: [existing],
        loadCompleter: loadCompleter,
      );

      final container = ProviderContainer(
        overrides: [spaceStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);

      final initialRead = container.read(spaceProvider.future);
      final added = _buildSpace('space-new');
      final addFuture = container.read(spaceProvider.notifier).addSpace(added);

      loadCompleter.complete();
      await initialRead;
      await addFuture;

      final current = container.read(spaceProvider).requireValue;
      expect(current.map((s) => s.id), ['space-existing', 'space-new']);
      expect(storage.persistedSpaces.map((s) => s.id), ['space-existing', 'space-new']);
    });

    test('serializes concurrent mutations without overwriting updates', () async {
      final initial = _buildSpace('space-1');
      final storage = FakeSpaceStorage(initialSpaces: [initial]);

      final container = ProviderContainer(
        overrides: [spaceStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);

      await container.read(spaceProvider.future);
      final notifier = container.read(spaceProvider.notifier);

      await Future.wait([
        notifier.addMoment('space-1', 'vent-2'),
        notifier.addMoment('space-1', 'vent-3'),
        notifier.addSpace(_buildSpace('space-2')),
      ]);

      final current = container.read(spaceProvider).requireValue;
      expect(current.map((s) => s.id), ['space-1', 'space-2']);
      expect(current.first.allVentIds, ['vent-space-1', 'vent-2', 'vent-3']);
      expect(storage.persistedSpaces.first.allVentIds, ['vent-space-1', 'vent-2', 'vent-3']);
    });

    test('does not publish optimistic state when storage write fails', () async {
      final initial = _buildSpace('space-1');
      final storage = FakeSpaceStorage(initialSpaces: [initial]);

      final container = ProviderContainer(
        overrides: [spaceStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);

      await container.read(spaceProvider.future);
      storage.failOnSave = true;

      await expectLater(
        container.read(spaceProvider.notifier).addSpace(_buildSpace('space-2')),
        throwsStateError,
      );

      final stateAfterFailure = container.read(spaceProvider).requireValue;
      expect(stateAfterFailure.map((s) => s.id), ['space-1']);
      expect(storage.persistedSpaces.map((s) => s.id), ['space-1']);
    });

    test('does not clear state when storage clear fails', () async {
      final initial = _buildSpace('space-1');
      final storage = FakeSpaceStorage(initialSpaces: [initial]);

      final container = ProviderContainer(
        overrides: [spaceStorageProvider.overrideWithValue(storage)],
      );
      addTearDown(container.dispose);

      await container.read(spaceProvider.future);
      storage.failOnClear = true;

      await expectLater(
        container.read(spaceProvider.notifier).clearSpaces(),
        throwsStateError,
      );

      final stateAfterFailure = container.read(spaceProvider).requireValue;
      expect(stateAfterFailure.map((s) => s.id), ['space-1']);
      expect(storage.persistedSpaces.map((s) => s.id), ['space-1']);
    });
  });
}
