import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../../../systems/resonance/models/resonance_candidate.dart';
import '../../../systems/resonance/models/resonance_connection.dart';
import '../../../systems/resonance/providers/resonance_provider.dart';
import '../../ventvo_voice/models/vent.dart';
import '../../ventvo_voice/providers/vent_provider.dart';
import 'resonance_relationship_screen.dart';
import '../../ventvo_voice/providers/voice_provider.dart';
import 'resonance_conversation_screen.dart';

class ResonanceConnectionsScreen extends ConsumerStatefulWidget {
  const ResonanceConnectionsScreen({super.key});

  @override
  ConsumerState<ResonanceConnectionsScreen> createState() =>
      _ResonanceConnectionsScreenState();
}

class _ResonanceConnectionsScreenState
    extends ConsumerState<ResonanceConnectionsScreen> {
  late Future<List<_ConnectionView>> _connectionsFuture;

  @override
  void initState() {
    super.initState();
    _connectionsFuture = _loadConnections();
  }

  Future<List<_ConnectionView>> _loadConnections() async {
    final vents = await ref.read(ventProvider.future);
    final voice = await ref.read(ventvoVoiceProvider.future);
    final localVoiceId = voice?.voiceId;
    final ventById = {for (final vent in vents) vent.id: vent};
    final engine = ref.read(resonanceEngineProvider);
    final seen = <String>{};
    final views = <_ConnectionView>[];

    for (final vent in vents) {
      final connections = await engine.getConnectionsInvolving(vent.id);
      for (final connection in connections) {
        if (!seen.add(connection.id)) continue;
        views.add(_ConnectionView(
          connection: connection,
          source: ventById[connection.sourceId],
          target: ventById[connection.targetId],
          localVoiceId: localVoiceId,
        ));
      }
    }

    views.sort((a, b) =>
        b.connection.createdAt.compareTo(a.connection.createdAt));
    return views;
  }

  Future<void> _accept(_ConnectionView view) async {
    final localVoiceId = view.localVoiceId;
    if (localVoiceId == null) return;
    final updated = await ref.read(resonanceConnectionServiceProvider)
        .accept(view.connection, actorVoiceId: localVoiceId);
    if (updated == null || !mounted) return;
    setState(() => _connectionsFuture = _loadConnections());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Connection accepted.')),
    );
  }

  void _openConnection(_ConnectionView view) {
    final localVoiceId = view.localVoiceId;
    if (localVoiceId == null) return;

    final localIsSource = view.connection.sourceVoiceId == localVoiceId;
    final counterpart = localIsSource ? view.target : view.source;
    if (counterpart == null) return;

    final candidate = ResonanceCandidate(
      id: counterpart.id,
      type: ResonanceCandidateType.vent,
      voiceMark: counterpart.voiceMark,
      voiceId: counterpart.ownerVoiceId,
      score: view.connection.strength,
    );

    final screen = view.connection.state == ResonanceConnectionState.active
        ? ResonanceConversationScreen(
            candidate: candidate,
            connection: view.connection,
          )
        : ResonanceRelationshipScreen(
            candidate: candidate,
            connection: view.connection,
          );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VentvoColors.background,
      appBar: AppBar(
        backgroundColor: VentvoColors.background,
        elevation: 0,
        title: const Text('Your Resonances'),
      ),
      body: FutureBuilder<List<_ConnectionView>>(
        future: _connectionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const _EmptyState(
              title: 'Your Resonances could not be loaded.',
              subtitle: 'Try again in a moment.',
            );
          }
          final connections = snapshot.data ?? const <_ConnectionView>[];
          if (connections.isEmpty) {
            return const _EmptyState(
              title: 'Nothing here yet.',
              subtitle:
                  'When you leave a Resonance for an experience, it will stay here while the connection develops.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              setState(() => _connectionsFuture = _loadConnections());
              await _connectionsFuture;
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
              itemCount: connections.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final view = connections[index];
                final isParticipant = view.localVoiceId != null &&
                    (view.connection.sourceVoiceId == view.localVoiceId ||
                        view.connection.targetVoiceId == view.localVoiceId);
                return _ConnectionCard(
                  view: view,
                  onAccept: view.connection.state ==
                              ResonanceConnectionState.suggested &&
                          view.target != null &&
                          view.localVoiceId != null &&
                          view.connection.targetVoiceId == view.localVoiceId
                      ? () => _accept(view)
                      : null,
                  onOpen: (view.connection.state ==
                              ResonanceConnectionState.accepted ||
                          view.connection.state ==
                              ResonanceConnectionState.active) &&
                      view.target != null &&
                      isParticipant
                      ? () => _openConnection(view)
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ConnectionView {
  final ResonanceConnection connection;
  final Vent? source;
  final Vent? target;
  final String? localVoiceId;

  const _ConnectionView({
    required this.connection,
    required this.source,
    required this.target,
    required this.localVoiceId,
  });
}

class _ConnectionCard extends StatelessWidget {
  final _ConnectionView view;
  final VoidCallback? onAccept;
  final VoidCallback? onOpen;

  const _ConnectionCard({
    required this.view,
    this.onAccept,
    this.onOpen,
  });

  String get _status {
    switch (view.connection.state) {
      case ResonanceConnectionState.suggested:
        if (view.target == null || view.localVoiceId == null) {
          return 'Waiting for their resonance';
        }
        if (view.connection.targetVoiceId == view.localVoiceId) {
          return 'Someone resonated with this experience';
        }
        return 'Waiting for their response';
      case ResonanceConnectionState.accepted:
        return 'Mutual Resonance';
      case ResonanceConnectionState.active:
        return 'Connection open';
      case ResonanceConnectionState.closed:
        return 'Resonance closed';
      case ResonanceConnectionState.blocked:
        return 'Resonance blocked';
    }
  }

  String get _title {
    if (view.source != null && view.target != null) {
      return '${view.source!.voiceMark} ↔ ${view.target!.voiceMark}';
    }
    final vent = view.source ?? view.target;
    return vent == null ? 'Resonance' : 'Resonance · ${vent.voiceMark}';
  }

  @override
  Widget build(BuildContext context) {
    final vent = view.target ?? view.source;
    return Container(
      padding: const EdgeInsets.fromLTRB(17, 17, 17, 16),
      decoration: BoxDecoration(
        color: VentvoColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: VentvoColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.waves_rounded, size: 19, color: VentvoColors.textSecondary),
            const SizedBox(width: 9),
            Expanded(child: Text(_title, style: const TextStyle(
              color: VentvoColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600,
            ))),
          ]),
          const SizedBox(height: 9),
          Text(_status, style: const TextStyle(
            color: VentvoColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500,
          )),
          if (vent != null) ...[
            const SizedBox(height: 7),
            Text(vent.content, maxLines: 3, overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: VentvoColors.textMuted, fontSize: 12, height: 1.45)),
          ],
          if (onAccept != null) ...[
            const SizedBox(height: 14),
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: onAccept, child: const Text('Resonate back'),
            )),
          ],
          if (onOpen != null) ...[
            const SizedBox(height: 14),
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: onOpen,
              child: Text(
                view.connection.state == ResonanceConnectionState.active
                    ? 'Open connection'
                    : 'View mutual Resonance',
              ),
            )),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  const _EmptyState({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.waves_outlined, size: 42, color: VentvoColors.textMuted),
        const SizedBox(height: 18),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(
          color: VentvoColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600,
        )),
        const SizedBox(height: 8),
        Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(
          color: VentvoColors.textMuted, fontSize: 13, height: 1.5,
        )),
      ]),
    ),
  );
}