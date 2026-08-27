import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/feed_provider.dart';
import '../widgets/vent_card.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moments = ref.watch(feedProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        titleSpacing: 20,
        title: const Text(
          'Moments',
          style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w600),
        ),
      ),
      body: moments.isEmpty
          ? const Center(
              child: Text(
                'Nothing here yet.\nMoments will find their way here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 17, height: 1.5),
              ),
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
              itemCount: moments.length,
              itemBuilder: (context, index) => VentCard(vent: moments[index]),
            ),
    );
  }
}
