import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ventvo/features/crash_out/providers/crash_out_space_provider.dart';
import 'package:ventvo/features/crash_out/models/crash_out_space_experience.dart';
import 'package:ventvo/features/crash_out/providers/crash_out_space_experience_provider.dart';
import 'package:ventvo/features/ventvo_voice/models/vent.dart';

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

  test('Space experiences are stored independently from the Vent model', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(crashOutSpaceExperienceProvider.future);
    final notifier =
        container.read(crashOutSpaceExperienceProvider.notifier);
    final vent = Vent(
      id: 'public-vent-1',
      content: 'I need people to check on me.',
      spaceId: 'open-discussion',
      voiceMark: '◇',
      voiceName: 'Nova',
      createdAt: DateTime(2026, 1, 1),
    );

    final doorway = await notifier.ensureFromVent(
      spaceId: 'attention',
      vent: vent,
    );

    expect(doorway.id, 'opposing_experience_public-vent-1');
    expect(doorway.sourceExperienceId, vent.id);
    expect(notifier.experiencesFor('attention'), hasLength(1));
    expect(notifier.experiencesFor('connection'), isEmpty);
  });

  test('Space doorway is not duplicated when revisited', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(crashOutSpaceExperienceProvider.future);
    final notifier =
        container.read(crashOutSpaceExperienceProvider.notifier);
    final vent = Vent(
      id: 'public-vent-2',
      content: 'I need room to be alone.',
      spaceId: 'open-discussion',
      voiceMark: '◇',
      createdAt: DateTime(2026, 1, 2),
    );

    final first = await notifier.ensureFromVent(
      spaceId: 'connection',
      vent: vent,
    );
    final second = await notifier.ensureFromVent(
      spaceId: 'connection',
      vent: vent,
    );

    expect(first.id, second.id);
    expect(notifier.experiencesFor('connection'), hasLength(1));
  });

  test('invalid Space experience content is ignored', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(crashOutSpaceExperienceProvider.future);
    final notifier =
        container.read(crashOutSpaceExperienceProvider.notifier);
    await notifier.addExperience(
      CrashOutSpaceExperience(
        id: 'empty',
        spaceId: 'attention',
        content: '   ',
        createdAt: DateTime(2026, 1, 1),
      ),
    );

    expect(notifier.experiencesFor('attention'), isEmpty);
  });

}
