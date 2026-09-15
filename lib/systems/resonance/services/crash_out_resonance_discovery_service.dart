import '../../../features/crash_out/models/crash_out.dart';
import '../../../features/spaces/models/space.dart';
import '../../../features/ventvo_voice/models/vent.dart';
import '../models/resonance_candidate.dart';
import '../models/resonance_query.dart';
import 'resonance_engine.dart';
import 'vent_resonance_signal_generator.dart';

/// Finds existing public Vents that may resonate with a Crash Out.
///
/// A Crash Out stays private. It is used only as a temporary discovery query;
/// no Crash Out is indexed or exposed as a Resonance experience.
class CrashOutResonanceDiscoveryService {
  final ResonanceEngine engine;
  final VentResonanceSignalGenerator signalGenerator;

  const CrashOutResonanceDiscoveryService({
    required this.engine,
    this.signalGenerator = const VentResonanceSignalGenerator(),
  });

  Future<List<ResonanceCandidate>> discoverForCrashOut({
    required CrashOut crashOut,
    required String voiceMark,
    Set<String> excludedIds = const {},
    int limit = 10,
  }) async {
    if (crashOut.type != CrashOutType.text) return const [];

    final content = crashOut.textContent?.trim() ?? '';
    if (content.length < 3 || limit <= 0) return const [];

    final queryVent = Vent(
      id: 'crash_out_query:${crashOut.id}',
      content: content,
      spaceId: 'crash_out_query:${crashOut.id}',
      voiceMark: voiceMark,
      visibility: VentVisibility.public,
      safetyState: VentSafetyState.approved,
    );

    final querySpace = Space(
      id: queryVent.spaceId,
      mode: SpaceMode.openDiscussion,
      originatingVentId: queryVent.id,
      creatorVoiceMark: voiceMark,
      createdAt: crashOut.createdAt,
    );

    final signals = signalGenerator.generate(
      vent: queryVent,
      space: querySpace,
    );

    return engine.discover(
      ResonanceQuery(
        sourceId: queryVent.id,
        sourceType: ResonanceCandidateType.vent,
        signals: signals,
        limit: limit,
        excludedIds: excludedIds,
      ),
    );
  }
}
