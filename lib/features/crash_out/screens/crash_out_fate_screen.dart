import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ventvo_voice/models/vent.dart';
import '../../ventvo_voice/providers/vent_provider.dart';
import '../models/crash_out.dart';
import '../providers/crash_out_provider.dart';

class CrashOutFateScreen extends ConsumerWidget {
  final CrashOut crashOut;

  const CrashOutFateScreen({
    super.key,
    required this.crashOut,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vents = ref.watch(ventProvider).asData?.value ?? const <Vent>[];
    final match = ref
        .read(crashOutOppositeExperienceServiceProvider)
        .find(
          crashOut: crashOut,
          experiences: vents,
        );

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        title: const Text(
          'Crash Out',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: match == null
              ? const _NoOppositeExperience()
              : _OppositeExperienceView(
                  crashOut: crashOut,
                  experience: match.experience,
                ),
        ),
      ),
    );
  }
}

class _OppositeExperienceView extends StatelessWidget {
  const _OppositeExperienceView({
    required this.crashOut,
    required this.experience,
  });

  final CrashOut crashOut;
  final Vent experience;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        const Icon(
          Icons.swap_vertical_circle_outlined,
          color: Colors.white70,
          size: 54,
        ),
        const SizedBox(height: 28),
        const Text(
          'Your Crash Out met an opposite experience.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'Not the same story. Not the same feeling. Just another side of something human.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 16,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 30),
        _ExperienceCard(
          label: 'YOUR EXPERIENCE',
          text: crashOut.textContent ?? '',
        ),
        const SizedBox(height: 12),
        const Icon(
          Icons.swap_vert_rounded,
          color: Colors.white30,
          size: 22,
        ),
        const SizedBox(height: 12),
        _ExperienceCard(
          label: 'ANOTHER EXPERIENCE',
          text: experience.content,
        ),
        const Spacer(),
      ],
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  const _ExperienceCard({
    required this.label,
    required this.text,
  });

  final String label;
  final String text;

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
          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoOppositeExperience extends StatelessWidget {
  const _NoOppositeExperience();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Spacer(),
        Icon(
          Icons.cloud_done_outlined,
          color: Colors.white70,
          size: 54,
        ),
        SizedBox(height: 30),
        Text(
          'You let it out.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Nothing on the other side surfaced yet.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 17,
            height: 1.5,
          ),
        ),
        Spacer(),
      ],
    );
  }
}
