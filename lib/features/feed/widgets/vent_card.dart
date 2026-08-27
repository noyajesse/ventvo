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
      loading: () => _buildCard(context, null),
      error: (_, _) => _buildCard(context, null),
      data: (spaces) {
        final space = spaces.where((item) => item.id == vent.spaceId).firstOrNull;
        return _buildCard(context, space);
      },
    );
  }

  Widget _buildCard(BuildContext context, Space? space) {
    final canEnterSpace = space != null;
    final momentLabel = space == null
        ? null
        : space.allVentIds.length == 1
            ? 'Continue this moment'
            : 'Continue this moment · ${space.allVentIds.length} moments';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                vent.voiceMark,
                style: const TextStyle(color: Colors.white70, fontSize: 22),
              ),
              const SizedBox(width: 10),
              if (vent.voiceName != null && vent.voiceName!.trim().isNotEmpty)
                Text(
                  vent.voiceName!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            vent.content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.4,
            ),
          ),
          if (canEnterSpace) ...[
            const SizedBox(height: 18),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => SpaceScreen.open(context, space),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: space.isJustListen ? Colors.white38 : Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          momentLabel!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white54,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
