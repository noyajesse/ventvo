import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../../../systems/resonance/models/resonance_connection.dart';
import '../../../systems/resonance/models/resonance_map.dart';
import '../providers/resonance_maps_provider.dart';

class ResonanceMapsScreen extends ConsumerWidget {
  const ResonanceMapsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maps = ref.watch(resonanceMapsProvider);

    return Scaffold(
      backgroundColor: VentvoColors.background,
      appBar: AppBar(
        title: const Text('Resonance Maps'),
        centerTitle: true,
      ),
      body: maps.when(
        loading: () => const Center(
          child: CircularProgressIndicator(strokeWidth: 1.5),
        ),
        error: (_, _) => const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Resonance Maps could not be loaded yet.',
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
                      'Nothing has formed a map yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: VentvoColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'As experiences become meaningfully connected, Ventvo can reveal the larger landscape around them.',
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
              final map = items[index];
              return _MapCard(
                map: map,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ResonanceMapDetailScreen(map: map),
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
        padding: const EdgeInsets.fromLTRB(14, 14, 16, 15),
        decoration: BoxDecoration(
          color: VentvoColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: VentvoColors.border),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 112,
              height: 84,
              child: _ResonanceConstellation(map: map),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RESONANCE MAP',
                    style: TextStyle(
                      color: VentvoColors.textMuted,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    '${map.experienceIds.length} connected experiences',
                    style: const TextStyle(
                      color: VentvoColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${map.connections.length} relationships',
                    style: const TextStyle(
                      color: VentvoColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 17,
              color: VentvoColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class ResonanceMapDetailScreen extends StatelessWidget {
  final ResonanceMap map;

  const ResonanceMapDetailScreen({super.key, required this.map});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VentvoColors.background,
      appBar: AppBar(
        title: const Text('Resonance Map'),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
        children: [
          const Text(
            'RESONANCE MAP',
            style: TextStyle(
              color: VentvoColors.textMuted,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'A landscape of connected experiences',
            style: TextStyle(
              color: VentvoColors.textPrimary,
              fontSize: 21,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${map.experienceIds.length} experiences · ${map.connections.length} relationships',
            style: const TextStyle(
              color: VentvoColors.textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 300,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: VentvoColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: VentvoColors.border),
            ),
            child: _ResonanceConstellation(map: map, detailed: true),
          ),
          const SizedBox(height: 22),
          ...map.connections.map(_ConnectionCard.new),
          const SizedBox(height: 8),
          const Text(
            'The Map shows the larger landscape. A Thread tells the story of one connected path through it.',
            style: TextStyle(
              color: VentvoColors.textSecondary,
              fontSize: 13,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResonanceConstellation extends StatelessWidget {
  final ResonanceMap map;
  final bool detailed;

  const _ResonanceConstellation({required this.map, this.detailed = false});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ConstellationPainter(map: map),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: detailed ? 20 : 8,
          runSpacing: detailed ? 18 : 8,
          children: map.experienceIds.take(detailed ? 9 : 5).map(
            (id) => _MapNode(
              label: _nodeLabel(id),
              large: detailed,
            ),
          ).toList(),
        ),
      ),
    );
  }

  String _nodeLabel(String id) {
    final cleaned = id.startsWith('echo:') ? id.substring(5) : id;
    if (cleaned.length <= 2) return cleaned.toUpperCase();
    return cleaned.characters.first.toUpperCase();
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

  const _ConstellationPainter({required this.map});

  @override
  void paint(Canvas canvas, Size size) {
    if (map.experienceIds.length < 2) return;

    final paint = Paint()
      ..color = VentvoColors.border
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.30;
    final positions = <String, Offset>{};

    for (var i = 0; i < map.experienceIds.length; i++) {
      final angle = (-3.14159 / 2) + (i * 6.28318 / map.experienceIds.length);
      positions[map.experienceIds[i]] = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
    }

    for (final connection in map.connections) {
      final start = positions[connection.sourceId];
      final end = positions[connection.targetId];
      if (start == null || end == null) continue;
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter oldDelegate) {
    return oldDelegate.map.id != map.id ||
        oldDelegate.map.connections.length != map.connections.length ||
        oldDelegate.map.experienceIds.length != map.experienceIds.length;
  }
}

class _ConnectionCard extends StatelessWidget {
  final ResonanceConnection connection;

  const _ConnectionCard(this.connection);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: VentvoColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VentvoColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.link_rounded,
            size: 16,
            color: VentvoColors.textMuted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _connectionLabel(connection.type),
              style: const TextStyle(
                color: VentvoColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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
