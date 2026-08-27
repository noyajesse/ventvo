import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ventvo_voice/models/vent.dart';
import '../../ventvo_voice/providers/vent_provider.dart';

/// The discovery layer for the Feed.
///
/// A Voice owns a person's Vents. The Feed owns the Moments a person
/// discovers. For the current local build, newly created Vents are seeded
/// into discovery so the experience remains testable until remote discovery
/// is connected.
class FeedNotifier extends Notifier<List<Vent>> {
  @override
  List<Vent> build() {
    return ref.watch(ventProvider).asData?.value ?? const <Vent>[];
  }

  void addDiscoveredMoment(Vent vent) {
    if (state.any((item) => item.id == vent.id)) return;
    state = [vent, ...state];
  }
}

final feedProvider = NotifierProvider<FeedNotifier, List<Vent>>(
  FeedNotifier.new,
);
