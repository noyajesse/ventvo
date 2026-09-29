import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ventvo/features/crash_out/models/experience_thread.dart';
import 'package:ventvo/features/crash_out/providers/experience_thread_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  ExperienceThread thread({
    String id = 'thread-1',
    String crashOutId = 'crash-1',
  }) {
    return ExperienceThread(
      id: id,
      originCrashOutId: crashOutId,
      createdAt: DateTime(2026, 1, 1),
      contributions: [
        ExperienceContribution(
          id: '$id-origin',
          threadId: id,
          content: 'The original experience.',
          type: ExperienceContributionType.origin,
          createdAt: DateTime(2026, 1, 1),
        ),
      ],
    );
  }

  test('creates one thread and rejects duplicate thread ownership', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(experienceThreadProvider.notifier);

    await notifier.createThread(thread());

    await notifier.createThread(
      thread(id: 'thread-2', crashOutId: 'crash-1'),
    );
    await notifier.createThread(
      thread(id: 'thread-1', crashOutId: 'crash-2'),
    );

    final items = await container.read(experienceThreadProvider.future);

    expect(items, hasLength(1));
    expect(items.single.id, 'thread-1');
    expect(items.single.originCrashOutId, 'crash-1');
  });

  test('rejects contributions for missing or mismatched threads', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(experienceThreadProvider.notifier);
    await notifier.createThread(thread());

    await notifier.addContribution(
      threadId: 'missing',
      contribution: ExperienceContribution(
        id: 'bad-1',
        threadId: 'missing',
        content: 'Should not be stored.',
        type: ExperienceContributionType.response,
        createdAt: DateTime(2026, 1, 2),
      ),
    );

    await notifier.addContribution(
      threadId: 'thread-1',
      contribution: ExperienceContribution(
        id: 'bad-2',
        threadId: 'other-thread',
        content: 'Should not be stored.',
        type: ExperienceContributionType.response,
        createdAt: DateTime(2026, 1, 2),
      ),
    );

    final items = await container.read(experienceThreadProvider.future);

    expect(items.single.contributions, hasLength(1));
  });

  test('rejects duplicate contribution IDs', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(experienceThreadProvider.notifier);
    await notifier.createThread(thread());

    final contribution = ExperienceContribution(
      id: 'response-1',
      threadId: 'thread-1',
      content: 'A response.',
      type: ExperienceContributionType.response,
      createdAt: DateTime(2026, 1, 2),
    );

    await notifier.addContribution(
      threadId: 'thread-1',
      contribution: contribution,
    );
    await notifier.addContribution(
      threadId: 'thread-1',
      contribution: contribution,
    );

    final items = await container.read(experienceThreadProvider.future);

    expect(items.single.contributions, hasLength(2));
  });

  test('deleting a Crash Out thread removes its encounter thread', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(experienceThreadProvider.notifier);
    await notifier.createThread(thread());

    expect(notifier.threadForCrashOut('crash-1'), isNotNull);

    await notifier.deleteThreadForCrashOut('crash-1');

    final items = await container.read(experienceThreadProvider.future);

    expect(items, isEmpty);
    expect(notifier.threadForCrashOut('crash-1'), isNull);
  });
}
