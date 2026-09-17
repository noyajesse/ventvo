import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../../feed/widgets/vent_card.dart';
import '../providers/vent_provider.dart';

class VoiceMomentsScreen extends ConsumerWidget {
  const VoiceMomentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vents = ref.watch(ventProvider).asData?.value ?? const [];
    final moments = [...vents]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      backgroundColor: VentvoColors.background,
      appBar: AppBar(
        title: const Text('Your Moments'),
        centerTitle: true,
      ),
      body: moments.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 36),
                child: Text(
                  'You have not released a Moment yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: VentvoColors.textMuted,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 32),
              itemCount: moments.length,
              itemBuilder: (context, index) => VentCard(
                vent: moments[index],
                index: index,
              ),
            ),
    );
  }
}
