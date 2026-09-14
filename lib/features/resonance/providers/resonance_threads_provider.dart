import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../systems/resonance/models/resonance_thread.dart';
import '../../../systems/resonance/providers/resonance_provider.dart';

final resonanceThreadsProvider = FutureProvider<List<ResonanceThread>>((ref) {
  return ref
      .watch(resonanceThreadDiscoveryServiceProvider)
      .discoverAll(limit: 20);
});
