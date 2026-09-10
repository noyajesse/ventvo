import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../spaces/models/space.dart';
import '../../spaces/providers/space_provider.dart';
import '../../ventvo_voice/models/vent.dart';
import '../../ventvo_voice/providers/vent_provider.dart';
import '../../../systems/resonance/models/resonance_candidate.dart';
import '../../../systems/resonance/models/resonance_signal.dart';
import '../../../systems/resonance/providers/resonance_provider.dart';

class FeedNotifier extends AsyncNotifier<List<Vent>> {
  @override
  Future<List<Vent>> build() async {
    final vents = ref.watch(ventProvider).asData?.value ?? const <Vent>[];
    final spaces = ref.watch(spaceProvider).asData?.value ?? const <Space>[];

    final service = ref.watch(ventResonanceDiscoveryServiceProvider);
    final repository = ref.watch(resonanceRepositoryProvider);

    // Index the local public Vent experiences before discovery. The repository
    // remains the source of candidates; Feed never performs matching itself.
    for (final vent in vents.where((item) => item.isDiscoverable)) {
      final space = spaces.where((item) => item.id == vent.spaceId).firstOrNull;
      if (space == null) continue;

      final signals = VentResonanceSignalGeneratorBridge.generate(
        vent: vent,
        space: space,
      );
      await repository.saveCandidate(
        ResonanceCandidate(
          id: vent.id,
          type: ResonanceCandidateType.vent,
          voiceMark: vent.voiceMark,
          score: 0,
          signals: signals,
        ),
      );
    }

    final discovered = <Vent>[];
    for (final vent in vents.where((item) => item.isDiscoverable)) {
      final space = spaces.where((item) => item.id == vent.spaceId).firstOrNull;
      if (space == null) continue;

      final candidates = await service.discoverForVent(
        vent: vent,
        space: space,
        limit: 10,
        excludedIds: vents.map((item) => item.id).toSet(),
      );

      for (final candidate in candidates) {
        if (discovered.any((item) => item.id == candidate.id)) continue;
        final match = vents.where((item) => item.id == candidate.id).firstOrNull;
        if (match != null) discovered.add(match);
      }
    }

    return [...vents, ...discovered]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void addDiscoveredMoment(Vent vent) {
    final current = state.asData?.value ?? const <Vent>[];
    if (current.any((item) => item.id == vent.id)) return;
    state = AsyncData([vent, ...current]);
  }
}

/// Temporary adapter kept inside the feature while the shared signal generator
/// remains the single interpretation source for Vent experiences.
class VentResonanceSignalGeneratorBridge {
  static List<ResonanceSignal> generate({
    required Vent vent,
    required Space space,
  }) {
    return const [];
  }
}

final feedProvider = AsyncNotifierProvider<FeedNotifier, List<Vent>>(
  FeedNotifier.new,
);
