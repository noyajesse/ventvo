import 'package:flutter_test/flutter_test.dart';

import 'package:ventvo/systems/resonance/models/resonance_connection.dart';
import 'package:ventvo/systems/resonance/repositories/local_resonance_repository.dart';
import 'package:ventvo/systems/resonance/services/resonance_engine.dart';
import 'package:ventvo/systems/resonance/services/resonance_map_formation_service.dart';
import 'package:ventvo/systems/resonance/services/resonance_relationship_formation_service.dart';
import 'package:ventvo/systems/resonance/services/resonance_thread_formation_service.dart';
import 'package:ventvo/systems/resonance/services/resonance_thread_service.dart';

void main() {
  test('forms Thread and Map when lifecycle evidence is sufficient', () async {
    final repository = LocalResonanceRepository();
    final engine = LocalResonanceEngine(repository: repository);
    final threadService = ResonanceThreadService(engine: engine);
    final threadFormationService = ResonanceThreadFormationService(
      engine: engine,
      threadService: threadService,
    );
    final mapFormationService = ResonanceMapFormationService(engine: engine);
    final formationService = ResonanceRelationshipFormationService(
      threadFormationService: threadFormationService,
      mapFormationService: mapFormationService,
    );

    final createdAt = DateTime(2026, 9, 19);
    await repository.saveConnection(
      ResonanceConnection(
        id: 'vent-origin_vent-a',
        sourceId: 'vent-origin',
        targetId: 'vent-a',
        sourceVoiceId: 'voice-origin',
        targetVoiceId: 'voice-a',
        type: ResonanceConnectionType.sharedExperience,
        strength: 0.8,
        state: ResonanceConnectionState.accepted,
        createdAt: createdAt,
      ),
    );
    await repository.saveConnection(
      ResonanceConnection(
        id: 'vent-origin_vent-b',
        sourceId: 'vent-origin',
        targetId: 'vent-b',
        sourceVoiceId: 'voice-origin',
        targetVoiceId: 'voice-b',
        type: ResonanceConnectionType.perspective,
        strength: 0.8,
        state: ResonanceConnectionState.accepted,
        createdAt: createdAt,
      ),
    );

    final trigger = ResonanceConnection(
      id: 'vent-origin_vent-b',
      sourceId: 'vent-origin',
      targetId: 'vent-b',
      sourceVoiceId: 'voice-origin',
      targetVoiceId: 'voice-b',
      type: ResonanceConnectionType.perspective,
      strength: 0.8,
      state: ResonanceConnectionState.accepted,
      createdAt: createdAt,
    );

    final result = await formationService.handleConnectionStateChange(trigger);

    expect(result.thread, isNotNull);
    expect(
      result.thread!.experienceIds,
      containsAll(['vent-origin', 'vent-a', 'vent-b']),
    );
    expect(result.map, isNotNull);
    expect(
      result.map!.experienceIds,
      containsAll(['vent-origin', 'vent-a', 'vent-b']),
    );
  });

  test('does nothing for a suggested connection', () async {
    final repository = LocalResonanceRepository();
    final engine = LocalResonanceEngine(repository: repository);
    final formationService = ResonanceRelationshipFormationService(
      threadFormationService: ResonanceThreadFormationService(
        engine: engine,
        threadService: ResonanceThreadService(engine: engine),
      ),
      mapFormationService: ResonanceMapFormationService(engine: engine),
    );

    final connection = ResonanceConnection(
      id: 'vent-origin_vent-a',
      sourceId: 'vent-origin',
      targetId: 'vent-a',
      sourceVoiceId: 'voice-origin',
      targetVoiceId: 'voice-a',
      type: ResonanceConnectionType.sharedExperience,
      strength: 0.8,
      state: ResonanceConnectionState.suggested,
      createdAt: DateTime(2026, 9, 19),
    );

    final result = await formationService.handleConnectionStateChange(
      connection,
    );

    expect(result.thread, isNull);
    expect(result.map, isNull);
  });
}
