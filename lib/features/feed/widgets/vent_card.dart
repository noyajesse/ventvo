import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../spaces/models/space.dart';
import '../../spaces/providers/space_provider.dart';
import '../../spaces/screens/space_screen.dart';
import '../../ventvo_voice/models/vent.dart';

class VentCard extends ConsumerStatefulWidget {
  final Vent vent;
  final int index;

  const VentCard({
    super.key,
    required this.vent,
    required this.index,
  });

  @override
  ConsumerState<VentCard> createState() => _VentCardState();
}

class _VentCardState extends ConsumerState<VentCard> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final spacesAsync = ref.watch(spaceProvider);

    return spacesAsync.when(
      loading: () => _buildMoment(context, null),
      error: (_, _) => _buildMoment(context, null),
      data: (spaces) {
        final space = spaces
            .where((item) => item.id == widget.vent.spaceId)
            .firstOrNull;

        return _buildMoment(context, space);
      },
    );
  }

  Widget _buildMoment(BuildContext context, Space? space) {
    final text = widget.vent.content.trim();
    final short = text.length < 75;
    final medium = text.length >= 75 && text.length < 150;

    final topSpacing = widget.index == 0
        ? 20.0
        : short
            ? 42.0
            : 52.0;

    final bottomSpacing = short
        ? 30.0
        : medium
            ? 42.0
            : 54.0;

    return AnimatedScale(
      scale: pressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: space == null
            ? null
            : (_) => setState(() => pressed = true),
        onTapCancel: space == null
            ? null
            : () => setState(() => pressed = false),
        onTapUp: space == null
            ? null
            : (_) async {
                setState(() => pressed = false);
                await SpaceScreen.open(context, space);
              },
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            8,
            topSpacing,
            8,
            bottomSpacing,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _voiceLine(),

              SizedBox(height: short ? 14 : 18),

              Hero(
                tag: 'moment-${widget.vent.id}',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    text,
                    maxLines: medium || !short ? 5 : 4,
                    overflow: TextOverflow.fade,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: short ? 22 : 25,
                      height: 1.43,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),

              if (space != null) ...[
                const SizedBox(height: 22),
                _continuationCue(),
              ],

              const SizedBox(height: 24),

              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _voiceLine() {
    return Row(
      children: [
        Text(
          widget.vent.voiceMark,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          _timeAgo(widget.vent.createdAt),
          style: const TextStyle(
            color: Colors.white24,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _continuationCue() {
    return Row(
      children: [
        Container(
          width: 28,
          height: 1,
          color: Colors.white.withValues(alpha: 0.16),
        ),
        const SizedBox(width: 9),
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.25),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 9),
        const Text(
          'there is more here',
          style: TextStyle(
            color: Colors.white30,
            fontSize: 10,
            letterSpacing: 0.25,
          ),
        ),
      ],
    );
  }

  String _timeAgo(DateTime time) {
    final difference = DateTime.now().difference(time);

    if (difference.inMinutes < 1) {
      return 'now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours}h';
    }

    return '${difference.inDays}d';
  }
}