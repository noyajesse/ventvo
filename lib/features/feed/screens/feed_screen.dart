import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../providers/feed_provider.dart';
import '../widgets/vent_card.dart';
import '../../ventvo_voice/screens/create_vent_screen.dart';
import '../../ventvo_voice/screens/voice_space_screen.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(feedProvider);

    return Scaffold(
      backgroundColor: VentvoColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateVentScreen())),
        backgroundColor: VentvoColors.surface,
        foregroundColor: VentvoColors.textPrimary,
        elevation: 0,
        icon: const Icon(Icons.edit_rounded, size: 17),
        label: const Text('Release'),
      ),
      body: SafeArea(
        child: feed.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'The moments could not be loaded yet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: VentvoColors.textMuted,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ),
          ),
          data: (moments) => CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 18, 8),
                  child: Row(
                    children: [
                      const Text(
                        'ventvo',
                        style: TextStyle(
                          color: VentvoColors.textPrimary,
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Your Voice',
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VoiceSpaceScreen())),
                        icon: const Icon(Icons.person_outline_rounded, color: VentvoColors.textSecondary, size: 22),
                      ),
                    ],
                  ),
                ),
              ),
              if (moments.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Nothing has found its way here yet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: VentvoColors.textMuted,
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                  sliver: SliverList.builder(
                    itemCount: moments.length,
                    itemBuilder: (context, index) {
                      return VentCard(
                        key: ValueKey(moments[index].id),
                        vent: moments[index],
                        index: index,
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
