import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final voice = ref.watch(ventvoVoiceProvider);
    final vents = ref.watch(ventProvider);
    final crashOuts = ref.watch(crashOutProvider);

    final privateCrashOuts = crashOuts
        .where((crashOut) => crashOut.status == CrashOutStatus.keptPrivate)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Your Voice',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _VoiceIdentity(
                mark: voice.mark ?? '◇',
                name: voice.name ?? 'Unnamed Voice',
                expression: voice.expression ?? 'Your Voice is waiting.',
              ),
              const SizedBox(height: 28),
              _SectionLabel(
                title: 'Your space',
                subtitle: 'A place for what you choose to express.',
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      value: '${vents.length}',
                      label: 'Vents',
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: _StatCard(
                      value: '0',
                      label: 'Moments',
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: _StatCard(
                      value: '0',
                      label: 'Arcs',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              if (vents.isNotEmpty) ...[
                _SectionLabel(
                  title: 'Your Vents',
                  subtitle: 'Expressions you have chosen to release.',
                ),
                const SizedBox(height: 14),
                ...vents.map((vent) => VentCard(vent: vent)),
                const SizedBox(height: 14),
              ] else
                _EmptyVentsCard(),
              if (privateCrashOuts.isNotEmpty) ...[
                const SizedBox(height: 12),
                _SectionLabel(
                  title: 'Private',
                  subtitle: 'Things you chose to keep for yourself.',
                ),
                const SizedBox(height: 14),
                _PrivateCrashOutCard(count: privateCrashOuts.length),
              ],
              const SizedBox(height: 30),
              const _SectionLabel(
                title: 'Express',
                subtitle: 'Choose what you need right now.',
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateVentScreen(),
                      ),
                    );
                  },
                  child: const Text('Create a Vent'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CrashOutScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text('Crash Out'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FeedScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text('Explore Feed'),
                ),
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
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              mark,
              style: const TextStyle(color: Colors.white, fontSize: 48),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            expression,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.45,
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
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyVentsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nothing here yet.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Your first Vent will live here.',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivateCrashOutCard extends StatelessWidget {
  const _PrivateCrashOutCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lock_outline, color: Colors.white70, size: 20),
              SizedBox(width: 10),
              Text(
                'Private Crash Outs',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            '$count ${count == 1 ? 'Crash Out' : 'Crash Outs'} kept for you.',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrivateCrashOutsScreen(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('View Private Crash Outs'),
            ),
          ),
        ],
      ),
    );
  }
}
