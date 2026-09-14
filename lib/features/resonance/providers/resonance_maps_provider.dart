import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../systems/resonance/models/resonance_map.dart';
import '../../../systems/resonance/providers/resonance_provider.dart';

final resonanceMapsProvider = FutureProvider<List<ResonanceMap>>((ref) {
  return ref
      .watch(resonanceMapDiscoveryServiceProvider)
      .discoverAll(limit: 20);
});
