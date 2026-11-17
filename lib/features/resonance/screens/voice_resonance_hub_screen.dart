import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../providers/resonance_gathering_provider.dart';
import '../providers/resonance_maps_provider.dart';
import '../providers/resonance_threads_provider.dart';
import 'resonance_connections_screen.dart';
import 'resonance_gatherings_screen.dart';
import 'resonance_maps_screen.dart';
import 'resonance_threads_screen.dart';

class VoiceResonanceHubScreen extends ConsumerWidget {
  const VoiceResonanceHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = ref.watch(resonanceThreadsProvider);
    final maps = ref.watch(resonanceMapsProvider);
    final gatheringService = ref.watch(resonanceGatheringServiceProvider);
    final gatheringCount = maps.asData?.value
            .expand(gatheringService.discoverCandidates)
            .length ??
        0;

    return Scaffold(
      backgroundColor: VentvoColors.background,
      appBar: AppBar(title: const Text('Resonance'), centerTitle: true),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 40),
        children: [
          const Text(
            'Where your experiences meet others.',
            style: TextStyle(
              color: VentvoColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Resonance grows from meaningful recognition between Moments. It is never a score or a popularity measure.',
            style: TextStyle(color: VentvoColors.textMuted, fontSize: 13, height: 1.55),
          ),
          const SizedBox(height: 28),
          _Entry(
            icon: Icons.waves_rounded,
            title: 'Your Resonances',
            subtitle: 'Moments that connected with yours.',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ResonanceConnectionsScreen(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _Entry(
            icon: Icons.account_tree_outlined,
            title: 'Threads',
            subtitle: threads.when(
              loading: () => 'Gathering shared stories…',
              error: (_, _) => 'Stories growing from shared experiences',
              data: (items) => items.isEmpty
                  ? 'Stories growing from shared experiences'
                  : '${items.length} shared ${items.length == 1 ? 'story' : 'stories'}',
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ResonanceThreadsScreen()),
            ),
          ),
          const SizedBox(height: 10),
          _Entry(
            icon: Icons.hub_outlined,
            title: 'Maps',
            subtitle: maps.when(
              loading: () => 'Exploring wider landscapes…',
              error: (_, _) => 'Wider landscapes of shared moments',
              data: (items) => items.isEmpty
                  ? 'Wider landscapes of shared moments'
                  : '${items.length} ${items.length == 1 ? 'landscape' : 'landscapes'} of moments',
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ResonanceMapsScreen()),
            ),
          ),
          const SizedBox(height: 10),
          _Entry(
            icon: Icons.groups_outlined,
            title: 'Gatherings',
            subtitle: maps.when(
              loading: () => 'Sensing small circles…',
              error: (_, _) => 'Small circles where connected experiences meet',
              data: (_) => gatheringCount == 0
                  ? 'Small circles where connected experiences meet'
                  : '$gatheringCount ${gatheringCount == 1 ? 'gathering' : 'gatherings'} emerging',
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ResonanceGatheringsScreen()),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Resonance begins with a single Moment, deepens through mutual recognition, and can grow into shared stories, landscapes, and small gatherings.',
            style: TextStyle(color: VentvoColors.textMuted, fontSize: 12, height: 1.55),
          ),
        ],
      ),
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: VentvoColors.surface,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, color: VentvoColors.textSecondary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: VentvoColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: VentvoColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: VentvoColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      );
}