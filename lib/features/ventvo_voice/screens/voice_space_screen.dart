
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../providers/voice_provider.dart';
import '../providers/vent_provider.dart';
import '../../feed/screens/feed_screen.dart';
import '../../feed/widgets/vent_card.dart';
import '../../crash_out/screens/crash_out_screen.dart';
import '../../crash_out/screens/private_crash_outs_screen.dart';
import '../../crash_out/models/crash_out.dart';
import '../../crash_out/providers/crash_out_provider.dart';
import 'create_vent_screen.dart';

class VoiceSpaceScreen extends ConsumerWidget {
  const VoiceSpaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voice = ref.watch(ventvoVoiceProvider).asData?.value;
    final vents = ref.watch(ventProvider).asData?.value ?? const [];
    final crashOuts = ref.watch(crashOutProvider);

    final privateCrashOuts = crashOuts
        .where(
          (crashOut) => crashOut.status == CrashOutStatus.keptPrivate,
        )
        .toList();

    return Scaffold(
      backgroundColor: VentvoColors.background,
      appBar: AppBar(
        backgroundColor: VentvoColors.background,
        elevation: 0,
        titleSpacing: 22,
        title: const Text(
          'Your Voice',
          style: TextStyle(
            color: VentvoColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_horiz_rounded,
              color: VentvoColors.textMuted,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _VoiceIdentity(
                mark: voice?.mark ?? '◇',
                name: voice?.name ?? 'Unnamed Voice',
                expression:
                    voice?.expression ?? 'Your Voice is waiting.',
              ),

              const SizedBox(height: 34),

              const _SectionLabel(
                title: 'Your expression',
                subtitle: 'Things you chose to let exist outside of you.',
              ),

              const SizedBox(height: 16),

              _StatsRow(
                vents: vents.length,
                moments: 0,
                arcs: 0,
              ),

              const SizedBox(height: 30),

              if (vents.isNotEmpty) ...[
                ...vents.asMap().entries.map(
                  (entry) => VentCard(
                    vent: entry.value,
                    index: entry.key,
                  ),
                ),
              ] else
                const _EmptyVentsCard(),

              if (privateCrashOuts.isNotEmpty) ...[
                const SizedBox(height: 30),

                const _SectionLabel(
                  title: 'Kept close',
                  subtitle: 'Things you chose not to release.',
                ),

                const SizedBox(height: 16),

                _PrivateCrashOutCard(
                  count: privateCrashOuts.length,
                ),
              ],

              const SizedBox(height: 34),

              const _SectionLabel(
                title: 'Express',
                subtitle: 'You decide what needs to happen next.',
              ),

              const SizedBox(height: 16),

              _PrimaryAction(
                icon: Icons.edit_rounded,
                label: 'Create a Vent',
                subtitle: 'Say what is on your mind.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateVentScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              _SecondaryAction(
                icon: Icons.waves_rounded,
                label: 'Crash Out',
                subtitle: 'Let it out without deciding what it means.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CrashOutScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              _SecondaryAction(
                icon: Icons.explore_outlined,
                label: 'Explore',
                subtitle: 'Find thoughts waiting to be understood.',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FeedScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoiceIdentity extends StatelessWidget {
  const _VoiceIdentity({
    required this.mark,
    required this.name,
    required this.expression,
  });

  final String mark;
  final String name;
  final String expression;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: BoxDecoration(
        color: VentvoColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: VentvoColors.border.withValues(alpha: .55),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: VentvoColors.border,
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              mark,
              style: const TextStyle(
                color: VentvoColors.textPrimary,
                fontSize: 38,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: VentvoColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w600,
              letterSpacing: -.4,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            expression,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: VentvoColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.vents,
    required this.moments,
    required this.arcs,
  });

  final int vents;
  final int moments;
  final int arcs;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Stat(
            value: '$vents',
            label: 'Vents',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Stat(
            value: '$moments',
            label: 'Moments',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Stat(
            value: '$arcs',
            label: 'Arcs',
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: VentvoColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: VentvoColors.border.withValues(alpha: .4),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: VentvoColors.textPrimary,
              fontSize: 21,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: VentvoColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: VentvoColors.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.w600,
            letterSpacing: -.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: VentvoColors.textMuted,
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _EmptyVentsCard extends StatelessWidget {
  const _EmptyVentsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: VentvoColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: VentvoColors.border.withValues(alpha: .4),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nothing released yet.',
            style: TextStyle(
              color: VentvoColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Your first Vent will find its place here.',
            style: TextStyle(
              color: VentvoColors.textMuted,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivateCrashOutCard extends StatelessWidget {
  const _PrivateCrashOutCard({
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PrivateCrashOutsScreen(),
            ),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 20, 18, 20),
          decoration: BoxDecoration(
            color: VentvoColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: VentvoColors.border.withValues(alpha: .4),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: VentvoColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: VentvoColors.textSecondary,
                  size: 19,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Private Crash Outs',
                      style: TextStyle(
                        color: VentvoColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count ${count == 1 ? 'thing' : 'things'} kept close.',
                      style: const TextStyle(
                        color: VentvoColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: VentvoColors.textMuted,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: VentvoColors.primary,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: VentvoColors.background,
                size: 20,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: VentvoColors.background,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: VentvoColors.background.withValues(alpha: .65),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: VentvoColors.background.withValues(alpha: .7),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  const _SecondaryAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: VentvoColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 15, 16, 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: VentvoColors.border.withValues(alpha: .4),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: VentvoColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: VentvoColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: VentvoColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: VentvoColors.textMuted,
                size: 17,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

