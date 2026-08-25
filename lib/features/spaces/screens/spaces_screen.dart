import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/space_provider.dart';
import '../widgets/space_card.dart';
import 'space_screen.dart';

class SpacesScreen extends ConsumerWidget {
  const SpacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spaces = ref.watch(spaceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        title: const Text(
          'Spaces',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: spaces.isEmpty
          ? const Center(
              child: Text(
                'No Spaces yet.',
                style: TextStyle(color: Colors.white54, fontSize: 17),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: spaces.length,
              itemBuilder: (context, index) {
                final space = spaces[index];
                return SpaceCard(
                  space: space,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SpaceScreen(space: space),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
