import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../systems/resonance/models/resonance_map.dart';
import '../../../systems/resonance/models/resonance_thread.dart';
import '../../../systems/resonance/providers/resonance_provider.dart';
import 'vent_provider.dart';

class VoiceSpaceResonanceStats {
  const VoiceSpaceResonanceStats({
    required this.threads,
    required this.maps,
  });

  final int threads;
  final int maps;
}

final voiceSpaceResonanceStatsProvider =
    FutureProvider<VoiceSpaceResonanceStats>((ref) async {
  final vents = await ref.watch(ventProvider.future);
  final experienceIds = vents.map((vent) => vent.id).toSet();

  if (experienceIds.isEmpty) {
    return const VoiceSpaceResonanceStats(threads: 0, maps: 0);
  }

  final threadService = ref.watch(resonanceThreadDiscoveryServiceProvider);
  final mapService = ref.watch(resonanceMapDiscoveryServiceProvider);

  final threads = <String, ResonanceThread>{};
  final maps = <String, ResonanceMap>{};

  for (final experienceId in experienceIds) {
    final results = await Future.wait([
      threadService.discoverForExperience(experienceId, limit: 100),
      mapService.discoverForExperience(experienceId, limit: 100),
    ]);

    for (final thread in results[0] as List<ResonanceThread>) {
      threads[thread.id] = thread;
    }

    for (final map in results[1] as List<ResonanceMap>) {
      maps[map.id] = map;
    }
  }

  return VoiceSpaceResonanceStats(
    threads: threads.length,
    maps: maps.length,
  );
});
