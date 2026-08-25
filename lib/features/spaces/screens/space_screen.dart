import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../discussion/screen/discussion_screen.dart';
import '../../ventvo_voice/providers/vent_provider.dart';
import '../models/space.dart';

class SpaceScreen extends ConsumerWidget {
  final Space space;

  const SpaceScreen({
    super.key,
    required this.space,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ventsAsync = ref.watch(ventProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        title: Text(
          space.modeLabel,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text('Unable to load this Space.', style: TextStyle(color: Colors.white70)),
        ),
        data: (vents) {
          final vent = vents.where((item) => item.id == space.originatingVentId).firstOrNull;

          if (vent == null) {
            return const Center(
              child: Text('This Space is empty.', style: TextStyle(color: Colors.white54)),
            );
          }

          if (space.isOpenDiscussion) {
            return DiscussionScreen(vent: vent);
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                '◇ ${vent.voiceMark}',
                style: const TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              Text(
                vent.content,
                style: const TextStyle(color: Colors.white, fontSize: 20, height: 1.5),
              ),
              const SizedBox(height: 28),
              const Text(
                'Just Listen',
                style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'No advice. No fixing. Just presence.',
                style: TextStyle(color: Colors.white54, fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 22),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.headphones_outlined),
                label: const Text('I’m listening'),
              ),
            ],
          );
        },
      ),
    );
  }
}
