import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../spaces/models/space.dart';
import '../../spaces/providers/space_provider.dart';
import '../../spaces/screens/space_screen.dart';
import '../../ventvo_voice/models/vent.dart';

class VentCard extends ConsumerWidget {
  final Vent vent;

  const VentCard({
    super.key,
    required this.vent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacesAsync = ref.watch(spaceProvider);
    final voiceName = vent.voiceName?.trim();
    final identity = voiceName == null || voiceName.isEmpty ? 'Voice' : voiceName;

    return spacesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => _buildCard(context, null, identity),
      data: (spaces) {
        final space = spaces.where((item) => item.id == vent.spaceId).firstOrNull;
        return _buildCard(context, space, identity);
      },
    );
  }

  Widget _buildCard(BuildContext context, Space? space, String identity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(vent.voiceMark, style: const TextStyle(color: Colors.white70, fontSize: 22)),
              const SizedBox(width: 10),
              Text(identity, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 18),
          Text(vent.content, style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.4)),
          const SizedBox(height: 20),
          if (space != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(20)),
              child: Text(
                space.isJustListen ? '🌊 Just Listen Space' : '💬 Open Discussion Space',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          const SizedBox(height: 22),
          const Divider(color: Colors.white12),
          const SizedBox(height: 14),
          Text(
            space?.isJustListen == true
                ? 'A moment asking for presence.'
                : 'A moment open to perspectives.',
            style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: space == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SpaceScreen(space: space)),
                      );
                    },
              child: const Text('Enter Space'),
            ),
          ),
        ],
      ),
    );
  }
}
