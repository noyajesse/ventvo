import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../../ventvo_voice/models/vent.dart';
import '../../ventvo_voice/providers/vent_provider.dart';
import '../../../systems/resonance/models/resonance_connection.dart';
import '../../../systems/resonance/models/resonance_thread.dart';
import '../providers/resonance_threads_provider.dart';
import 'resonance_maps_screen.dart';
import 'resonance_thread_detail_screen.dart';

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
        actions: [
          IconButton(
            tooltip: 'Resonance Maps',
            icon: const Icon(Icons.hub_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ResonanceMapsScreen(),
                ),
              );
            },
          ),
        ],
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

    final relationshipSummary = _relationshipSummary(thread.connections);

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ResonanceThreadDetailScreen(
              thread: thread,
              ventsById: ventsById,
            ),
          ),
        );
      },
      child: Container(
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
            if (relationshipSummary != null) ...[
              const SizedBox(height: 8),
              Text(
                relationshipSummary,
                style: const TextStyle(
                  color: VentvoColors.textSecondary,
                  fontSize: 11,
                  height: 1.45,
                ),
              ),
            ],
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
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 17,
                color: VentvoColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _relationshipSummary(List<ResonanceConnection> connections) {
    final labels = <String>[];
    final seenTypes = <ResonanceConnectionType>{};

    for (final connection in connections) {
      if (!seenTypes.add(connection.type)) continue;
      labels.add(_labelFor(connection.type));
      if (labels.length == 2) break;
    }

    if (labels.isEmpty) return null;
    if (labels.length == 1) return 'Connected through ${labels.first.toLowerCase()}.';
    return 'Connected through ${labels[0].toLowerCase()} and ${labels[1].toLowerCase()}.';
  }

  String _labelFor(ResonanceConnectionType type) {
    switch (type) {
      case ResonanceConnectionType.sharedExperience:
        return 'shared experience';
      case ResonanceConnectionType.perspective:
        return 'different perspective';
      case ResonanceConnectionType.response:
        return 'response';
      case ResonanceConnectionType.similarity:
        return 'similar experience';
      case ResonanceConnectionType.discovery:
        return 'discovered connection';
    }
  }
}
