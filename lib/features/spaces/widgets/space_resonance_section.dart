import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../../../systems/resonance/models/resonance_candidate.dart';
import '../../../systems/resonance/models/resonance_connection.dart';
import '../../../systems/resonance/providers/resonance_provider.dart';
import '../../ventvo_voice/models/vent.dart';
import '../../ventvo_voice/providers/vent_provider.dart';
import '../../ventvo_voice/providers/voice_lifecycle_provider.dart';
import '../../ventvo_voice/providers/voice_provider.dart';
import '../models/space.dart';
import '../providers/space_provider.dart';
import '../providers/space_resonance_provider.dart';
import '../screens/space_screen.dart';
import '../../resonance/screens/resonance_relationship_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadConnection();
  }

  Future<void> _loadConnection() async {
    final existing = await ref
        .read(resonanceConnectionServiceProvider)
        .getConnectionBetween(
          widget.targetSpace.originatingVentId,
          widget.candidate.id,
        );

    if (!mounted || existing == null) return;
    setState(() => connection = existing);
  }

  Future<void> _resonate() async {
    if (saving || connection != null) return;

    setState(() => saving = true);

    final voice = await ref.read(ventvoVoiceProvider.future);
    final sourceVoiceId = voice?.voiceId;
    if (sourceVoiceId == null || sourceVoiceId.trim().isEmpty) {
      if (mounted) setState(() => saving = false);
      return;
    }

    final sourceVent = await _loadSourceVent();
    if (sourceVent?.ownerVoiceId != sourceVoiceId) {
      if (mounted) setState(() => saving = false);
      return;
    }

    final service = ref.read(resonanceConnectionServiceProvider);
    final suggested = await service.suggestConnection(
      sourceId: widget.targetSpace.originatingVentId,
      sourceVoiceId: sourceVoiceId,
      candidate: widget.candidate,
    );

    if (!mounted) return;
    setState(() {
      connection = suggested;
      saving = false;
    });
    ref.invalidate(voiceLifecycleProvider);
  }

  Future<Vent?> _loadSourceVent() async {
    final vents = ref.read(ventProvider).asData?.value ?? const <Vent>[];
    for (final vent in vents) {
      if (vent.id == widget.targetSpace.originatingVentId) {
        return vent;
      }
    }
    return null;
  }

  Future<void> _openRelationship() async {
    final current = connection;
    if (current == null || saving) return;

    final updated = await Navigator.of(context).push<ResonanceConnection>(
      MaterialPageRoute(
        builder: (_) => ResonanceRelationshipScreen(
          candidate: widget.candidate,
          connection: current,
        ),
      ),
    );

    if (!mounted || updated == null) return;
    setState(() => connection = updated);
    ref.invalidate(voiceLifecycleProvider);
  }

  String get _actionLabel {
    final state = connection?.state;
    switch (state) {
      case ResonanceConnectionState.accepted:
      case ResonanceConnectionState.active:
        return 'Resonating';
      case ResonanceConnectionState.closed:
        return 'Resonance closed';
      case ResonanceConnectionState.blocked:
        return 'Resonance blocked';
      case ResonanceConnectionState.suggested:
      case null:
        return 'Resonate';
    }
  }

  bool get _canOpenRelationship {
    final state = connection?.state;
    return state == ResonanceConnectionState.accepted ||
        state == ResonanceConnectionState.active;
  }

  @override
  Widget build(BuildContext context) {
    final hasResonated = connection != null;\n    final isSuggested = connection?.state == ResonanceConnectionState.suggested;
    final canOpenRelationship = _canOpenRelationship;

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
                onPressed: saving
                    ? null
                    : canOpenRelationship
                        ? _openRelationship
                        : hasResonated
                            ? null
                            : _resonate,
                icon: Icon(
                  hasResonated
                      ? Icons.check_rounded
                      : Icons.blur_on_rounded,
                  size: 15,
                ),
                label: Text(_actionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
