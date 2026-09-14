import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../../../systems/resonance/models/resonance_map.dart';
import '../../../systems/resonance/models/resonance_thread.dart';
import '../../../systems/resonance/providers/resonance_provider.dart';
import '../providers/resonance_map_threads_provider.dart';
import '../providers/resonance_maps_provider.dart';

class ResonanceThreadMapIntegrationScreen extends ConsumerWidget {
  final ResonanceThread thread;

  const ResonanceThreadMapIntegrationScreen({
    super.key,
    required this.thread,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maps = ref.watch(resonanceMapsProvider);

    return Scaffold(
      backgroundColor: VentvoColors.background,
      appBar: AppBar(
        title: const Text('Place Thread in a Map'),
        centerTitle: true,
      ),
      body: maps.when(
        loading: () => const Center(
          child: CircularProgressIndicator(strokeWidth: 1.5),
        ),
        error: (_, _) => const Center(
          child: Text(
            'Resonance Maps could not be loaded yet.',
            style: TextStyle(color: VentvoColors.textMuted),
          ),
        ),
        data: (items) {
          final eligibleMaps = items
              .where((map) =>
                  !map.threadIds.contains(thread.id) &&
                  thread.experienceIds.any(map.containsExperience))
              .toList(growable: false);

          if (eligibleMaps.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 36),
                child: Text(
                  'This Thread does not currently connect to another Map.\n\nWhen it shares an experience with a Map, the Thread can become part of that larger landscape.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: VentvoColors.textMuted,
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ),
            );
          }

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
            children: [
              const Text(
                'THREAD → MAP',
                style: TextStyle(
                  color: VentvoColors.textMuted,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'This Thread already touches part of a larger landscape.',
                style: TextStyle(
                  color: VentvoColors.textPrimary,
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose the Map where this connected path belongs. Ventvo will preserve the existing Map and Thread relationships rather than creating a new structure.',
                style: TextStyle(
                  color: VentvoColors.textMuted,
                  fontSize: 13,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 22),
              ...eligibleMaps.map(
                (map) => _MapChoice(
                  map: map,
                  thread: thread,
                  onIntegrate: () => _integrate(context, ref, map),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _integrate(
    BuildContext context,
    WidgetRef ref,
    ResonanceMap map,
  ) async {
    final service = ref.read(resonanceMapThreadIntegrationServiceProvider);
    final updatedMap = await service.integrateThread(
      mapId: map.id,
      threadId: thread.id,
    );

    if (!context.mounted) return;

    if (updatedMap == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This Thread cannot be added to that Map right now.'),
        ),
      );
      return;
    }

    ref.invalidate(resonanceMapsProvider);
    ref.invalidate(resonanceMapThreadsProvider(map.id));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thread connected to the Map.'),
      ),
    );
    Navigator.of(context).pop(true);
  }
}

class _MapChoice extends StatelessWidget {
  final ResonanceMap map;
  final ResonanceThread thread;
  final VoidCallback onIntegrate;

  const _MapChoice({
    required this.map,
    required this.thread,
    required this.onIntegrate,
  });

  @override
  Widget build(BuildContext context) {
    final overlapCount =
        thread.experienceIds.where(map.containsExperience).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 14),
      decoration: BoxDecoration(
        color: VentvoColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: VentvoColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RESONANCE MAP',
            style: TextStyle(
              color: VentvoColors.textMuted,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${map.experienceIds.length} connected experiences',
            style: const TextStyle(
              color: VentvoColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$overlapCount shared ${overlapCount == 1 ? 'experience' : 'experiences'} · ${map.connections.length} relationships',
            style: const TextStyle(
              color: VentvoColors.textMuted,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onIntegrate,
              child: const Text('Connect Thread'),
            ),
          ),
        ],
      ),
    );
  }
}
