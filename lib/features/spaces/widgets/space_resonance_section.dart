import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../../../systems/resonance/models/resonance_candidate.dart';
import '../../../systems/resonance/models/resonance_connection.dart';
import '../../../systems/resonance/providers/resonance_provider.dart';
import '../../ventvo_voice/models/vent.dart';
import '../../ventvo_voice/providers/vent_provider.dart';
import '../models/space.dart';
import '../providers/space_provider.dart';
import '../providers/space_resonance_provider.dart';
import '../screens/space_screen.dart';

class SpaceResonanceSection extends ConsumerWidget {
  final Space space;
  final List<String> excludedIds;

  const SpaceResonanceSection({
    super.key,
    required this.space,
    this.excludedIds = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resonance = ref.watch(
      spaceResonanceCandidatesProvider(space),
    );

    return resonance.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (candidates) {
        final visible = candidates
            .where((candidate) => !excludedIds.contains(candidate.id))
            .take(3)
            .toList();

        if (visible.isEmpty) return const SizedBox.shrink();

        final spaces = ref.watch(spaceProvider).asData?.value ?? const [];
        final vents = ref.watch(ventProvider).asData?.value ?? const [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionCaption(),
            const SizedBox(height: 8),
            const Text(
              'Somewhere else, someone put something like this into words.',
              style: TextStyle(
                color: VentvoColors.textSecondary,
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            ...visible.map(
              (candidate) {
                final vent = _ventForCandidate(candidate, vents);
                final targetSpace = _spaceForCandidate(candidate, spaces);

                if (vent == null || targetSpace == null) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ResonanceCard(
                    candidate: candidate,
                    vent: vent,
                    targetSpace: targetSpace,
                    onTap: () => SpaceScreen.open(context, targetSpace),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Vent? _ventForCandidate(
    ResonanceCandidate candidate,
    List<Vent> vents,
  ) {
    for (final vent in vents) {
      if (vent.id == candidate.id) return vent;
    }
    return null;
  }

  Space? _spaceForCandidate(
    ResonanceCandidate candidate,
    List<Space> spaces,
  ) {
    for (final candidateSpace in spaces) {
      if (candidateSpace.allVentIds.contains(candidate.id)) {
        return candidateSpace;
      }
    }
    return null;
  }
}

class _SectionCaption extends StatelessWidget {
  const _SectionCaption();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'RESONANCE',
      style: TextStyle(
        color: VentvoColors.textMuted,
        fontSize: 8,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _ResonanceCard extends ConsumerStatefulWidget {
  final ResonanceCandidate candidate;
  final Vent vent;
  final Space targetSpace;
  final VoidCallback onTap;

  const _ResonanceCard({
    required this.candidate,
    required this.vent,
    required this.targetSpace,
    required this.onTap,
  });

  @override
  ConsumerState<_ResonanceCard> createState() => _ResonanceCardState();
}

class _ResonanceCardState extends ConsumerState<_ResonanceCard> {
  ResonanceConnection? connection;
  bool saving = false;

  Future<void> _resonate() async {
    if (saving || connection != null) return;

    setState(() => saving = true);

    final service = ref.read(resonanceConnectionServiceProvider);
    final suggested = await service.suggestConnection(
      sourceId: widget.targetSpace.originatingVentId,
      candidate: widget.candidate,
    );

    if (suggested == null) {
      if (mounted) setState(() => saving = false);
      return;
    }

    final accepted = await service.accept(suggested);
    if (!mounted) return;

    setState(() {
      connection = accepted;
      saving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasResonated = connection != null;

    return Material(
      color: VentvoColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 15, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.vent.voiceMark,
                          style: const TextStyle(
                            color: VentvoColors.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.vent.content,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: VentvoColors.textPrimary,
                            fontSize: 14,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.targetSpace.modeLabel.toUpperCase(),
                          style: const TextStyle(
                            color: VentvoColors.textMuted,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13,
                      color: VentvoColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 13),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: hasResonated || saving ? null : _resonate,
                icon: Icon(
                  hasResonated
                      ? Icons.check_rounded
                      : Icons.blur_on_rounded,
                  size: 15,
                ),
                label: Text(hasResonated ? 'Resonating' : 'Resonate'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
