import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
// The platform store lets this test simulate a local write failure.
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

import 'package:ventvo/features/crash_out/models/crash_out.dart';
import 'package:ventvo/features/crash_out/providers/crash_out_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('new Crash Out is private by default', () {
    final crashOut = CrashOut(
      id: 'crash-1',
      textContent: 'Something I needed to let out.',
      type: CrashOutType.text,
      createdAt: DateTime(2026, 1, 1),
    );

    expect(crashOut.status, CrashOutStatus.keptPrivate);
  });

  test('Crash Out can remain private after an encounter', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final crashOut = CrashOut(
      id: 'crash-1',
      textContent: 'Something I needed to let out.',
      type: CrashOutType.text,
      createdAt: DateTime(2026, 1, 1),
    );

    final notifier = container.read(crashOutProvider.notifier);
    await notifier.addCrashOut(crashOut);
    await notifier.markSpaceEntered(crashOut.id);
    await notifier.keepPrivate(crashOut.id);

    final items = await container.read(crashOutProvider.future);
    expect(items.single.status, CrashOutStatus.spaceEntered);
    expect(items.single.status.isPrivate, isTrue);
  });

  test('letting go removes the Crash Out', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final crashOut = CrashOut(
      id: 'crash-2',
      textContent: 'I am letting this one go.',
      type: CrashOutType.text,
      createdAt: DateTime(2026, 1, 2),
    );

    await container.read(crashOutProvider.notifier).addCrashOut(crashOut);
    await container.read(crashOutProvider.notifier).deleteCrashOut(crashOut.id);

    final items = await container.read(crashOutProvider.future);
    expect(items, isEmpty);
  });

  test(
    'entering a wider Space records the lifecycle and keeps the Crash Out private',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(crashOutProvider.future);
      final notifier = container.read(crashOutProvider.notifier);
      final crashOut = CrashOut(
        id: 'crash-space-1',
        ownerVoiceId: 'voice-owner-1',
        textContent: 'I needed another perspective.',
        type: CrashOutType.text,
        createdAt: DateTime(2026, 1, 3),
      );

      await notifier.addCrashOut(crashOut);
      await notifier.markSpaceEntered(crashOut.id);

      final items = await container.read(crashOutProvider.future);
      expect(items.single.status, CrashOutStatus.spaceEntered);
      expect(items.single.status.isPrivate, isTrue);
      expect(items.single.ownerVoiceId, 'voice-owner-1');

      final reloadedContainer = ProviderContainer();
      addTearDown(reloadedContainer.dispose);
      final reloaded = await reloadedContainer.read(crashOutProvider.future);
      expect(reloaded.single.status, CrashOutStatus.spaceEntered);
      expect(reloaded.single.ownerVoiceId, 'voice-owner-1');
    },
  );

  test(
    'legacy Crash Outs without a Voice ID remain private and loadable',
    () async {
      SharedPreferences.setMockInitialValues({
        'ventvo_crash_outs':
            '[{"id":"legacy-1","textContent":"Old local entry","type":"text","createdAt":"2026-01-04T00:00:00.000","status":"keptPrivate"}]',
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final items = await container.read(crashOutProvider.future);
      expect(items.single.ownerVoiceId, isNull);
      expect(items.single.status, CrashOutStatus.keptPrivate);
      expect(items.single.status.isPrivate, isTrue);
    },
  );

  test(
    'an early add preserves Crash Outs while the initial local load is pending',
    () async {
      SharedPreferences.setMockInitialValues({
        'ventvo_crash_outs':
            '[{"id":"saved-1","textContent":"Already saved","type":"text","createdAt":"2026-01-05T00:00:00.000","status":"keptPrivate"}]',
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(crashOutProvider.notifier);

      await notifier.addCrashOut(
        CrashOut(
          id: 'new-1',
          ownerVoiceId: 'voice-1',
          textContent: 'New entry',
          type: CrashOutType.text,
          createdAt: DateTime(2026, 1, 6),
        ),
      );

      final items = await container.read(crashOutProvider.future);
      expect(items.map((item) => item.id), containsAll(['saved-1', 'new-1']));
      expect(items, hasLength(2));
    },
  );

  test('concurrent additions do not overwrite one another', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(crashOutProvider.future);
    final notifier = container.read(crashOutProvider.notifier);

    await Future.wait([
      notifier.addCrashOut(
        CrashOut(
          id: 'concurrent-1',
          textContent: 'First concurrent entry.',
          type: CrashOutType.text,
          createdAt: DateTime(2026, 1, 7),
        ),
      ),
      notifier.addCrashOut(
        CrashOut(
          id: 'concurrent-2',
          textContent: 'Second concurrent entry.',
          type: CrashOutType.text,
          createdAt: DateTime(2026, 1, 8),
        ),
      ),
    ]);

    final items = await container.read(crashOutProvider.future);
    expect(items.map((item) => item.id),
        containsAll(['concurrent-1', 'concurrent-2']));
    expect(items, hasLength(2));
  });

  test('failed local save does not publish an unsaved Crash Out', () async {
    final store = _FailingSharedPreferencesStore();
    SharedPreferencesStorePlatform.instance = store;

    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(crashOutProvider.future);
    final notifier = container.read(crashOutProvider.notifier);

    await expectLater(
      notifier.addCrashOut(
        CrashOut(
          id: 'not-saved',
          textContent: 'This must not appear as saved.',
          type: CrashOutType.text,
          createdAt: DateTime(2026, 1, 9),
        ),
      ),
      throwsA(isA<StateError>()),
    );

    final currentState = container.read(crashOutProvider);
    expect(currentState.asData!.value, isEmpty);
    expect(store.values, isEmpty);
  });
}

class _FailingSharedPreferencesStore extends SharedPreferencesStorePlatform {
  final Map<String, Object> values = {};

  @override
  Future<Map<String, Object>> getAll() async => Map<String, Object>.of(values);

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    throw StateError('simulated local persistence failure');
  }

  @override
  Future<bool> remove(String key) async => values.remove(key) != null;

  @override
  Future<bool> clear() async {
    values.clear();
    return true;
  }
}
