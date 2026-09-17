import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/spaces/models/space.dart';
import '../../../features/ventvo_voice/models/vent.dart';
import '../models/resonance_connection.dart';
import '../providers/resonance_provider.dart';

/// Controlled local-only experiences used to make the Resonance prototype
/// observable before a multi-user backend exists.
///
/// These fixtures are deliberately kept outside product domain storage. They
/// are indexed into the same Resonance engine as real discoverable Vents, so
/// Feed and Space can exercise the real discovery path while Threads and Maps
/// can be formed from real lifecycle evidence.
class ResonanceDemoDataService {
  static final DateTime _createdAt = DateTime(2026, 8, 27, 12, 0);

  static final List<Vent> vents = [
    Vent(
      id: 'demo_nera_moment',
      content: 'I thought starting over would make me feel free. Nobody tells you how invisible a new beginning can feel.',
      spaceId: 'demo_nera_space',
      voiceMark: '◇ Nera',
      voiceName: 'Nera',
      createdAt: DateTime(2026, 8, 27, 12, 10),
    ),
    Vent(
      id: 'demo_sol_moment',
      content: 'The strangest part of starting over is realizing nobody knows the version of you that existed before.',
      spaceId: 'demo_sol_space',
      voiceMark: '◇ Sol',
      voiceName: 'Sol',
      createdAt: DateTime(2026, 8, 27, 11, 42),
    ),
    Vent(
      id: 'demo_aven_moment',
      content: 'I left because I needed a new beginning, but some kinds of loneliness follow you wherever you go.',
      spaceId: 'demo_aven_space',
      voiceMark: '◇ Aven',
      voiceName: 'Aven',
      createdAt: DateTime(2026, 8, 27, 11, 15),
    ),
    Vent(
      id: 'demo_mira_moment',
      content: 'Maybe belonging is not finding a place that already knows you. Maybe it is slowly becoming known somewhere new.',
      spaceId: 'demo_mira_space',
      voiceMark: '◇ Mira',
      voiceName: 'Mira',
      createdAt: DateTime(2026, 8, 27, 10, 48),
    ),
  ];

  static final List<Space> spaces = [
    Space(
      id: 'demo_nera_space',
      mode: SpaceMode.justListen,
      originatingVentId: 'demo_nera_moment',
      creatorVoiceMark: '◇ Nera',
      createdAt: DateTime(2026, 8, 27, 12, 10),
    ),
    Space(
      id: 'demo_sol_space',
      mode: SpaceMode.openDiscussion,
      originatingVentId: 'demo_sol_moment',
      creatorVoiceMark: '◇ Sol',
      createdAt: DateTime(2026, 8, 27, 11, 42),
    ),
    Space(
      id: 'demo_aven_space',
      mode: SpaceMode.justListen,
      originatingVentId: 'demo_aven_moment',
      creatorVoiceMark: '◇ Aven',
      createdAt: DateTime(2026, 8, 27, 11, 15),
    ),
    Space(
      id: 'demo_mira_space',
      mode: SpaceMode.openDiscussion,
      originatingVentId: 'demo_mira_moment',
      creatorVoiceMark: '◇ Mira',
      createdAt: DateTime(2026, 8, 27, 10, 48),
    ),
  ];

  final Ref ref;

  ResonanceDemoDataService(this.ref);

  Future<void> initialize() async {
    final engine = ref.read(resonanceEngineProvider);
    final connectionService = ref.read(resonanceConnectionServiceProvider);
    final threadFormation = ref.read(resonanceThreadFormationServiceProvider);
    final mapFormation = ref.read(resonanceMapFormationServiceProvider);
    final threadService = ref.read(resonanceThreadServiceProvider);

    final existingThread = await engine.getThread('demo-thread-starting-over');
    if (existingThread != null) return;

    final ventDiscovery = ref.read(ventResonanceDiscoveryServiceProvider);
    for (final vent in vents) {
      final space = spaces.firstWhere((item) => item.id == vent.spaceId);
      await ventDiscovery.indexVent(vent: vent, space: space);
    }

    final first = await engine.createConnection(
      sourceId: 'demo_nera_moment',
      targetId: 'demo_sol_moment',
      type: ResonanceConnectionType.sharedExperience,
      strength: 0.84,
    );
    final second = await engine.createConnection(
      sourceId: 'demo_nera_moment',
      targetId: 'demo_aven_moment',
      type: ResonanceConnectionType.sharedExperience,
      strength: 0.78,
    );

    await connectionService.accept(first);
    await connectionService.accept(second);

    final thread = await threadFormation.formThreadForExperience(
      experienceId: 'demo_nera_moment',
      threadId: 'demo-thread-starting-over',
      voiceMark: '◇ Nera',
      voiceMarks: const ['◇ Sol', '◇ Aven'],
      createdAt: _createdAt,
    );
    if (thread == null) return;

    await mapFormation.formForExperience(
      'demo_nera_moment',
      createdAt: _createdAt,
    );

    final third = await engine.createConnection(
      sourceId: 'demo_nera_moment',
      targetId: 'demo_mira_moment',
      type: ResonanceConnectionType.perspective,
      strength: 0.72,
    );
    final acceptedThird = await connectionService.accept(third);
    if (acceptedThird == null) return;

    await threadService.extendThread(
      thread: thread,
      experienceId: 'demo_mira_moment',
      voiceMark: '◇ Mira',
      connection: acceptedThird,
    );
  }
}

final resonanceDemoDataServiceProvider =
    Provider<ResonanceDemoDataService>((ref) {
  return ResonanceDemoDataService(ref);
});

final resonanceDemoBootstrapProvider = FutureProvider<void>((ref) {
  return ref.read(resonanceDemoDataServiceProvider).initialize();
});
