import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    await container.read(crashOutProvider.notifier).addCrashOut(crashOut);
    await container.read(crashOutProvider.notifier).keepPrivate(crashOut.id);

    var items = await container.read(crashOutProvider.future);
    expect(items.single.status, CrashOutStatus.keptPrivate);

    items = await container.read(crashOutProvider.future);
    expect(items.single.status, CrashOutStatus.keptPrivate);
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
}
