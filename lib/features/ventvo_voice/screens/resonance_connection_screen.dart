import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../../../systems/resonance/models/resonance_candidate.dart';
import '../../../systems/resonance/models/resonance_connection.dart';
import '../../../systems/resonance/providers/resonance_provider.dart';
import '../../spaces/providers/space_provider.dart';
import '../models/vent.dart';

class ResonanceConnectionScreen extends ConsumerStatefulWidget {
  final Vent sourceVent;
  final Vent targetVent;

  const ResonanceConnectionScreen({
    super.key,
    required this.sourceVent,
    required this.targetVent,
  });

  @override
  ConsumerState<ResonanceConnectionScreen> createState() =>
      _ResonanceConnectionScreenState();
}

class _ResonanceConnectionScreenState
    extends ConsumerState<ResonanceConnectionScreen> {
  bool _sending = false;
  ResonanceConnection? _connection;

  Future<ResonanceCandidate?> _findCandidate() async {
    final spaces = await ref.read(spaceProvider.future);
    final sourceSpace = spaces
        .where((space) => space.id == widget.sourceVent.spaceId)
        .firstOrNull;

    if (sourceSpace == null || !widget.sourceVent.isDiscoverable) {
      return null;
    }

    final candidates = await ref
        .read(ventResonanceDiscoveryServiceProvider)
        .discoverForVent(
          vent: widget.sourceVent,
          space: sourceSpace,
          excludedIds: {widget.sourceVent.id},
          limit: 20,
        );

    for (final candidate in candidates) {
      if (candidate.type == ResonanceCandidateType.vent &&
          candidate.id == widget.targetVent.id) {
        return candidate;
      }
    }

    return null;
  }

  Future<void> _sendResonance() async {
    if (_sending || _connection != null) return;

    setState(() => _sending = true);

    try {
      final existing = await ref
          .read(resonanceConnectionServiceProvider)
          .getConnectionBetween(
            widget.sourceVent.id,
            widget.targetVent.id,
          );

      if (existing != null) {
        if (!mounted) return;
        setState(() {
          _connection = existing;
          _sending = false;
        });
        return;
      }

      final candidate = await _findCandidate();
      if (candidate == null) {
        if (!mounted) return;
        setState(() => _sending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This Resonance is no longer available from the current experience.',
            ),
          ),
        );
        return;
      }

      final connection = await ref
          .read(resonanceConnectionServiceProvider)
          .suggestConnection(
            sourceId: widget.sourceVent.id,
            candidate: candidate,
          );

      if (!mounted) return;
      setState(() {
        _connection = connection;
        _sending = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('We could not send the Resonance right now.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sent = _connection != null;

    return Scaffold(
      backgroundColor: VentvoColors.background,
      appBar: AppBar(
        backgroundColor: VentvoColors.background,
        elevation: 0,
        title: const Text('Resonance'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 40),
          children: [
            const Text(
              'Something in this experience reached yours.',
              style: TextStyle(
                color: VentvoColors.textPrimary,
                fontSize: 23,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              sent
                  ? 'Your Resonance has been recorded as a suggestion. The other Voice can choose whether to accept it.'
                  : 'If you feel understood by this thought, you can leave a Resonance between the two experiences.',
              style: const TextStyle(
                color: VentvoColors.textMuted,
                fontSize: 14,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 28),
            _ExperienceCard(
              label: 'YOUR MOMENT',
              vent: widget.sourceVent,
            ),
            const SizedBox(height: 12),
            const Center(
              child: Icon(
                Icons.waves_rounded,
                size: 22,
                color: VentvoColors.textMuted,
              ),
            ),
            const SizedBox(height: 12),
            _ExperienceCard(
              label: 'THE OTHER MOMENT',
              vent: widget.targetVent,
            ),
            const SizedBox(height: 30),
            if (sent) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: VentvoColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: VentvoColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: VentvoColors.textSecondary,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Resonance recorded. Nothing private from your side was exposed through this action.',
                        style: TextStyle(
                          color: VentvoColors.textSecondary,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to Find People'),
              ),
            ] else
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _sending ? null : _sendResonance,
                  child: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Leave a Resonance'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  final String label;
  final Vent vent;

  const _ExperienceCard({
    required this.label,
    required this.vent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(17, 16, 17, 18),
      decoration: BoxDecoration(
        color: VentvoColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: VentvoColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: VentvoColors.textMuted,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            vent.voiceMark,
            style: const TextStyle(
              color: VentvoColors.textMuted,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            vent.content,
            style: const TextStyle(
              color: VentvoColors.textPrimary,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
