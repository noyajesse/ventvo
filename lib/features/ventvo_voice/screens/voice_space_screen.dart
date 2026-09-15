import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../models/voice_seed.dart';
import '../providers/voice_provider.dart';
import '../providers/vent_provider.dart';
import '../providers/voice_space_provider.dart';
import '../services/voice_identity_catalog.dart';
import '../../feed/screens/feed_screen.dart';
import '../../feed/widgets/vent_card.dart';
import '../../crash_out/screens/crash_out_screen.dart';
import '../../crash_out/screens/private_crash_outs_screen.dart';
import '../../crash_out/models/crash_out.dart';
import '../../crash_out/providers/crash_out_provider.dart';
import 'create_vent_screen.dart';
import 'voice_evolution_screen.dart';

class VoiceSpaceScreen extends ConsumerWidget {
  const VoiceSpaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voice = ref.watch(ventvoVoiceProvider).asData?.value;
    final vents = ref.watch(ventProvider).asData?.value ?? const [];
    final resonanceStats = ref.watch(voiceSpaceResonanceStatsProvider);
    final crashOutState = ref.watch(crashOutProvider);
    final privateCrashOuts = crashOutState.asData?.value
            .where((crashOut) => crashOut.status == CrashOutStatus.keptPrivate)
            .toList() ??
        const <CrashOut>[];
    final seed = _seedForVoice(voice);

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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VoiceEvolutionScreen(),
                ),
              );
            },
            tooltip: 'Let your Voice evolve',
            icon: const Icon(
              Icons.auto_awesome_outlined,
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
              _VoiceIdentity(seed: seed, voice: voice),
              const SizedBox(height: 36),
              const _SectionLabel(
                title: 'Your journey',
                subtitle: 'Your Voice is shaped by what you live, release, and recognize.',
              ),
              const SizedBox(height: 16),
              _StatsRow(
                vents: vents.length,
                resonance: resonanceStats.asData?.value.threads ?? 0,
                arcs: resonanceStats.asData?.value.maps ?? 0,
              ),
              const SizedBox(height: 30),
              if (vents.isNotEmpty) ...[
                const Text(
                  'What you have expressed',
                  style: TextStyle(
                    color: VentvoColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                ...vents.asMap().entries.map(
                  (entry) => VentCard(
                    vent: entry.value,
                    index: entry.key,
                    showLifecycleActions: true,
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
                _PrivateCrashOutCard(count: privateCrashOuts.length),
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
                subtitle: 'Give what you are carrying somewhere to exist.',
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

  static VoiceSeed _seedForVoice(dynamic voice) {
    final name = voice?.name;
    if (name is String && name.trim().isNotEmpty) {
      return VoiceIdentityCatalog.seedByWord(name.trim());
    }
    return VoiceIdentityCatalog.seeds.first;
  }
}

class _VoiceIdentity extends StatelessWidget {
  const _VoiceIdentity({required this.seed, required this.voice});

  final VoiceSeed seed;
  final dynamic voice;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 26),
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
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: VentvoColors.border,
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              seed.mark.symbol,
              style: const TextStyle(
                color: VentvoColors.textPrimary,
                fontSize: 40,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            seed.word,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: VentvoColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            seed.essence,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: VentvoColors.textMuted,
              fontSize: 12,
              letterSpacing: .5,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            seed.meaning,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: VentvoColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          if (voice?.expression != null &&
              (voice.expression as String).trim().isNotEmpty) ...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: VentvoColors.background,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                voice.expression as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: VentvoColors.textPrimary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          Text(
            '“${seed.feeling}”',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: VentvoColors.textMuted,
              fontSize: 12,
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.subtitle});

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
            fontSize: 18,
            fontWeight: FontWeight.w600,
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

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.vents,
    required this.resonance,
    required this.arcs,
  });

  final int vents;
  final int resonance;
  final int arcs;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Stat(label: 'Vents', value: vents),
        const SizedBox(width: 12),
        _Stat(label: 'Resonance', value: resonance),
        const SizedBox(width: 12),
        _Stat(label: 'Arcs', value: arcs),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: VentvoColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: const TextStyle(
                color: VentvoColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: VentvoColors.textMuted,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyVentsCard extends StatelessWidget {
  const _EmptyVentsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: VentvoColors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Text(
        'Nothing has been released yet.\nYour Voice is still becoming.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: VentvoColors.textSecondary,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }
}

class _PrivateCrashOutCard extends StatelessWidget {
  const _PrivateCrashOutCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: VentvoColors.surface,
      borderRadius: BorderRadius.circular(22),
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Icon(Icons.lock_outline_rounded, color: VentvoColors.textMuted),
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
                      '$count kept close',
                      style: const TextStyle(
                        color: VentvoColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: VentvoColors.textMuted),
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
    return _ActionCard(
      icon: icon,
      label: label,
      subtitle: subtitle,
      onTap: onTap,
      prominent: true,
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
    return _ActionCard(
      icon: icon,
      label: label,
      subtitle: subtitle,
      onTap: onTap,
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.prominent = false,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: VentvoColors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                icon,
                color: prominent
                    ? VentvoColors.textPrimary
                    : VentvoColors.textSecondary,
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
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
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
                size: 13,
                color: VentvoColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
