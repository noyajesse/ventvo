import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../systems/resonance/models/resonance_gathering_candidate.dart';
import '../../../systems/resonance/models/resonance_map.dart';
import '../../../systems/resonance/services/resonance_gathering_service.dart';

final resonanceGatheringServiceProvider = Provider<ResonanceGatheringService>((ref) {
  return const ResonanceGatheringService();
});

final resonanceGatheringCandidatesProvider =
    Provider.family<List<ResonanceGatheringCandidate>, ResonanceMap>((ref, map) {
  return ref
      .watch(resonanceGatheringServiceProvider)
      .discoverCandidates(map);
});
