import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../../spaces/models/space.dart';
import '../../spaces/providers/space_provider.dart';
import '../../spaces/screens/space_screen.dart';
import '../../ventvo_voice/models/vent.dart';
import '../../ventvo_voice/providers/vent_provider.dart';
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
      appBar: AppBar(title: const Text('Maps'), centerTitle: true),
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
          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 36),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 18),
            itemBuilder: (context, index) {
              final map = items[index];
              return _MapPreview(
                map: map,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ResonanceMapDetailScreen(map: map, ventsById: ventsById)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _MapPreview extends StatelessWidget {
  final ResonanceMap map;
  final VoidCallback onTap;

  const _MapPreview({required this.map, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        height: 244,
        decoration: BoxDecoration(
          color: VentvoColors.surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: VentvoColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 18, 12, 54),
                child: _ResonanceConstellation(map: map),
              ),
            ),
            const Positioned(
              left: 18,
              top: 16,
              child: Text(
                'RESONANCE MAP',
                style: TextStyle(color: VentvoColors.textMuted, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1.5),
              ),
            ),
            Positioned(
              left: 18,
              bottom: 17,
              child: Text(
                '${map.experienceIds.length} experiences found each other',
                style: const TextStyle(color: VentvoColors.textSecondary, fontSize: 12),
              ),
            ),
            const Positioned(
              right: 18,
              bottom: 15,
              child: Icon(Icons.arrow_forward_rounded, size: 17, color: VentvoColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class ResonanceMapDetailScreen extends ConsumerStatefulWidget {
  final ResonanceMap map;
  final Map<String, Vent> ventsById;

  const ResonanceMapDetailScreen({super.key, required this.map, required this.ventsById});

  @override
  ConsumerState<ResonanceMapDetailScreen> createState() => _ResonanceMapDetailScreenState();
}

class _ResonanceMapDetailScreenState extends ConsumerState<ResonanceMapDetailScreen> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final spaces = ref.watch(spaceProvider).asData?.value ?? const <Space>[];
    final spacesById = {for (final space in spaces) space.id: space};
    final resolver = ref.watch(resonanceMapExperienceResolverProvider);
    final threads = ref.watch(resonanceMapThreadsProvider(widget.map.id));

    return Scaffold(
      backgroundColor: VentvoColors.background,
      appBar: AppBar(title: const Text('Map'), centerTitle: true),
      body: FutureBuilder<List<ResonanceMapExperience>>(
        future: resolver.resolve(
          experienceIds: widget.map.experienceIds,
          ventsById: widget.ventsById,
          spacesById: spacesById,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 1.5));
          }

          final experiences = snapshot.data ?? const <ResonanceMapExperience>[];
          final selected = _selectedExperience(experiences);

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 40),
            children: [
              const Text(
                'RESONANCE MAP',
                style: TextStyle(color: VentvoColors.textMuted, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1.5),
              ),
              const SizedBox(height: 10),
              const Text(
                'Some experiences find each other.',
                style: TextStyle(color: VentvoColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w600, height: 1.25),
              ),
              const SizedBox(height: 7),
              const Text(
                'A wider landscape formed from meaningful Resonance.',
                style: TextStyle(color: VentvoColors.textMuted, fontSize: 12, height: 1.5),
              ),
              const SizedBox(height: 22),
              Container(
                height: 390,
                decoration: BoxDecoration(
                  color: VentvoColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: VentvoColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: _InteractiveConstellation(
                  map: widget.map,
                  experiences: experiences,
                  selectedId: _selectedId,
                  onSelected: (id) => setState(() => _selectedId = id),
                ),
              ),
              const SizedBox(height: 18),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: selected == null
                    ? const _MapPrompt(key: ValueKey('prompt'))
                    : _SelectedExperience(key: ValueKey(selected.id), experience: selected),
              ),
              const SizedBox(height: 22),
              threads.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (items) => items.isEmpty
                    ? const SizedBox.shrink()
                    : _MapThreadsSection(threads: items, ventsById: widget.ventsById),
              ),
            ],
          );
        },
      ),
    );
  }

  ResonanceMapExperience? _selectedExperience(List<ResonanceMapExperience> experiences) {
    if (_selectedId == null) return null;
    for (final experience in experiences) {
      if (experience.id == _selectedId) return experience;
    }
    return null;
  }
}

class _MapPrompt extends StatelessWidget {
  const _MapPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Icon(Icons.touch_app_outlined, size: 17, color: VentvoColors.textMuted),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Touch an experience to see where it leads.',
              style: TextStyle(color: VentvoColors.textMuted, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedExperience extends StatelessWidget {
  final ResonanceMapExperience experience;

  const _SelectedExperience({super.key, required this.experience});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      decoration: BoxDecoration(
        color: VentvoColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: VentvoColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            experience.voiceMark,
            style: const TextStyle(color: VentvoColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 9),
          Text(
            experience.content,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: VentvoColors.textPrimary, fontSize: 14, height: 1.55),
          ),
          if (experience.space != null) ...[
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => SpaceScreen.open(context, experience.space!),
                child: const Text('Open Space'),
              ),
            ),
          ],
        ],
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
        const Text(
          'THREADS WITHIN THIS MAP',
          style: TextStyle(color: VentvoColors.textMuted, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1.4),
        ),
        const SizedBox(height: 10),
        ...threads.map(
          (thread) => Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: InkWell(
              borderRadius: BorderRadius.circular(17),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ResonanceThreadDetailScreen(thread: thread, ventsById: ventsById),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(15, 14, 13, 14),
                decoration: BoxDecoration(
                  color: VentvoColors.surface,
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: VentvoColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.route_outlined, size: 17, color: VentvoColors.textMuted),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        thread.voiceMarks.isEmpty ? 'A connected path' : thread.voiceMarks.join('  ·  '),
                        style: const TextStyle(color: VentvoColors.textSecondary, fontSize: 12),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_rounded, size: 16, color: VentvoColors.textMuted),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ResonanceConstellation extends StatelessWidget {
  final ResonanceMap map;

  const _ResonanceConstellation({required this.map});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final positions = _buildPositions(map.experienceIds, Size(constraints.maxWidth, constraints.maxHeight));
        return CustomPaint(
          painter: _ConstellationPainter(map: map, positions: positions),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _InteractiveConstellation extends StatelessWidget {
  final ResonanceMap map;
  final List<ResonanceMapExperience> experiences;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  const _InteractiveConstellation({
    required this.map,
    required this.experiences,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final ids = experiences.isEmpty ? map.experienceIds : experiences.map((experience) => experience.id).toList();
        final positions = _buildPositions(ids, size);
        final labels = {for (final experience in experiences) experience.id: experience.voiceMark};

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _ConstellationPainter(map: map, positions: positions, selectedId: selectedId),
              ),
            ),
            for (final id in ids)
              if (positions[id] != null)
                Positioned(
                  left: positions[id]!.dx - 31,
                  top: positions[id]!.dy - 31,
                  width: 62,
                  height: 62,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onSelected(id),
                    child: _ConstellationNode(label: labels[id] ?? _fallbackLabel(id), selected: selectedId == id),
                  ),
                ),
          ],
        );
      },
    );
  }
}

class _ConstellationNode extends StatelessWidget {
  final String label;
  final bool selected;

  const _ConstellationNode({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: selected ? 25 : 17,
            height: selected ? 25 : 17,
            decoration: BoxDecoration(
              color: selected ? VentvoColors.primary : VentvoColors.surfaceElevated,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? VentvoColors.primary : VentvoColors.secondary.withValues(alpha: 0.55),
                width: selected ? 2 : 1,
              ),
              boxShadow: selected
                  ? [BoxShadow(color: VentvoColors.primary.withValues(alpha: 0.28), blurRadius: 18, spreadRadius: 3)]
                  : null,
            ),
          ),
          const SizedBox(height: 5),
          if (label.isNotEmpty)
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? VentvoColors.textPrimary : VentvoColors.textMuted,
                fontSize: 9,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

Map<String, Offset> _buildPositions(List<String> ids, Size size) {
  if (ids.isEmpty) return const {};

  final center = Offset(size.width / 2, size.height / 2);
  final positions = <String, Offset>{};

  if (ids.length == 1) {
    positions[ids.first] = center;
    return positions;
  }

  positions[ids.first] = center;
  final outerIds = ids.skip(1).toList();
  final radius = math.min(size.width, size.height) * 0.29;
  final goldenAngle = math.pi * (3 - math.sqrt(5));

  for (var i = 0; i < outerIds.length; i++) {
    final angle = -math.pi / 2 + i * goldenAngle;
    final distance = radius * (0.82 + (i % 3) * 0.09);
    positions[outerIds[i]] = Offset(
      center.dx + math.cos(angle) * distance,
      center.dy + math.sin(angle) * distance,
    );
  }

  return positions;
}

class _ConstellationPainter extends CustomPainter {
  final ResonanceMap map;
  final Map<String, Offset> positions;
  final String? selectedId;

  const _ConstellationPainter({required this.map, required this.positions, this.selectedId});

  @override
  void paint(Canvas canvas, Size size) {
    for (final connection in map.connections) {
      final start = positions[connection.sourceId];
      final end = positions[connection.targetId];
      if (start == null || end == null) continue;

      final selected = selectedId != null && (connection.sourceId == selectedId || connection.targetId == selectedId);
      final paint = Paint()
        ..color = selected
            ? VentvoColors.primary.withValues(alpha: 0.58)
            : VentvoColors.secondary.withValues(alpha: 0.16)
        ..strokeWidth = selected ? 1.4 : 0.9
        ..style = PaintingStyle.stroke;

      canvas.drawLine(start, end, paint);
    }

    final center = positions[map.experienceIds.isEmpty ? '' : map.experienceIds.first];
    if (center != null) {
      final glow = Paint()
        ..color = VentvoColors.primary.withValues(alpha: 0.07)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
      canvas.drawCircle(center, 34, glow);
    }
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter oldDelegate) {
    return oldDelegate.map.id != map.id ||
        oldDelegate.map.connections.length != map.connections.length ||
        oldDelegate.selectedId != selectedId ||
        oldDelegate.positions.length != positions.length;
  }
}

String _fallbackLabel(String id) {
  final cleaned = id.startsWith('echo:') ? id.substring(5) : id;
  if (cleaned.isEmpty) return '';
  return cleaned.substring(0, 1).toUpperCase();
}
