import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../systems/resonance/models/resonance_candidate.dart';
import '../../../systems/resonance/providers/resonance_provider.dart';
import '../../../systems/resonance/services/vent_resonance_signal_generator.dart';
import '../../spaces/models/space.dart';
import '../../spaces/providers/space_provider.dart';
import '../../ventvo_voice/models/vent.dart';
import '../../ventvo_voice/providers/vent_provider.dart';

class FeedNotifier extends AsyncNotifier<List<Vent>> {
  @override
  Future<List<Vent>> build() async {
    final ownVents = ref.watch(ventProvider).asData?.value ?? const <Vent>[];
    final spaces = ref.watch(spaceProvider).asData?.value ?? const <Space>[];
    final repository = ref.watch(resonanceRepositoryProvider);
    final discoveryService = ref.watch(ventResonanceDiscoveryServiceProvider);
    const generator = VentResonanceSignalGenerator();

    // These are temporary local fixtures only. They let us exercise the real
    // Resonance path before backend discovery exists. Feed itself does not
    // score or select them.
    final fixtureVents = _localDiscoveryFixtures;
    final fixtureSpaces = _localFixtureSpaces;

    for (final vent in [...ownVents, ...fixtureVents]) {
      final space = [...spaces, ...fixtureSpaces]
          .where((item) => item.id == vent.spaceId)
          .firstOrNull;
      if (space == null || !vent.isDiscoverable) continue;

      await repository.saveCandidate(
        ResonanceCandidate(
          id: vent.id,
          type: ResonanceCandidateType.vent,
          voiceMark: vent.voiceMark,
          score: 0,
          signals: generator.generate(vent: vent, space: space),
        ),
      );
    }

    final discovered = <Vent>[];
    for (final source in ownVents.where((item) => item.isDiscoverable)) {
      final sourceSpace = spaces.where((item) => item.id == source.spaceId).firstOrNull;
      if (sourceSpace == null) continue;

      final candidates = await discoveryService.discoverForVent(
        vent: source,
        space: sourceSpace,
        limit: 10,
        excludedIds: {...ownVents.map((item) => item.id), source.id},
      );

      for (final candidate in candidates) {
        final match = fixtureVents
            .where((item) => item.id == candidate.id)
            .firstOrNull;
        if (match != null && !discovered.any((item) => item.id == match.id)) {
          discovered.add(match);
        }
      }
    }

    return [...ownVents, ...discovered]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void addDiscoveredMoment(Vent vent) {
    final current = state.asData?.value ?? const <Vent>[];
    if (current.any((item) => item.id == vent.id)) return;
    state = AsyncData([vent, ...current]);
  }
}

const _localDiscoveryFixtures = <Vent>[
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

const _localFixtureSpaces = <Space>[
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
