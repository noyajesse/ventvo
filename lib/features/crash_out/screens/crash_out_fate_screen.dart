import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ventvo_voice/models/vent.dart';
import '../models/crash_out.dart';
import '../services/crash_out_opposite_experience_service.dart';

class CrashOutFateScreen extends ConsumerWidget {
  final CrashOut crashOut;
  final CrashOutOppositeMatch? match;

  const CrashOutFateScreen({
    super.key,
    required this.crashOut,
    required this.match,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        title: const Text(
          'The Other Side',
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
                  experience: match!.experience,
                  tension: match!.sourceAtom.tension.label,
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
    required this.tension,
  });

  final CrashOut crashOut;
  final Vent experience;
  final String tension;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        const Icon(
          Icons.compare_arrows_rounded,
          color: Colors.white70,
          size: 54,
        ),
        const SizedBox(height: 28),
        const Text(
          'Something on the other side surfaced.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Two sides of $tension.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Not a match. Not a conversation. Just another human experience moving in a different direction.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 30),
        _ExperienceCard(
          label: 'WHAT YOU LET OUT',
          text: crashOut.textContent ?? '',
        ),
        const SizedBox(height: 12),
        const Icon(
          Icons.compare_arrows_rounded,
          color: Colors.white30,
          size: 22,
        ),
        const SizedBox(height: 12),
        _ExperienceCard(
          label: 'ANOTHER SIDE',
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
          'Nothing meaningful on the other side surfaced yet.',
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
