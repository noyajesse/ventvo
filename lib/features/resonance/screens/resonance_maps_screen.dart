import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../../spaces/models/space.dart';
import '../../spaces/models/echo_note.dart';
import '../../spaces/providers/space_provider.dart';
import '../../spaces/screens/space_screen.dart';
import '../../ventvo_voice/models/vent.dart';
import '../../ventvo_voice/providers/vent_provider.dart';
import '../../../systems/resonance/models/resonance_connection.dart';
import '../../../systems/resonance/models/resonance_map.dart';
import '../../../systems/resonance/models/resonance_thread.dart';
import '../models/resonance_map_experience.dart';
import '../providers/resonance_map_experience_provider.dart';
import '../providers/resonance_map_threads_provider.dart';
import '../providers/resonance_maps_provider.dart';
import 'resonance_thread_detail_screen.dart';

class ResonanceMapsScreen extends ConsumerWidget {
  const ResonanceMapsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maps = ref.watch(resonanceMapsProvider);
    final vents = ref.watch(ventProvider).asData?.value ?? const <Vent>[];
    final ventsById = {for (final vent in vents) vent.id: vent};

    return Scaffold(
      backgroundColor: VentvoColors.background,
      appBar: AppBar(title: const Text('Resonance Maps'), centerTitle: true),
      body: maps.when(
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
        error: (_, _) => const Center(child: Text('Resonance Maps could not be loaded yet.')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 36),
                child: Text(
                  'Nothing has formed a map yet.\n\nAs experiences become meaningfully connected, Ventvo can reveal the larger landscape around them.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: VentvoColors.textMuted, fontSize: 13, height: 1.6),
                ),
              ),
            );
          }
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final map = items[index];
              return _MapCard(
                map: map,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ResonanceMapDetailScreen(map: map, ventsById: ventsById),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  final ResonanceMap map;
  final VoidCallback onTap;
  const _MapCard({required this.map, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: VentvoColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: VentvoColors.border),
        ),
        child: Row(
          children: [
            SizedBox(width: 112, height: 84, child: _ResonanceConstellation(map: map)),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('RESONANCE MAP', style: TextStyle(color: VentvoColors.textMuted, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
                  const SizedBox(height: 9),
                  Text('${map.experienceIds.length} connected experiences', style: const TextStyle(color: VentvoColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 5),
                  Text('${map.connections.length} relationships', style: const TextStyle(color: VentvoColors.textMuted, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, size: 17, color: VentvoColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class ResonanceMapDetailScreen extends ConsumerWidget {
  final ResonanceMap map;
  final Map<String, Vent> ventsById;
  const ResonanceMapDetailScreen({super.key, required this.map, required this.ventsById});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spaces = ref.watch(spaceProvider).asData?.value ?? const <Space>[];
    final spacesById = {for (final space in spaces) space.id: space};
    final resolver = ref.watch(resonanceMapExperienceResolverProvider);
    final threads = ref.watch(resonanceMapThreadsProvider(map.id));

    return Scaffold(
      backgroundColor: VentvoColors.background,
      appBar: AppBar(title: const Text('Resonance Map'), centerTitle: true),
      body: FutureBuilder<List<ResonanceMapExperience>>(
        future: resolver.resolve(experienceIds: map.experienceIds, ventsById: ventsById, spacesById: spacesById),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 1.5));
          }
          final experiences = snapshot.data ?? const <ResonanceMapExperience>[];
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
            children: [
              const Text('RESONANCE MAP', style: TextStyle(color: VentvoColors.textMuted, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
              const SizedBox(height: 10),
              const Text('A landscape of connected experiences', style: TextStyle(color: VentvoColors.textPrimary, fontSize: 21, fontWeight: FontWeight.w600, height: 1.25)),
              const SizedBox(height: 8),
              Text('${map.experienceIds.length} experiences · ${map.connections.length} relationships', style: const TextStyle(color: VentvoColors.textMuted, fontSize: 12)),
              const SizedBox(height: 24),
              Container(
                height: 300,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: VentvoColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: VentvoColors.border)),
                child: _ResonanceConstellation(map: map, detailed: true),
              ),
              const SizedBox(height: 24),
              ...experiences.map((experience) => _MapExperienceCard(experience: experience)),
              const SizedBox(height: 16),
              threads.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (items) => items.isEmpty ? const SizedBox.shrink() : _MapThreadsSection(threads: items, ventsById: ventsById),
              ),
              const SizedBox(height: 8),
              ...map.connections.map(_ConnectionCard.new),
              const SizedBox(height: 8),
              const Text('The Map shows the larger landscape. A Thread tells the story of one connected path through it.', style: TextStyle(color: VentvoColors.textSecondary, fontSize: 13, height: 1.55)),
            ],
          );
        },
      ),
    );
  }
}

class _MapThreadsSection extends StatelessWidget {
  final List<ResonanceThread> threads;
  final Map<String, Vent> ventsById;

  const _MapThreadsSection({required this.threads, required this.ventsById});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('THREADS WITHIN THIS MAP', style: TextStyle(color: VentvoColors.textMuted, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
        const SizedBox(height: 10),
        ...threads.map(
          (thread) => InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ResonanceThreadDetailScreen(thread: thread, ventsById: ventsById)),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
              decoration: BoxDecoration(color: VentvoColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: VentvoColors.border)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(thread.voiceMarks.isEmpty ? 'Connected experiences' : thread.voiceMarks.join('  ·  '), style: const TextStyle(color: VentvoColors.textSecondary, fontSize: 11)),
                        const SizedBox(height: 5),
                        Text('${thread.experienceIds.length} experiences · ${thread.connections.length} connections', style: const TextStyle(color: VentvoColors.textMuted, fontSize: 10)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, size: 16, color: VentvoColors.textMuted),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MapExperienceCard extends StatelessWidget {
  final ResonanceMapExperience experience;
  const _MapExperienceCard({required this.experience});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 13),
      decoration: BoxDecoration(color: VentvoColors.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: VentvoColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Text(experience.voiceMark, style: const TextStyle(color: VentvoColors.textSecondary, fontSize: 11)), const Spacer(), Text(experience.isEcho ? 'ECHO' : 'VENT', style: const TextStyle(color: VentvoColors.textMuted, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1.2))]),
          const SizedBox(height: 8),
          Text(experience.content, maxLines: 5, overflow: TextOverflow.ellipsis, style: const TextStyle(color: VentvoColors.textPrimary, fontSize: 14, height: 1.5)),
          if (experience.echoNotes.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...experience.echoNotes.take(2).map(_EchoNotePreview.new),
          ],
          if (experience.space != null)
            Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => SpaceScreen.open(context, experience.space!), child: const Text('Open Space'))),
        ],
      ),
    );
  }
}

class _EchoNotePreview extends StatelessWidget {
  final EchoNote note;
  const _EchoNotePreview(this.note);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(color: VentvoColors.surfaceElevated, borderRadius: BorderRadius.circular(14), border: Border.all(color: VentvoColors.border)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(note.voiceMark, style: const TextStyle(color: VentvoColors.textMuted, fontSize: 10)), const SizedBox(width: 9), Expanded(child: Text(note.content, style: const TextStyle(color: VentvoColors.textSecondary, fontSize: 12, height: 1.5)))]),
    );
  }
}

class _ResonanceConstellation extends StatelessWidget {
  final ResonanceMap map;
  final bool detailed;
  const _ResonanceConstellation({required this.map, this.detailed = false});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final visibleIds = map.experienceIds.take(detailed ? 9 : 5).toList();
      final positions = <String, Offset>{};
      final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
      final radius = math.min(constraints.maxWidth, constraints.maxHeight) * (detailed ? 0.32 : 0.30);
      for (var i = 0; i < visibleIds.length; i++) {
        final angle = (-math.pi / 2) + (i * math.pi * 2 / visibleIds.length);
        positions[visibleIds[i]] = Offset(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle));
      }
      return Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _ConstellationPainter(map: map, positions: positions))),
        for (final id in visibleIds)
          Positioned(left: positions[id]!.dx - (detailed ? 22 : 13.5), top: positions[id]!.dy - (detailed ? 22 : 13.5), child: _MapNode(label: _nodeLabel(id), large: detailed)),
      ]);
    });
  }

  String _nodeLabel(String id) {
    final cleaned = id.startsWith('echo:') ? id.substring(5) : id;
    if (cleaned.isEmpty) return '?';
    return cleaned.substring(0, 1).toUpperCase();
  }
}

class _MapNode extends StatelessWidget {
  final String label;
  final bool large;
  const _MapNode({required this.label, required this.large});

  @override
  Widget build(BuildContext context) {
    final size = large ? 44.0 : 27.0;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: VentvoColors.surfaceElevated,
        shape: BoxShape.circle,
        border: Border.all(color: VentvoColors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: VentvoColors.textSecondary,
          fontSize: large ? 11 : 8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ConstellationPainter extends CustomPainter {
  final ResonanceMap map;
  final Map<String, Offset> positions;
  const _ConstellationPainter({required this.map, required this.positions});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = VentvoColors.border..strokeWidth = 1..style = PaintingStyle.stroke;
    for (final connection in map.connections) {
      final start = positions[connection.sourceId];
      final end = positions[connection.targetId];
      if (start == null || end == null) continue;
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter oldDelegate) => oldDelegate.map.id != map.id || oldDelegate.map.connections.length != map.connections.length;
}

class _ConnectionCard extends StatelessWidget {
  final ResonanceConnection connection;
  const _ConnectionCard(this.connection);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(color: VentvoColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: VentvoColors.border)),
      child: Row(children: [const Icon(Icons.link_rounded, size: 16, color: VentvoColors.textMuted), const SizedBox(width: 10), Expanded(child: Text(_connectionLabel(connection.type), style: const TextStyle(color: VentvoColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)))]),
    );
  }

  String _connectionLabel(ResonanceConnectionType type) {
    switch (type) {
      case ResonanceConnectionType.sharedExperience:
        return 'Shared experience';
      case ResonanceConnectionType.perspective:
        return 'Different perspective';
      case ResonanceConnectionType.response:
        return 'Response';
      case ResonanceConnectionType.similarity:
        return 'Similar experience';
      case ResonanceConnectionType.discovery:
        return 'Discovered connection';
    }
  }
}
