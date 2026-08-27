import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../spaces/models/space.dart';
import '../../spaces/providers/space_provider.dart';
import '../../spaces/screens/space_screen.dart';
import '../../ventvo_voice/models/vent.dart';

class VentCard extends ConsumerWidget {
  final Vent vent;

  const VentCard({super.key, required this.vent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacesAsync = ref.watch(spaceProvider);

    return spacesAsync.when(
      loading: () => _moment(context, null),
      error: (_, _) => _moment(context, null),
      data: (spaces) {
        final space = spaces.where((item) => item.id == vent.spaceId).firstOrNull;
        return _moment(context, space);
      },
    );
  }

  Widget _moment(BuildContext context, Space? space) {
    final compact = vent.content.trim().length < 90;
    final hasDepth = vent.content.trim().length > 130 && space != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: space == null ? null : () => SpaceScreen.open(context, space),
        child: Padding(
          padding: EdgeInsets.fromLTRB(6, compact ? 22 : 28, 6, compact ? 30 : 38),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    vent.voiceMark,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _timeAgo(vent.createdAt),
                    style: const TextStyle(color: Colors.white30, fontSize: 10),
                  ),
                ],
              ),
              SizedBox(height: compact ? 13 : 18),
              Hero(
                tag: 'moment-${vent.id}',
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    vent.content,
                    maxLines: hasDepth ? 3 : null,
                    overflow: hasDepth ? TextOverflow.fade : TextOverflow.clip,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: compact ? 21 : 25,
                      height: 1.42,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -.15,
                    ),
                  ),
                ),
              ),
              if (hasDepth) ...[
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white12, height: 1)),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_downward_rounded, size: 13, color: Colors.white30),
                  ],
                ),
              ],
              const SizedBox(height: 23),
              Container(height: 1, color: Colors.white10),
            ],
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inMinutes < 1) return 'now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    return '${difference.inDays}d';
  }
}
