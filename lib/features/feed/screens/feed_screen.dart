import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../../../systems/resonance/services/resonance_demo_data_service.dart';
import '../../spaces/models/space.dart';
import '../../spaces/providers/space_provider.dart';
import '../../spaces/screens/space_screen.dart';
import '../../ventvo_voice/models/vent.dart';
import '../../ventvo_voice/screens/create_vent_screen.dart';
import '../../ventvo_voice/screens/voice_space_screen.dart';
import '../providers/feed_provider.dart';
import '../widgets/vent_card.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(feedProvider);
    final storedSpaces =
        ref.watch(spaceProvider).asData?.value ?? const <Space>[];
    final spaces = [...storedSpaces, ...ResonanceDemoDataService.spaces];

    return Scaffold(
      backgroundColor: VentvoColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateVentScreen()),
        ),
        backgroundColor: VentvoColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        icon: const Icon(Icons.edit_rounded, size: 17),
        label: const Text('Release'),
      ),
      body: SafeArea(
        child: feed.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => const Center(
            child: Text(
              'The moments could not be loaded yet.',
              style: TextStyle(color: VentvoColors.textMuted),
            ),
          ),
          data: (moments) => CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _header(context)),
              if (moments.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'Nothing has found its way here yet.',
                      style: TextStyle(
                        color: VentvoColors.textMuted,
                        fontSize: 15,
                      ),
                    ),
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                    child: _FeaturedMoment(
                      moment: moments.first,
                      spaces: spaces,
                    ),
                  ),
                ),
                if (moments.length > 1)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 4, 18, 110),
                    sliver: SliverList.builder(
                      itemCount: moments.length - 1,
                      itemBuilder: (context, index) {
                        final moment = moments[index + 1];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: VentCard(
                            key: ValueKey(moment.id),
                            vent: moment,
                            index: index + 1,
                          ),
                        );
                      },
                    ),
                  )
                else
                  const SliverPadding(
                    padding: EdgeInsets.only(bottom: 110),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 18, 0),
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
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const VoiceSpaceScreen(),
              ),
            ),
            icon: const Icon(
              Icons.person_outline_rounded,
              color: VentvoColors.textSecondary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedMoment extends StatelessWidget {
  const _FeaturedMoment({
    required this.moment,
    required this.spaces,
  });

  final Vent moment;
  final List<Space> spaces;

  @override
  Widget build(BuildContext context) {
    final space = _spaceForMoment();

    return Material(
      color: VentvoColors.surface,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: space == null
            ? null
            : () => SpaceScreen.open(context, space),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    moment.voiceMark,
                    style: const TextStyle(
                      color: VentvoColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'MOMENT',
                    style: TextStyle(
                      color: VentvoColors.textMuted,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Text(
                moment.content,
                maxLines: 8,
                overflow: TextOverflow.fade,
                style: const TextStyle(
                  color: VentvoColors.textPrimary,
                  fontSize: 25,
                  height: 1.42,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.35,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 1,
                    color: VentvoColors.border,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    space?.modeLabel ?? 'Space',
                    style: const TextStyle(
                      color: VentvoColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                  if (space != null) ...[
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: VentvoColors.textMuted,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Space? _spaceForMoment() {
    for (final space in spaces) {
      if (space.allVentIds.contains(moment.id)) return space;
    }
    return null;
  }
}