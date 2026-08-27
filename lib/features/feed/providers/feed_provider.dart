import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ventvo_voice/models/vent.dart';
import '../../ventvo_voice/providers/vent_provider.dart';

/// Discovery is separate from a person's Voice.
///
/// These local moments let us experience the intended multi-Voice Feed before
/// a remote discovery source is connected.
class FeedNotifier extends Notifier<List<Vent>> {
  @override
  List<Vent> build() {
    final ownVents = ref.watch(ventProvider).asData?.value ?? const <Vent>[];

    final discovered = <Vent>[
      Vent(
        id: 'sample_moment_01',
        content: 'I keep thinking about how strange it is that you can miss a version of yourself that you were never really happy being.',
        spaceId: 'sample_space_01',
        voiceMark: '◇ Nera',
        voiceName: 'Nera',
        createdAt: DateTime(2026, 8, 27, 12, 10),
      ),
      Vent(
        id: 'sample_moment_02',
        content: 'Today I realized I do not need an answer yet. I just needed somewhere to put the question.',
        spaceId: 'sample_space_02',
        voiceMark: '◇ Sol',
        voiceName: 'Sol',
        createdAt: DateTime(2026, 8, 27, 11, 42),
      ),
      Vent(
        id: 'sample_moment_03',
        content: 'There are people I have never spoken to who somehow made me feel less alone.',
        spaceId: 'sample_space_03',
        voiceMark: '◇ Aven',
        voiceName: 'Aven',
        createdAt: DateTime(2026, 8, 27, 10, 58),
      ),
    ];

    return [...ownVents, ...discovered]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void addDiscoveredMoment(Vent vent) {
    if (state.any((item) => item.id == vent.id)) return;
    state = [vent, ...state];
  }
}

final feedProvider = NotifierProvider<FeedNotifier, List<Vent>>(
  FeedNotifier.new,
);
