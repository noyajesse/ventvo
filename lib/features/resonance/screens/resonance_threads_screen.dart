import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../../ventvo_voice/models/vent.dart';
import '../../ventvo_voice/providers/vent_provider.dart';
import '../../../systems/resonance/models/resonance_thread.dart';
import '../providers/resonance_threads_provider.dart';
import 'resonance_maps_screen.dart';
import 'resonance_thread_detail_screen.dart';

class ResonanceThreadsScreen extends ConsumerWidget {
  final String? experienceId;

  const ResonanceThreadsScreen({super.key, this.experienceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threads = experienceId == null
        ? ref.watch(resonanceThreadsProvider)
        : ref.watch(resonanceThreadsForExperienceProvider(experienceId!));
    final vents = ref.watch(ventProvider).asData?.value ?? const <Vent>[];
    final ventsById = {for (final vent in vents) vent.id: vent};

    return Scaffold(
      backgroundColor: VentvoColors.background,
      appBar: AppBar(
        title: Text(experienceId == null ? 'Threads' : 'Related Threads'),
        centerTitle: true,
        actions: [
          if (experienceId == null)
            IconButton(
              tooltip: 'Explore Maps',
              icon: const Icon(Icons.hub_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ResonanceMapsScreen()),
              ),
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
              'Threads could not be loaded yet.',
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
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      experienceId == null
                          ? 'No stories have taken shape yet.'
                          : 'No related stories have taken shape yet.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: VentvoColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      experienceId == null
                          ? 'Threads emerge when enough experiences meaningfully connect. There is no need to force a story before those connections are there.'
                          : 'This Moment may become part of a Thread as more meaningful experiences connect around it.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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
            itemBuilder: (context, index) => _ThreadCard(
              thread: items[index],
              ventsById: ventsById,
            ),
          );
        },
      ),
    );
  }
}

class _ThreadCard extends StatelessWidget {
  final ResonanceThread thread;
  final Map<String, Vent> ventsById;

  const _ThreadCard({required this.thread, required this.ventsById});

  @override
  Widget build(BuildContext context) {
    final excerpts = thread.experienceIds
        .map((id) => ventsById[id])
        .whereType<Vent>()
        .take(3)
        .map((vent) => vent.content)
        .toList();

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResonanceThreadDetailScreen(
            thread: thread,
            ventsById: ventsById,
          ),
        ),
      ),
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
              'A STORY TAKING SHAPE',
              style: TextStyle(
                color: VentvoColors.textMuted,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            if (excerpts.isEmpty)
              const Text(
                'Explore the experiences connected here.',
                style: TextStyle(
                  color: VentvoColors.textPrimary,
                  fontSize: 15,
                  height: 1.45,
                ),
              )
            else
              Text(
                excerpts.first,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: VentvoColors.textPrimary,
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(height: 12),
            Text(
              '${thread.experienceIds.length} connected experiences',
              style: const TextStyle(
                color: VentvoColors.textMuted,
                fontSize: 10,
              ),
            ),
            if (excerpts.length > 1) ...[
              const SizedBox(height: 15),
              ...excerpts.skip(1).map(
                (excerpt) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    excerpt,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: VentvoColors.textSecondary,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Explore story',
                    style: TextStyle(
                      color: VentvoColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: VentvoColors.textMuted,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
