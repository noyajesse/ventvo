import 'package:flutter/material.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../../../systems/resonance/models/resonance_gathering_candidate.dart';
import '../models/resonance_map_experience.dart';
import 'resonance_gathering_screen.dart';

/// Presentation layer for the moment a connected cluster becomes an
/// invitation to meet. It does not auto-enroll anyone in a Gathering.
class ResonanceGatheringEntryScreen extends StatelessWidget {
  final ResonanceGatheringCandidate candidate;
  final List<ResonanceMapExperience> experiences;

  const ResonanceGatheringEntryScreen({
    super.key,
    required this.candidate,
    required this.experiences,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VentvoColors.background,
      appBar: AppBar(title: const Text('Meet'), centerTitle: true),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
        children: [
          const Text(
            'A GATHERING IS POSSIBLE',
            style: TextStyle(
              color: VentvoColors.textMuted,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 11),
          const Text(
            'These experiences found each other.',
            style: TextStyle(
              color: VentvoColors.textPrimary,
              fontSize: 23,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            '${experiences.length} connected experiences form this small landscape. The Voices can choose whether to meet here.',
            style: const TextStyle(
              color: VentvoColors.textMuted,
              fontSize: 12,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 24),
          ...experiences.map(
            (experience) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ExperiencePreview(experience: experience),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'This is not a permanent group. Enter only if you want to meet the Voices connected through this experience.',
            style: TextStyle(
              color: VentvoColors.textMuted,
              fontSize: 11,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ResonanceGatheringScreen(
                    candidate: candidate,
                    experiences: experiences,
                  ),
                ),
              ),
              child: const Text('Enter Gathering'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExperiencePreview extends StatelessWidget {
  final ResonanceMapExperience experience;

  const _ExperiencePreview({required this.experience});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
      decoration: BoxDecoration(
        color: VentvoColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: VentvoColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            experience.voiceMark,
            style: const TextStyle(
              color: VentvoColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            experience.content,
            style: const TextStyle(
              color: VentvoColors.textPrimary,
              fontSize: 14,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
