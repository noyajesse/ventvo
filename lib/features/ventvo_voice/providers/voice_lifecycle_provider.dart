import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'vent_provider.dart';
import 'voice_provider.dart';
import 'voice_space_provider.dart';

enum VoiceLifecycleStage {
  seed,
  expression,
  resonance,
  becoming,
}

class VoiceLifecycleSnapshot {
  const VoiceLifecycleSnapshot({
    required this.stage,
    required this.ventCount,
    required this.resonanceCount,
    required this.arcCount,
    required this.hasExpression,
    required this.hasResonance,
  });

  final VoiceLifecycleStage stage;
  final int ventCount;
  final int resonanceCount;
  final int arcCount;
  final bool hasExpression;
  final bool hasResonance;

  bool hasReached(VoiceLifecycleStage value) => value.index <= stage.index;
}

final voiceLifecycleProvider = FutureProvider<VoiceLifecycleSnapshot>((ref) async {
  final voice = ref.watch(ventvoVoiceProvider).asData?.value;
  final vents = await ref.watch(ventProvider.future);
  final resonance = await ref.watch(voiceSpaceResonanceStatsProvider.future);

  final hasExpression = _hasText(voice?.expression) || vents.isNotEmpty;
  final hasResonance = _hasText(voice?.resonance) || resonance.threads > 0;

  final stage = voiceLifecycleStageFor(
    hasExpression: hasExpression,
    hasResonance: hasResonance,
    arcCount: resonance.maps,
  );

  return VoiceLifecycleSnapshot(
    stage: stage,
    ventCount: vents.length,
    resonanceCount: resonance.threads,
    arcCount: resonance.maps,
    hasExpression: hasExpression,
    hasResonance: hasResonance,
  );
});

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

VoiceLifecycleStage voiceLifecycleStageFor({
  required bool hasExpression,
  required bool hasResonance,
  required int arcCount,
}) {
  if (arcCount > 0) return VoiceLifecycleStage.becoming;
  if (hasResonance) return VoiceLifecycleStage.resonance;
  if (hasExpression) return VoiceLifecycleStage.expression;
  return VoiceLifecycleStage.seed;
}

extension VoiceLifecycleLabels on VoiceLifecycleStage {
  String get title {
    switch (this) {
      case VoiceLifecycleStage.seed:
        return 'Seed';
      case VoiceLifecycleStage.expression:
        return 'Expression';
      case VoiceLifecycleStage.resonance:
        return 'Resonance';
      case VoiceLifecycleStage.becoming:
        return 'Becoming';
    }
  }

  String get description {
    switch (this) {
      case VoiceLifecycleStage.seed:
        return 'This is where your Voice begins.';
      case VoiceLifecycleStage.expression:
        return 'Your Voice has started to put something into the world.';
      case VoiceLifecycleStage.resonance:
        return 'Your experiences are beginning to recognize other experiences.';
      case VoiceLifecycleStage.becoming:
        return 'Your Voice is carrying a history of what you have lived and recognized.';
    }
  }
}
