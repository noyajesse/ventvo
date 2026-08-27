import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ventvo_voice/providers/vent_provider.dart';
import '../widgets/vent_card.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ventsAsync = ref.watch(ventProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        titleSpacing: 20,
        title: const Text(
          'Moments',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(
          child: Text(
            'Unable to load your Moments right now.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ),
        data: (vents) {
          if (vents.isEmpty) {
            return const Center(
              child: Text(
                'Nothing here yet.\nBe the first to express.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 17, height: 1.5),
              ),
            );
          }

          final moments = [...vents]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
            itemCount: moments.length,
            itemBuilder: (context, index) => VentCard(vent: moments[index]),
          );
        },
      ),
    );
  }
}
