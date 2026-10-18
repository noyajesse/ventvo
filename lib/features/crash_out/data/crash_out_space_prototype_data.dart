import '../models/crash_out_space_experience.dart';
import '../models/experience_representation.dart';

/// Clearly-labelled local examples used to preview a populated Crash Out Space.
///
/// These are fictional prototype fixtures, not posts from real Ventvo users.
/// They must be replaced by eligible shared experiences when a secured backend
/// and moderation/eligibility rules are implemented.
class CrashOutSpacePrototypeData {
  const CrashOutSpacePrototypeData._();

  static List<CrashOutSpaceExperience> forTension(HumanTension tension) {
    final spaceId = tension.name;
    final examples = switch (tension) {
      HumanTension.connection => const [
          ('connection_01', 'I keep people at a distance because getting close can cost me something.', 'Sample Voice 01'),
          ('connection_02', 'I want to be close to someone without feeling like I am losing myself.', 'Sample Voice 02'),
          ('connection_03', 'I miss people, but I get tired of being around them so quickly.', 'Sample Voice 03'),
        ],
      HumanTension.attention => const [
          ('attention_01', 'I wish someone would notice when I am not okay without me having to say it.', 'Sample Voice 01'),
          ('attention_02', 'When people keep checking on me, I feel crowded instead of cared for.', 'Sample Voice 02'),
          ('attention_03', 'I want to be seen, but I do not want everyone looking at me.', 'Sample Voice 03'),
        ],
      HumanTension.dependence => const [
          ('dependence_01', 'I cannot keep doing everything alone. I wish asking for help felt easier.', 'Sample Voice 01'),
          ('dependence_02', 'Depending on people makes me feel trapped, so I would rather handle it myself.', 'Sample Voice 02'),
          ('dependence_03', 'I want support, but I hate feeling like I owe someone for it.', 'Sample Voice 03'),
        ],
      HumanTension.explanation => const [
          ('explanation_01', 'I am tired of explaining myself just to be misunderstood again.', 'Sample Voice 01'),
          ('explanation_02', 'I wish someone would try to understand before deciding what I meant.', 'Sample Voice 02'),
          ('explanation_03', 'Sometimes I stay quiet because explaining everything takes too much out of me.', 'Sample Voice 03'),
        ],
      HumanTension.presence => const [
          ('presence_01', 'I want people to stay when things get difficult, not only when I am easy to be around.', 'Sample Voice 01'),
          ('presence_02', 'Sometimes leaving is the only way I can breathe again.', 'Sample Voice 02'),
          ('presence_03', 'I want space, but I do not want people to assume I do not care.', 'Sample Voice 03'),
        ],
      HumanTension.responsibility => const [
          ('responsibility_01', 'Everyone expects me to hold everything together, and I am tired.', 'Sample Voice 01'),
          ('responsibility_02', 'I feel like I am falling behind while everyone else keeps moving.', 'Sample Voice 02'),
          ('responsibility_03', 'I want to be dependable, but I do not want every problem to become mine.', 'Sample Voice 03'),
        ],
      HumanTension.recognition => const [
          ('recognition_01', 'I do not need applause. I just want the effort I put in to matter.', 'Sample Voice 01'),
          ('recognition_02', 'Being praised makes me uncomfortable. I would rather work quietly.', 'Sample Voice 02'),
          ('recognition_03', 'It hurts when people benefit from what I do and act like it happened by itself.', 'Sample Voice 03'),
        ],
      HumanTension.control => const [
          ('control_01', 'I need to make my own decisions, even when I get them wrong.', 'Sample Voice 01'),
          ('control_02', 'I am exhausted from deciding everything and wish someone else would take over for once.', 'Sample Voice 02'),
          ('control_03', 'I want help, but I still need to feel like the choice is mine.', 'Sample Voice 03'),
        ],
      HumanTension.belonging => const [
          ('belonging_01', 'I want to feel included without pretending to be someone else.', 'Sample Voice 01'),
          ('belonging_02', 'I stopped trying to fit in. It costs too much of me.', 'Sample Voice 02'),
          ('belonging_03', 'I like being around people, but I never know if I really belong there.', 'Sample Voice 03'),
        ],
      HumanTension.vulnerability => const [
          ('vulnerability_01', 'I want to tell someone the truth, but I do not know where to start.', 'Sample Voice 01'),
          ('vulnerability_02', 'I keep everything to myself because opening up still feels unsafe.', 'Sample Voice 02'),
          ('vulnerability_03', 'I want to be known, but I am scared of what people might do with the truth.', 'Sample Voice 03'),
        ],
    };

    final now = DateTime.now();
    return [
      for (var i = 0; i < examples.length; i++)
        CrashOutSpaceExperience(
          id: 'prototype_${examples[i].$1}',
          spaceId: spaceId,
          content: examples[i].$2,
          voiceName: examples[i].$3,
          voiceMark: '◇',
          createdAt: now.subtract(Duration(minutes: i * 7)),
        ),
    ];
  }
}
