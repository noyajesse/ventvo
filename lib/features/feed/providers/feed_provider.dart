import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../systems/resonance/providers/resonance_provider.dart';
import '../../spaces/models/space.dart';
import '../../spaces/providers/space_provider.dart';
import '../../ventvo_voice/models/vent.dart';
import '../../ventvo_voice/providers/vent_provider.dart';
import '../services/feed_resonance_service.dart';

final feedResonanceServiceProvider = Provider<FeedResonanceService>((ref) {
  return FeedResonanceService(
    discoveryService: ref.watch(ventResonanceDiscoveryServiceProvider),
  );
});

class FeedNotifier extends AsyncNotifier<List<Vent>> {
  @override
  Future<List<Vent>> build() async {
    final ownVents = ref.watch(ventProvider).asData?.value ?? const <Vent>[];
    final storedSpaces = ref.watch(spaceProvider).asData?.value ?? const <Space>[];
    final fixtureSpaces = _localFixtureSpaces;
    final fixtureVents = _localDiscoveryFixtures;

    final allSources = [...ownVents, ...fixtureVents];
    final allSpaces = [...storedSpaces, ...fixtureSpaces];

    final discovery = await ref.read(feedResonanceServiceProvider).discover(
      sources: allSources,
      spaces: allSpaces,
      candidateVents: fixtureVents,
    );

    return [...ownVents, ...discovery]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void addDiscoveredMoment(Vent vent) {
    final current = state.asData?.value ?? const <Vent>[];
    if (current.any((item) => item.id == vent.id)) return;
    state = AsyncData([vent, ...current]);
  }
}

final _localDiscoveryFixtures = <Vent>[
  Vent(
    id: 'sample_moment_01',
    content: 'I keep thinking about how strange it is that you can miss a version of yourself that you were never really happy being.',
    spaceId: 'sample_space_01',
    voiceMark: '◇ Nera',
    voiceName: 'Nera',
    createdAt: DateTime(2026, 8, 27, 12, 10),
  ),
  Vent(
    id: 'sample_moment_02',
    content: 'Today I realized I do not need an answer yet. I just needed somewhere to put the question.',
    spaceId: 'sample_space_02',
    voiceMark: '◇ Sol',
    voiceName: 'Sol',
    createdAt: DateTime(2026, 8, 27, 11, 42),
  ),
  Vent(
    id: 'sample_moment_03',
    content: 'There are people I have never spoken to who somehow made me feel less alone.',
    spaceId: 'sample_space_03',
    voiceMark: '◇ Aven',
    voiceName: 'Aven',
    createdAt: DateTime(2026, 8, 27, 10, 58),
  ),
];

final _localFixtureSpaces = <Space>[
  Space(
    id: 'sample_space_01',
    mode: SpaceMode.justListen,
    originatingVentId: 'sample_moment_01',
    creatorVoiceMark: '◇ Nera',
    createdAt: DateTime(2026, 8, 27, 12, 10),
  ),
  Space(
    id: 'sample_space_02',
    mode: SpaceMode.openDiscussion,
    originatingVentId: 'sample_moment_02',
    creatorVoiceMark: '◇ Sol',
    createdAt: DateTime(2026, 8, 27, 11, 42),
  ),
  Space(
    id: 'sample_space_03',
    mode: SpaceMode.justListen,
    originatingVentId: 'sample_moment_03',
    creatorVoiceMark: '◇ Aven',
    createdAt: DateTime(2026, 8, 27, 10, 58),
  ),
];

final feedProvider = AsyncNotifierProvider<FeedNotifier, List<Vent>>(
  FeedNotifier.new,
);
