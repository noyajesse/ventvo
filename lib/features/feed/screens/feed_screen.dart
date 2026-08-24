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
        title: const Text(
          'Ventvo Feed',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ventsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => const Center(
          child: Text(
            'Unable to load your Vents right now.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 18,
            ),
          ),
        ),
        data: (vents) {
          if (vents.isEmpty) {
            return const Center(
              child: Text(
                'No Voices yet.\nBe the first to express.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 18,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: vents.length,
            itemBuilder: (context, index) {
              final vent = vents[index];
              return VentCard(vent: vent);
            },
          );
        },
      ),
    );
  }
}
