import '../models/crash_out_space_experience.dart';
import '../models/experience_representation.dart';
import '../providers/crash_out_space_provider.dart';

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

  static List<CrashOutSpaceReply> repliesForTension(HumanTension tension) {
    final examples = switch (tension) {
      HumanTension.connection => const [
          ('connection_reply_01', 'connection_01', 'I tell myself that too, especially when I feel like I am the only one trying.', 'Sample Voice 04'),
          ('connection_reply_02', 'connection_02', 'I think I sometimes confuse closeness with having to give up my own space.', 'Sample Voice 05'),
        ],
      HumanTension.attention => const [
          ('attention_reply_01', 'attention_01', 'It is hard having to ask for the care you hoped someone would notice you needed.', 'Sample Voice 04'),
          ('attention_reply_02', 'attention_02', 'I pull away too, even when part of me wants them to check in.', 'Sample Voice 05'),
        ],
      HumanTension.dependence => const [
          ('dependence_reply_01', 'dependence_01', 'Asking is the hardest part for me. I rehearse it and then do it alone.', 'Sample Voice 04'),
          ('dependence_reply_02', 'dependence_02', 'I hear you. Help can feel like a debt even when nobody says it is.', 'Sample Voice 05'),
        ],
      HumanTension.explanation => const [
          ('explanation_reply_01', 'explanation_01', 'After a while, silence feels easier than being misunderstood again.', 'Sample Voice 04'),
          ('explanation_reply_02', 'explanation_02', 'I try to ask one more question before I decide what someone meant.', 'Sample Voice 05'),
        ],
      HumanTension.presence => const [
          ('presence_reply_01', 'presence_01', 'Consistency means more to me than someone always knowing the perfect thing to say.', 'Sample Voice 04'),
          ('presence_reply_02', 'presence_02', 'Sometimes leaving is not about not caring. It is about reaching your limit.', 'Sample Voice 05'),
        ],
      HumanTension.responsibility => const [
          ('responsibility_reply_01', 'responsibility_01', 'People see that you can handle things and forget to ask whether you should have to.', 'Sample Voice 04'),
          ('responsibility_reply_02', 'responsibility_02', 'I keep comparing my pace to everyone else and it never helps.', 'Sample Voice 05'),
        ],
      HumanTension.recognition => const [
          ('recognition_reply_01', 'recognition_01', 'Being noticed for the effort would mean more than being praised for the result.', 'Sample Voice 04'),
          ('recognition_reply_02', 'recognition_02', 'I avoid attention too, but sometimes I still want people to see the work.', 'Sample Voice 05'),
        ],
      HumanTension.control => const [
          ('control_reply_01', 'control_01', 'I want advice sometimes, but I still need the final decision to be mine.', 'Sample Voice 04'),
          ('control_reply_02', 'control_02', 'It is exhausting being the person everyone waits on to decide.', 'Sample Voice 05'),
        ],
      HumanTension.belonging => const [
          ('belonging_reply_01', 'belonging_01', 'I want to be included without having to perform a version of myself.', 'Sample Voice 04'),
          ('belonging_reply_02', 'belonging_02', 'Leaving first can feel safer than waiting to find out if you fit.', 'Sample Voice 05'),
        ],
      HumanTension.vulnerability => const [
          ('vulnerability_reply_01', 'vulnerability_01', 'You do not have to tell everything at once for it to count as opening up.', 'Sample Voice 04'),
          ('vulnerability_reply_02', 'vulnerability_02', 'Keeping things in protects you until it starts feeling lonely too.', 'Sample Voice 05'),
        ],
    };

    final now = DateTime.now();
    return [
      for (var i = 0; i < examples.length; i++)
        CrashOutSpaceReply(
          id: 'prototype_reply_${examples[i].$1}',
          experienceId: 'prototype_${examples[i].$2}',
          content: examples[i].$3,
          voiceName: examples[i].$4,
          voiceMark: '◇',
          createdAt: now.subtract(Duration(minutes: i * 5)),
        ),
    ];
  }
}
