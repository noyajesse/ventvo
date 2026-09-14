import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../../ventvo_voice/models/vent.dart';
import '../../ventvo_voice/providers/vent_provider.dart';
import '../../../systems/resonance/models/resonance_thread.dart';
import '../providers/resonance_threads_provider.dart';

class ResonanceThreadsScreen extends ConsumerWidget {
  const ResonanceThreadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = ref.watch(resonanceThreadsProvider);
    final vents = ref.watch(ventProvider).asData?.value ?? const <Vent>[];
    final ventsById = {for (final vent in vents) vent.id: vent};

    return Scaffold(
      backgroundColor: VentvoColors.background,
      appBar: AppBar(
        title: const Text('Resonance'),
        centerTitle: true,
      ),
      body: threads.when(
        loading: () => const Center(
          child: CircularProgressIndicator(strokeWidth: 1.5),
        ),
        error: (_, _) => const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Resonance could not be loaded yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: VentvoColors.textMuted,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Nothing is resonating yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: VentvoColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'When experiences remain meaningfully connected, Ventvo can let you encounter that relationship as a Resonance Thread.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: VentvoColors.textMuted,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _ThreadCard(
                thread: items[index],
                ventsById: ventsById,
              );
            },
          );
        },
      ),
    );
  }
}

class _ThreadCard extends StatelessWidget {
  final ResonanceThread thread;
  final Map<String, Vent> ventsById;

  const _ThreadCard({
    required this.thread,
    required this.ventsById,
  });

  @override
  Widget build(BuildContext context) {
    final marks = thread.voiceMarks.isEmpty
        ? 'Voices connected through experience'
        : thread.voiceMarks.join('  ·  ');

    final excerpts = thread.experienceIds
        .map((id) => ventsById[id])
        .whereType<Vent>()
        .take(3)
        .map((vent) => vent.content)
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 17),
      decoration: BoxDecoration(
        color: VentvoColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: VentvoColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RESONANCE THREAD',
            style: TextStyle(
              color: VentvoColors.textMuted,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            marks,
            style: const TextStyle(
              color: VentvoColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '${thread.experienceIds.length} experiences · ${thread.connections.length} connections',
            style: const TextStyle(
              color: VentvoColors.textMuted,
              fontSize: 10,
            ),
          ),
          if (excerpts.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...excerpts.map(
              (excerpt) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Text(
                  excerpt,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: VentvoColors.textPrimary,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
