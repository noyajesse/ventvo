import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../systems/resonance/models/resonance_thread.dart';
import '../../../systems/resonance/providers/resonance_provider.dart';

final resonanceMapThreadsProvider = FutureProvider.family<List<ResonanceThread>, String>((ref, mapId) async {
  final maps = await ref.watch(resonanceMapDiscoveryServiceProvider).discoverAll(limit: 20);
  final map = maps.where((candidate) => candidate.id == mapId).firstOrNull;
  if (map == null) return const [];

  final engine = ref.watch(resonanceEngineProvider);
  final threads = <ResonanceThread>[];
  for (final threadId in map.threadIds) {
    final thread = await engine.getThread(threadId);
    if (thread != null) threads.add(thread);
  }
  return List.unmodifiable(threads);
});
