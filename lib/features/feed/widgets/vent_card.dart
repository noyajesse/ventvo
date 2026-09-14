import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../../spaces/models/space.dart';
import '../../spaces/providers/space_provider.dart';
import '../../spaces/screens/space_screen.dart';
import '../../ventvo_voice/models/vent.dart';
import '../../ventvo_voice/providers/vent_provider.dart';

class VentCard extends ConsumerStatefulWidget {
  final Vent vent;
  final int index;
  final bool showLifecycleActions;

  const VentCard({
    super.key,
    required this.vent,
    required this.index,
    this.showLifecycleActions = false,
  });

  @override
  ConsumerState<VentCard> createState() => _VentCardState();
}

class _VentCardState extends ConsumerState<VentCard> {
  bool pressed = false;

  Future<void> _toggleLifecycle() async {
    final service = ref.read(ventLifecycleServiceProvider);
    if (widget.vent.isActive) {
      await service.archive(widget.vent);
    } else {
      await service.restore(widget.vent);
    }
  }

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

  Widget _buildMoment(
    BuildContext context,
    Space? space,
  ) {
    final text = widget.vent.content.trim();

    final isFirst = widget.index == 0;
    final isShort = text.length < 90;
    final isLong = text.length > 180;

    return AnimatedScale(
      scale: pressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: space == null
            ? null
            : (_) {
                setState(() {
                  pressed = true;
                });
              },
        onTapCancel: space == null
            ? null
            : () {
                setState(() {
                  pressed = false;
                });
              },
        onTapUp: space == null
            ? null
            : (_) async {
                setState(() {
                  pressed = false;
                });

                await SpaceScreen.open(
                  context,
                  space,
                );
              },
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            8,
            isFirst ? 22 : 34,
            8,
            isShort
                ? 34
                : isLong
                    ? 48
                    : 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              SizedBox(height: isFirst ? 18 : 16),
              Hero(
                tag: 'moment-${widget.vent.id}',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    text,
                    maxLines: isShort ? 4 : 6,
                    overflow: TextOverflow.fade,
                    style: TextStyle(
                      color: VentvoColors.textPrimary,
                      fontSize: isFirst
                          ? 27
                          : isShort
                              ? 22
                              : 24,
                      height: 1.45,
                      fontWeight: isFirst
                          ? FontWeight.w500
                          : FontWeight.w400,
                      letterSpacing: -0.25,
                    ),
                  ),
                ),
              ),
              if (space != null) ...[
                const SizedBox(height: 20),
                _spaceHint(),
              ],
              const SizedBox(height: 28),
              if (!isFirst) _subtleDivider(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Text(
          widget.vent.voiceMark,
          style: const TextStyle(
            color: VentvoColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (!widget.vent.isActive) ...[
          const SizedBox(width: 8),
          const Text(
            'ARCHIVED',
            style: TextStyle(
              color: VentvoColors.textMuted,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ],
        const Spacer(),
        if (widget.showLifecycleActions)
          PopupMenuButton<String>(
            tooltip: 'Vent options',
            icon: const Icon(
              Icons.more_horiz_rounded,
              size: 18,
              color: VentvoColors.textMuted,
            ),
            onSelected: (value) async {
              if (value == 'toggle') await _toggleLifecycle();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'toggle',
                child: Text(
                  widget.vent.isActive ? 'Archive Vent' : 'Restore Vent',
                ),
              ),
            ],
          ),
        Text(
          _timeAgo(widget.vent.createdAt),
          style: const TextStyle(
            color: VentvoColors.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _spaceHint() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            color: VentvoColors.textMuted,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 9),
        const Text(
          'Space',
          style: TextStyle(
            color: VentvoColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _subtleDivider() {
    return Container(
      height: 1,
      width: double.infinity,
      color: VentvoColors.border.withValues(alpha: 0.32),
    );
  }

  String _timeAgo(DateTime time) {
    final difference = DateTime.now().difference(time);

    if (difference.isNegative || difference.inMinutes < 1) return 'now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}d';
    if (difference.inDays < 30) return '${difference.inDays ~/ 7}w';
    return '${difference.inDays ~/ 30}mo';
  }
}
