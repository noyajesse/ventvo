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
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: space == null ? null : () => SpaceScreen.open(context, space),
          child: Ink(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      vent.voiceMark,
                      style: const TextStyle(color: Colors.white70, fontSize: 21),
                    ),
                    const SizedBox(width: 10),
                    if (vent.voiceName != null && vent.voiceName!.trim().isNotEmpty)
                      Text(
                        vent.voiceName!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  vent.content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (space != null) ...[
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white54,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 9),
                      const Text(
                        'Enter',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white38,
                        size: 17,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
