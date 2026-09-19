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

  test('Crash Out lifecycle can move from private to converted', () async {
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

    await container
        .read(crashOutProvider.notifier)
        .markConvertedToVent(crashOut.id);

    items = await container.read(crashOutProvider.future);
    expect(items.single.status, CrashOutStatus.convertedToVent);
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
}
