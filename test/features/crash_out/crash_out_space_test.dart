import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
// The store platform is the narrowest seam for simulating a real write failure.
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

import 'package:ventvo/features/crash_out/data/crash_out_space_prototype_data.dart';
import 'package:ventvo/features/crash_out/models/crash_out.dart';
import 'package:ventvo/features/crash_out/models/crash_out_space_experience.dart';
import 'package:ventvo/features/crash_out/models/experience_representation.dart';
import 'package:ventvo/features/crash_out/providers/crash_out_space_experience_provider.dart';
import 'package:ventvo/features/crash_out/providers/crash_out_space_provider.dart';
import 'package:ventvo/features/crash_out/services/crash_out_experience_interpreter.dart';
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
    final duplicateAccepted = await notifier.addReply(
      spaceId: 'attention',
      experienceId: 'experience-1',
      reply: reply,
    );

    expect(duplicateAccepted, isFalse);
    expect(
      notifier.repliesFor('attention', 'experience-1'),
      hasLength(1),
    );
  });

  test('rejected reply-to-reply references report failure without saving', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(crashOutSpaceProvider.future);
    final notifier = container.read(crashOutSpaceProvider.notifier);
    final accepted = await notifier.addReply(
      spaceId: 'attention',
      experienceId: 'experience-1',
      reply: CrashOutSpaceReply(
        id: 'orphan-reply',
        experienceId: 'experience-1',
        content: 'This should not be saved.',
        createdAt: DateTime(2026, 1, 1),
        replyToId: 'missing-parent',
      ),
    );

    expect(accepted, isFalse);
    expect(notifier.repliesFor('attention', 'experience-1'), isEmpty);
  });

  test('reply-to-reply stays within its original experience', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(crashOutSpaceProvider.future);
    final notifier = container.read(crashOutSpaceProvider.notifier);

    expect(
      await notifier.addReply(
        spaceId: 'attention',
        experienceId: 'experience-1',
        reply: CrashOutSpaceReply(
          id: 'parent-reply',
          experienceId: 'experience-1',
          content: 'The parent reply.',
          createdAt: DateTime(2026, 1, 1),
        ),
      ),
      isTrue,
    );

    expect(
      await notifier.addReply(
        spaceId: 'attention',
        experienceId: 'experience-2',
        reply: CrashOutSpaceReply(
          id: 'cross-experience-reply',
          experienceId: 'experience-2',
          content: 'This must not attach to another experience.',
          createdAt: DateTime(2026, 1, 1),
          replyToId: 'parent-reply',
        ),
      ),
      isFalse,
    );

    expect(
      await notifier.addReply(
        spaceId: 'attention',
        experienceId: 'experience-1',
        reply: CrashOutSpaceReply(
          id: 'child-reply',
          experienceId: 'experience-1',
          content: 'A valid continued reply.',
          createdAt: DateTime(2026, 1, 1),
          replyToId: 'parent-reply',
        ),
      ),
      isTrue,
    );

    expect(
      notifier.repliesFor('attention', 'experience-1').map((reply) => reply.id),
      ['parent-reply', 'child-reply'],
    );
    expect(notifier.repliesFor('attention', 'experience-2'), isEmpty);
  });

  test('accepted replies survive a provider reload', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(crashOutSpaceProvider.future);
    final notifier = container.read(crashOutSpaceProvider.notifier);

    final accepted = await notifier.addReply(
      spaceId: 'attention',
      experienceId: 'experience-1',
      reply: CrashOutSpaceReply(
        id: 'persisted-reply',
        experienceId: 'experience-1',
        content: 'This reply should remain after reload.',
        createdAt: DateTime(2026, 1, 1),
      ),
    );
    expect(accepted, isTrue);

    final restoredContainer = ProviderContainer();
    addTearDown(restoredContainer.dispose);
    await restoredContainer.read(crashOutSpaceProvider.future);

    expect(
      restoredContainer
          .read(crashOutSpaceProvider.notifier)
          .repliesFor('attention', 'experience-1')
          .map((reply) => reply.content),
      contains('This reply should remain after reload.'),
    );
  });

  testWidgets(
    'preserves draft and reply target when local reply persistence throws',
    (tester) async {
      const spaceId = 'attention';
      const experienceId = 'experience-1';
      const parentReplyId = 'parent-reply';
      const storageKey = 'flutter.ventvo_crash_out_space_replies';
      const draft = '  Keep this exact draft.  ';
      final parentReply = CrashOutSpaceReply(
        id: parentReplyId,
        experienceId: experienceId,
        content: 'The existing reply.',
        createdAt: DateTime(2026, 1, 1),
      );
      final store = _FailingSharedPreferencesStore({
        storageKey: jsonEncode({
          '$spaceId::$experienceId': [parentReply.toMap()],
        }),
      });
      SharedPreferencesStorePlatform.instance = store;

      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: CrashOutSpaceScreen(
              tension: HumanTension.attention,
              experiences: [
                CrashOutSpaceExperience(
                  id: experienceId,
                  spaceId: spaceId,
                  content: 'The experience being replied to.',
                  voiceName: 'Sample Voice',
                  createdAt: DateTime(2026, 1, 1),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('The existing reply.'), findsOneWidget);
      await tester.ensureVisible(find.text('Reply to this'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reply to this'));
      await tester.pump();
      expect(find.text('Continuing a reply in Sample Voice'), findsOneWidget);

      await tester.enterText(find.byType(TextField), draft);
      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pumpAndSettle();

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        draft,
      );
      expect(find.text('Continuing a reply in Sample Voice'), findsOneWidget);
      expect(
        find.text('Could not save that reply. Your text is still here.'),
        findsOneWidget,
      );
      final repliesAfterFailure = container
          .read(crashOutSpaceProvider.notifier)
          .repliesFor(spaceId, experienceId);
      expect(repliesAfterFailure, hasLength(1));
      expect(repliesAfterFailure.single.id, parentReplyId);

      // Let the failure feedback finish before retrying through the same
      // composer and selected reply-to-reply target.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      store.throwOnWrite = false;
      await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
      await tester.pumpAndSettle();

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expect(find.text('Continuing a reply in Sample Voice'), findsNothing);
      final persisted = jsonDecode(store.values[storageKey] as String)
          as Map<String, dynamic>;
      final savedReplies = (persisted['$spaceId::$experienceId'] as List)
          .cast<Map<String, dynamic>>();
      expect(savedReplies, hasLength(2));
      expect(savedReplies.last['content'], draft.trim());
      expect(savedReplies.last['replyToId'], parentReplyId);
    },
  );

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


  test('prototype experiences populate a Space without duplicate entries', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(crashOutSpaceExperienceProvider.future);
    final notifier =
        container.read(crashOutSpaceExperienceProvider.notifier);
    final examples =
        CrashOutSpacePrototypeData.forTension(HumanTension.connection);

    await notifier.ensurePrototypeExperiences(examples);
    await notifier.ensurePrototypeExperiences(examples);

    await container.read(crashOutSpaceProvider.future);
    final replyNotifier = container.read(crashOutSpaceProvider.notifier);
    final sampleReplies =
        CrashOutSpacePrototypeData.repliesForTension(HumanTension.connection);
    await replyNotifier.ensurePrototypeReplies(
      spaceId: 'connection',
      prototypes: sampleReplies,
    );
    await replyNotifier.ensurePrototypeReplies(
      spaceId: 'connection',
      prototypes: sampleReplies,
    );

    expect(notifier.experiencesFor('connection'), hasLength(3));
    expect(
      replyNotifier.repliesFor('connection', 'prototype_connection_01'),
      hasLength(1),
    );
    expect(
      replyNotifier.repliesFor('connection', 'prototype_connection_02'),
      hasLength(1),
    );
    expect(
      notifier.experiencesFor('connection').every(
            (experience) => experience.id.startsWith('prototype_'),
          ),
      isTrue,
    );
    expect(notifier.experiencesFor('attention'), isEmpty);
  });

  test('interprets “I hate people” as a connection tension', () {
    final representation = const CrashOutExperienceInterpreter().interpret(
      CrashOut(
        id: 'private-crash-out',
        textContent: 'I hate people',
        type: CrashOutType.text,
        createdAt: DateTime(2026, 10, 18),
      ),
    );

    expect(
      representation.atoms.any(
        (atom) =>
            atom.tension == HumanTension.connection &&
            atom.direction == ExperienceDirection.away,
      ),
      isTrue,
    );
  });

}

class _FailingSharedPreferencesStore extends SharedPreferencesStorePlatform {
  _FailingSharedPreferencesStore(Map<String, Object> initialValues)
      : values = Map<String, Object>.of(initialValues);

  final Map<String, Object> values;
  bool throwOnWrite = true;

  @override
  Future<Map<String, Object>> getAll() async => Map<String, Object>.of(values);

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    if (throwOnWrite) {
      throw StateError('simulated local persistence failure');
    }
    values[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async => values.remove(key) != null;

  @override
  Future<bool> clear() async {
    values.clear();
    return true;
  }
}
