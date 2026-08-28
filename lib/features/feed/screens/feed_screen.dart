import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../providers/feed_provider.dart';
import '../widgets/vent_card.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moments = ref.watch(feedProvider);

    return Scaffold(
      backgroundColor: VentvoColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 10),
                child: Row(
                  children: [
                    const Text(
                      'moments',
                      style: TextStyle(
                        color: VentvoColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: VentvoColors.textMuted,
                        shape: BoxShape.circle,
                      ),
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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
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
    );
  }
}