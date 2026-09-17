import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../../feed/screens/feed_screen.dart';
import '../../crash_out/models/crash_out.dart';
import '../../crash_out/providers/crash_out_provider.dart';
import '../../crash_out/screens/crash_out_screen.dart';
import '../../crash_out/screens/private_crash_outs_screen.dart';
import '../../resonance/screens/voice_resonance_screen.dart';
import '../models/voice_seed.dart';
import '../providers/vent_provider.dart';
import '../providers/voice_provider.dart';
import '../providers/voice_space_provider.dart';
import '../services/voice_identity_catalog.dart';
import 'create_vent_screen.dart';
import 'voice_evolution_screen.dart';
import 'voice_moments_screen.dart';

class VoiceSpaceScreen extends ConsumerWidget {
  const VoiceSpaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voice = ref.watch(ventvoVoiceProvider).asData?.value;
    final vents = ref.watch(ventProvider).asData?.value ?? const [];
    final resonanceStats = ref.watch(voiceSpaceResonanceStatsProvider);
    final crashOuts = ref.watch(crashOutProvider).asData?.value
            .where((item) => item.status == CrashOutStatus.keptPrivate)
            .toList() ??
        const <CrashOut>[];
    final seed = _seedForVoice(voice);
    final threadCount = resonanceStats.asData?.value.threads ?? 0;
    final mapCount = resonanceStats.asData?.value.maps ?? 0;

    void open(Widget page) => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );

    return Scaffold(
      backgroundColor: VentvoColors.background,
      appBar: AppBar(
        backgroundColor: VentvoColors.background,
        elevation: 0,
        titleSpacing: 22,
        title: const Text('Your Voice', style: TextStyle(color: VentvoColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            onPressed: () => open(const VoiceEvolutionScreen()),
            tooltip: 'Let your Voice evolve',
            icon: const Icon(Icons.auto_awesome_outlined, color: VentvoColors.textMuted),
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
              const SizedBox(height: 30),
              if (vents.isEmpty) ...[
                _FirstMomentCard(onCreateVent: () => open(const CreateVentScreen())),
                const SizedBox(height: 34),
              ],
              const _SectionLabel(title: 'Your journey', subtitle: 'Your Voice is shaped by what you live, release, and recognize.'),
              const SizedBox(height: 16),
              _StatsRow(vents: vents.length, resonance: threadCount, arcs: mapCount),
              const SizedBox(height: 30),
              _VoiceEntry(
                icon: Icons.auto_stories_outlined,
                title: 'Your Moments',
                subtitle: '${vents.length} expressed ${vents.length == 1 ? 'moment' : 'moments'}',
                onTap: () => open(const VoiceMomentsScreen()),
              ),
              const SizedBox(height: 10),
              _VoiceEntry(
                icon: Icons.blur_on_rounded,
                title: 'Resonance',
                subtitle: '$threadCount Threads · $mapCount Maps',
                onTap: () => open(const VoiceResonanceScreen()),
              ),
              if (crashOuts.isNotEmpty) ...[
                const SizedBox(height: 30),
                const _SectionLabel(title: 'Kept close', subtitle: 'Things you chose not to release.'),
                const SizedBox(height: 16),
                _PrivateCrashOutCard(count: crashOuts.length),
              ],
              const SizedBox(height: 34),
              const _SectionLabel(title: 'Express', subtitle: 'You decide what needs to happen next.'),
              const SizedBox(height: 16),
              _PrimaryAction(icon: Icons.edit_rounded, label: 'Create a Vent', subtitle: 'Give what you are carrying somewhere to exist.', onTap: () => open(const CreateVentScreen())),
              const SizedBox(height: 10),
              _SecondaryAction(icon: Icons.waves_rounded, label: 'Crash Out', subtitle: 'Let it out without deciding what it means.', onTap: () => open(const CrashOutScreen())),
              const SizedBox(height: 10),
              _SecondaryAction(icon: Icons.explore_outlined, label: 'Explore', subtitle: 'Find thoughts waiting to be understood.', onTap: () => open(const FeedScreen())),
            ],
          ),
        ),
      ),
    );
  }

  static VoiceSeed _seedForVoice(dynamic voice) {
    final name = voice?.name;
    return name is String && name.trim().isNotEmpty
        ? VoiceIdentityCatalog.seedByWord(name.trim())
        : VoiceIdentityCatalog.seeds.first;
  }
}

class _VoiceIdentity extends StatelessWidget {
  const _VoiceIdentity({required this.seed, required this.voice});
  final VoiceSeed seed;
  final dynamic voice;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 30, 24, 26),
        decoration: BoxDecoration(color: VentvoColors.surface, borderRadius: BorderRadius.circular(30), border: Border.all(color: VentvoColors.border.withValues(alpha: .55))),
        child: Column(children: [
          Container(width: 92, height: 92, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: VentvoColors.border)), child: Text(seed.mark.symbol, style: const TextStyle(color: VentvoColors.textPrimary, fontSize: 40, fontWeight: FontWeight.w300))),
          const SizedBox(height: 18),
          Text(seed.word, textAlign: TextAlign.center, style: const TextStyle(color: VentvoColors.textPrimary, fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
          const SizedBox(height: 7),
          Text(seed.essence, textAlign: TextAlign.center, style: const TextStyle(color: VentvoColors.textMuted, fontSize: 12, letterSpacing: .5)),
          const SizedBox(height: 18),
          Text(seed.meaning, textAlign: TextAlign.center, style: const TextStyle(color: VentvoColors.textSecondary, fontSize: 14, height: 1.5)),
          if (voice?.expression != null && (voice.expression as String).trim().isNotEmpty) ...[
            const SizedBox(height: 18),
            Container(width: double.infinity, padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: VentvoColors.background, borderRadius: BorderRadius.circular(18)), child: Text(voice.expression as String, textAlign: TextAlign.center, style: const TextStyle(color: VentvoColors.textPrimary, fontSize: 13, height: 1.5))),
          ],
          const SizedBox(height: 18),
          Text('“${seed.feeling}”', textAlign: TextAlign.center, style: const TextStyle(color: VentvoColors.textMuted, fontSize: 12, fontStyle: FontStyle.italic)),
        ]),
      );
}

class _FirstMomentCard extends StatelessWidget {
  const _FirstMomentCard({required this.onCreateVent});
  final VoidCallback onCreateVent;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
        decoration: BoxDecoration(color: VentvoColors.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: VentvoColors.primary.withValues(alpha: .18))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Your Voice is here.', style: TextStyle(color: VentvoColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 7),
          const Text('Now give it a moment. What you release can become a Space, meet another Voice, and grow into Resonance.', style: TextStyle(color: VentvoColors.textSecondary, fontSize: 13, height: 1.5)),
          const SizedBox(height: 18),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: onCreateVent, child: const Text('Release your first moment'))),
        ]),
      );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.subtitle});
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: VentvoColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: VentvoColors.textMuted, fontSize: 12, height: 1.4))]);
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.vents, required this.resonance, required this.arcs});
  final int vents, resonance, arcs;
  @override
  Widget build(BuildContext context) => Row(children: [_Stat(label: 'Vents', value: vents), const SizedBox(width: 12), _Stat(label: 'Resonance', value: resonance), const SizedBox(width: 12), _Stat(label: 'Arcs', value: arcs)]);
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label; final int value;
  @override
  Widget build(BuildContext context) => Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: VentvoColors.surface, borderRadius: BorderRadius.circular(18)), child: Column(children: [Text('$value', style: const TextStyle(color: VentvoColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text(label, style: const TextStyle(color: VentvoColors.textMuted, fontSize: 10))])));
}

class _VoiceEntry extends StatelessWidget {
  const _VoiceEntry({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon; final String title, subtitle; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => _ActionCard(icon: icon, label: title, subtitle: subtitle, onTap: onTap);
}

class _PrivateCrashOutCard extends StatelessWidget {
  const _PrivateCrashOutCard({required this.count});
  final int count;
  @override
  Widget build(BuildContext context) => _ActionCard(icon: Icons.lock_outline_rounded, label: 'Private Crash Outs', subtitle: '$count kept close', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivateCrashOutsScreen())));
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.icon, required this.label, required this.subtitle, required this.onTap});
  final IconData icon; final String label, subtitle; final VoidCallback onTap;
  @override Widget build(BuildContext context) => _ActionCard(icon: icon, label: label, subtitle: subtitle, onTap: onTap, prominent: true);
}

class _SecondaryAction extends StatelessWidget {
  const _SecondaryAction({required this.icon, required this.label, required this.subtitle, required this.onTap});
  final IconData icon; final String label, subtitle; final VoidCallback onTap;
  @override Widget build(BuildContext context) => _ActionCard(icon: icon, label: label, subtitle: subtitle, onTap: onTap);
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.icon, required this.label, required this.subtitle, required this.onTap, this.prominent = false});
  final IconData icon; final String label, subtitle; final VoidCallback onTap; final bool prominent;
  @override
  Widget build(BuildContext context) => Material(color: VentvoColors.surface, borderRadius: BorderRadius.circular(22), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(22), child: Padding(padding: const EdgeInsets.all(20), child: Row(children: [Icon(icon, color: prominent ? VentvoColors.textPrimary : VentvoColors.textSecondary), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: VentvoColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: VentvoColors.textMuted, fontSize: 12, height: 1.4))])), const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: VentvoColors.textMuted)])));
}
