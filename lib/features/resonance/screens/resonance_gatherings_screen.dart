import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../../spaces/models/space.dart';
import '../../spaces/providers/space_provider.dart';
import '../../ventvo_voice/models/vent.dart';
import '../../ventvo_voice/providers/vent_provider.dart';
import '../models/resonance_map_experience.dart';
import '../providers/resonance_gathering_provider.dart';
import '../providers/resonance_map_experience_provider.dart';
import '../providers/resonance_maps_provider.dart';
import 'resonance_gathering_entry_screen.dart';

class ResonanceGatheringsScreen extends ConsumerWidget {
  const ResonanceGatheringsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maps = ref.watch(resonanceMapsProvider);
    final vents = ref.watch(ventProvider).asData?.value ?? const <Vent>[];
    final spaces = ref.watch(spaceProvider).asData?.value ?? const <Space>[];
    final ventsById = {for (final vent in vents) vent.id: vent};
    final spacesById = {for (final space in spaces) space.id: space};
    final resolver = ref.read(resonanceMapExperienceResolverProvider);
    final gatheringService = ref.read(resonanceGatheringServiceProvider);

    return Scaffold(
      backgroundColor: VentvoColors.background,
      appBar: AppBar(title: const Text('Gatherings'), centerTitle: true),
      body: maps.when(
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
        error: (_, _) => const Center(child: Text('Gatherings could not be loaded yet.')),
        data: (items) {
          final candidates = items
              .expand(gatheringService.discoverCandidates)
              .toList(growable: false);

          if (candidates.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 34),
                child: Text(
                  'Nothing is ready to gather yet.\n\nGatherings emerge when connected experiences form a meaningful small landscape.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: VentvoColors.textMuted, fontSize: 13, height: 1.6),
                ),
              ),
            );
          }

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 36),
            itemCount: candidates.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final candidate = candidates[index];
              return FutureBuilder<List<ResonanceMapExperience>>(
                future: resolver.resolve(
                  experienceIds: candidate.experienceIds,
                  ventsById: ventsById,
                  spacesById: spacesById,
                ),
                builder: (context, snapshot) {
                  final experiences = snapshot.data ?? const <ResonanceMapExperience>[];
                  if (experiences.isEmpty) return const SizedBox.shrink();

                  return _GatheringCandidateCard(
                    experiences: experiences,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ResonanceGatheringEntryScreen(
                          candidate: candidate,
                          experiences: experiences,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _GatheringCandidateCard extends StatelessWidget {
  final List<ResonanceMapExperience> experiences;
  final VoidCallback onTap;

  const _GatheringCandidateCard({required this.experiences, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: VentvoColors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(17, 17, 15, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'These experiences found each other.',
                      style: TextStyle(color: VentvoColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, size: 17, color: VentvoColors.textMuted),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${experiences.length} connected experiences',
                style: const TextStyle(color: VentvoColors.textMuted, fontSize: 11),
              ),
              const SizedBox(height: 13),
              ...experiences.take(3).map(
                    (experience) => Padding(
                      padding: const EdgeInsets.only(bottom: 7),
                      child: Text(
                        '${experience.voiceMark}  ${experience.content}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: VentvoColors.textSecondary, fontSize: 12, height: 1.45),
                      ),
                    ),
                  ),
              if (experiences.length > 3)
                Text(
                  '+ ${experiences.length - 3} more experiences',
                  style: const TextStyle(color: VentvoColors.textMuted, fontSize: 10),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
