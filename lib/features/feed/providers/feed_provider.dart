import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../systems/resonance/providers/resonance_provider.dart';
import '../../../systems/resonance/services/resonance_demo_data_service.dart';
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
    final fixtureSpaces = ResonanceDemoDataService.spaces;
    final fixtureVents = ResonanceDemoDataService.vents;

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

final feedProvider = AsyncNotifierProvider<FeedNotifier, List<Vent>>(
  FeedNotifier.new,
);
