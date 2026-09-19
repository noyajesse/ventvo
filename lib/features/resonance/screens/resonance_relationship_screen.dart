import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../../../systems/resonance/models/resonance_candidate.dart';
import '../../../systems/resonance/models/resonance_connection.dart';
import '../../../systems/resonance/providers/resonance_provider.dart';
import 'resonance_threads_screen.dart';
import 'resonance_conversation_screen.dart';
import '../../ventvo_voice/providers/voice_provider.dart';

class ResonanceRelationshipScreen extends ConsumerStatefulWidget {
  final ResonanceCandidate candidate;
  final ResonanceConnection connection;

  const ResonanceRelationshipScreen({
    super.key,
    required this.candidate,
    required this.connection,
  });

  @override
  ConsumerState<ResonanceRelationshipScreen> createState() =>
      _ResonanceRelationshipScreenState();
}

class _ResonanceRelationshipScreenState
    extends ConsumerState<ResonanceRelationshipScreen> {
  late ResonanceConnection connection;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    connection = widget.connection;
  }

  Future<void> _activate() async {
    if (saving) return;
    setState(() => saving = true);
    final voice = await ref.read(ventvoVoiceProvider.future);
    final actorVoiceId = voice?.voiceId;
    if (actorVoiceId == null || actorVoiceId.trim().isEmpty) {
      if (mounted) setState(() => saving = false);
      return;
    }
    final updated = await ref.read(resonanceConnectionServiceProvider)
        .activate(connection, actorVoiceId: actorVoiceId);
    if (!mounted) return;
    if (updated == null) {
      setState(() => saving = false);
      return;
    }
    setState(() {
      connection = updated;
      saving = false;
    });
    if (updated.state == ResonanceConnectionState.active && mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ResonanceConversationScreen(
          candidate: widget.candidate,
          connection: updated,
        ),
      ));
    }
  }

  Future<void> _finish({required bool block}) async {
    if (saving) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(block ? 'Block this Resonance?' : 'Close this Resonance?'),
        content: Text(block
            ? 'This relationship will be blocked and cannot become active again.'
            : 'This relationship will be closed and will no longer be active.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(block ? 'Block' : 'Close')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => saving = true);
    final voice = await ref.read(ventvoVoiceProvider.future);
    final actorVoiceId = voice?.voiceId;
    if (actorVoiceId == null || actorVoiceId.trim().isEmpty) {
      if (mounted) setState(() => saving = false);
      return;
    }
    final service = ref.read(resonanceConnectionServiceProvider);
    final updated = block
        ? await service.block(connection, actorVoiceId: actorVoiceId)
        : await service.close(connection, actorVoiceId: actorVoiceId);
    if (!mounted) return;
    if (updated == null) {
      setState(() => saving = false);
      return;
    }
    Navigator.of(context).pop(updated);
  }

  void _openRelatedThreads() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ResonanceThreadsScreen(experienceId: widget.candidate.id),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final voiceId = ref.watch(ventvoVoiceProvider).asData?.value?.voiceId;
    final isParticipant = voiceId != null &&
        (connection.sourceVoiceId == voiceId || connection.targetVoiceId == voiceId);
    final canActivate = connection.state == ResonanceConnectionState.accepted && isParticipant;
    final isActive = connection.state == ResonanceConnectionState.active;
    final isTerminal = connection.state == ResonanceConnectionState.closed ||
        connection.state == ResonanceConnectionState.blocked;

    return Scaffold(
      backgroundColor: VentvoColors.background,
      appBar: AppBar(title: const Text('Resonance'), backgroundColor: VentvoColors.background),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            Text(widget.candidate.voiceMark ?? 'RESONANCE', style: const TextStyle(color: VentvoColors.textMuted, fontSize: 10, letterSpacing: 1.1, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            const Text('There is a connection here.', style: TextStyle(color: VentvoColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w600, height: 1.2)),
            const SizedBox(height: 10),
            Text(_stateDescription(connection.state), style: const TextStyle(color: VentvoColors.textSecondary, fontSize: 14, height: 1.5)),
            const SizedBox(height: 26),
            _RelationshipDetail(label: 'RELATIONSHIP', value: _typeLabel(connection.type)),
            const SizedBox(height: 14),
            _RelationshipDetail(label: 'STATE', value: _stateLabel(connection.state)),
            if (isActive) ...[
              const SizedBox(height: 28),
              _ActionButton(label: 'Explore related Threads', onPressed: saving ? null : _openRelatedThreads, primary: true),
              const SizedBox(height: 9),
              const Text('Active Resonance can become part of a deeper Thread when enough meaningful experiences connect around it.', style: TextStyle(color: VentvoColors.textMuted, fontSize: 12, height: 1.5)),
            ],
            const SizedBox(height: 30),
            if (canActivate) _ActionButton(label: 'Continue with this Resonance', onPressed: saving ? null : _activate, primary: true),
            if (!isTerminal) ...[
              if (canActivate) const SizedBox(height: 10),
              _ActionButton(label: 'Close Resonance', onPressed: saving ? null : () => _finish(block: false)),
              const SizedBox(height: 8),
              _ActionButton(label: 'Block Resonance', onPressed: saving ? null : () => _finish(block: true)),
            ],
          ],
        ),
      ),
    );
  }

  String _stateDescription(ResonanceConnectionState state) {
    switch (state) {
      case ResonanceConnectionState.suggested: return 'This connection has been discovered but not accepted yet.';
      case ResonanceConnectionState.accepted: return 'You chose to resonate. You can now decide whether to continue this relationship.';
      case ResonanceConnectionState.active: return 'This Resonance is active. It can contribute to deeper Threads and Maps.';
      case ResonanceConnectionState.closed: return 'This Resonance has been closed.';
      case ResonanceConnectionState.blocked: return 'This Resonance has been blocked.';
    }
  }

  String _stateLabel(ResonanceConnectionState state) {
    switch (state) {
      case ResonanceConnectionState.suggested: return 'SUGGESTED';
      case ResonanceConnectionState.accepted: return 'ACCEPTED';
      case ResonanceConnectionState.active: return 'ACTIVE';
      case ResonanceConnectionState.closed: return 'CLOSED';
      case ResonanceConnectionState.blocked: return 'BLOCKED';
    }
  }

  String _typeLabel(ResonanceConnectionType type) {
    switch (type) {
      case ResonanceConnectionType.similarity: return 'SIMILAR EXPERIENCE';
      case ResonanceConnectionType.sharedExperience: return 'SHARED EXPERIENCE';
      case ResonanceConnectionType.perspective: return 'DIFFERENT PERSPECTIVE';
      case ResonanceConnectionType.response: return 'RESPONSE';
      case ResonanceConnectionType.discovery: return 'DISCOVERED CONNECTION';
    }
  }
}

class _RelationshipDetail extends StatelessWidget {
  final String label;
  final String value;
  const _RelationshipDetail({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: VentvoColors.textMuted, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
      const SizedBox(height: 5),
      Text(value, style: const TextStyle(color: VentvoColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
    ],
  );
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  const _ActionButton({required this.label, required this.onPressed, this.primary = false});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: primary ? FilledButton(onPressed: onPressed, child: Text(label)) : OutlinedButton(onPressed: onPressed, child: Text(label)),
  );
}
