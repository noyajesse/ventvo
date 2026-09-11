import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ventvo_voice/models/vent.dart';
import '../../ventvo_voice/providers/vent_provider.dart';
import '../models/space.dart';
import '../providers/space_provider.dart';
import '../../../systems/resonance/models/resonance_candidate.dart';
import '../../../systems/resonance/providers/resonance_provider.dart';

final spaceResonanceCandidatesProvider =
    FutureProvider.family<List<ResonanceCandidate>, Space>(
  (ref, space) async {
    final vents = await ref.watch(ventProvider.future);
    final spaces = await ref.watch(spaceProvider.future);
    final service = ref.watch(spaceResonanceDiscoveryServiceProvider);

    await service.indexVents(
      vents: vents,
      spaces: spaces,
    );

    final originatingVent = _findOriginatingVent(
      vents,
      space.originatingVentId,
    );

    if (originatingVent == null) return const [];

    return service.discoverRelatedVents(
      space: space,
      originatingVent: originatingVent,
      limit: 3,
    );
  },
);

Vent? _findOriginatingVent(
  Iterable<Vent> vents,
  String id,
) {
  for (final vent in vents) {
    if (vent.id == id) return vent;
  }
  return null;
}
