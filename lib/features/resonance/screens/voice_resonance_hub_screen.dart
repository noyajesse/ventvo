import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
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
            'Resonance grows from meaningful connections between experiences. It is not a popularity measure.',
            style: TextStyle(color: VentvoColors.textMuted, fontSize: 13, height: 1.55),
          ),
          const SizedBox(height: 28),
          _Entry(
            icon: Icons.waves_rounded,
            title: 'Your Resonances',
            subtitle: 'See connections as they develop.',
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
              loading: () => 'Loading connected experiences',
              error: (_, _) => 'Could not load Threads',
              data: (items) => '${items.length} ${items.length == 1 ? 'Thread' : 'Threads'}',
            ),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ResonanceThreadsScreen())),
          ),
          const SizedBox(height: 10),
          _Entry(
            icon: Icons.hub_outlined,
            title: 'Maps',
            subtitle: maps.when(
              loading: () => 'Loading connected landscapes',
              error: (_, _) => 'Could not load Maps',
              data: (items) => '${items.length} ${items.length == 1 ? 'Map' : 'Maps'}',
            ),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ResonanceMapsScreen())),
          ),
          const SizedBox(height: 10),
          const _Entry(
            icon: Icons.forum_outlined,
            title: 'Gatherings',
            subtitle: 'Meet where connected experiences converge',
          ),
          const SizedBox(height: 28),
          const Text(
            'Resonance begins with a shared experience, becomes a connection, and can later grow into Threads, Maps, and Gatherings.',
            style: TextStyle(color: VentvoColors.textMuted, fontSize: 12, height: 1.55),
          ),
        ],
      ),
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({required this.icon, required this.title, required this.subtitle, this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: VentvoColors.surface,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap ?? () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ResonanceGatheringsScreen())),
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
                      Text(title, style: const TextStyle(color: VentvoColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: const TextStyle(color: VentvoColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: VentvoColors.textMuted),
              ],
            ),
          ),
        ),
      );
}
