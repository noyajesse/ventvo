import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ventvo/features/crash_out/providers/crash_out_space_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('replies belong to a specific experience inside a Space', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(crashOutSpaceProvider.future);
    final notifier = container.read(crashOutSpaceProvider.notifier);

    await notifier.addReply(
      spaceId: 'attention',
      experienceId: 'experience-1',
      reply: CrashOutSpaceReply(
        id: 'reply-1',
        experienceId: 'experience-1',
        content: 'I see this differently.',
        createdAt: DateTime(2026, 1, 1),
      ),
    );

    expect(
      notifier.repliesFor('attention', 'experience-1'),
      hasLength(1),
    );
    expect(
      notifier.repliesFor('attention', 'experience-2'),
      isEmpty,
    );
    expect(
      notifier.repliesFor('connection', 'experience-1'),
      isEmpty,
    );
  });

  test('rejects duplicate reply IDs for the same experience', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(crashOutSpaceProvider.future);
    final notifier = container.read(crashOutSpaceProvider.notifier);
    final reply = CrashOutSpaceReply(
      id: 'reply-1',
      experienceId: 'experience-1',
      content: 'A reply.',
      createdAt: DateTime(2026, 1, 1),
    );

    await notifier.addReply(
      spaceId: 'attention',
      experienceId: 'experience-1',
      reply: reply,
    );
    await notifier.addReply(
      spaceId: 'attention',
      experienceId: 'experience-1',
      reply: reply,
    );

    expect(
      notifier.repliesFor('attention', 'experience-1'),
      hasLength(1),
    );
  });
}
