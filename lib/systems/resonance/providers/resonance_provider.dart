import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/local_resonance_repository.dart';
import '../repositories/resonance_repository.dart';
import '../services/resonance_connection_service.dart';
import '../services/resonance_engine.dart';
import '../services/resonance_map_discovery_service.dart';
import '../services/resonance_map_event_service.dart';
import '../services/resonance_map_evolution_service.dart';
import '../services/resonance_map_formation_service.dart';
import '../services/resonance_map_reconciliation_service.dart';
import '../services/resonance_relationship_formation_service.dart';
import '../services/resonance_map_thread_integration_service.dart';
import '../services/resonance_thread_discovery_service.dart';
import '../services/resonance_thread_formation_service.dart';
import '../services/resonance_thread_reconciliation_service.dart';
import '../services/resonance_thread_service.dart';
import '../services/space_resonance_discovery_service.dart';
import '../services/vent_resonance_discovery_service.dart';

final resonanceRepositoryProvider = Provider<ResonanceRepository>((ref) {
  return LocalResonanceRepository();
});

final localResonanceEngineProvider = Provider<LocalResonanceEngine>((ref) {
  return LocalResonanceEngine(
    repository: ref.watch(resonanceRepositoryProvider),
  );
});

final resonanceEngineProvider = Provider<ResonanceEngine>((ref) {
  return ref.watch(localResonanceEngineProvider);
});

final resonanceMapEngineProvider = Provider<ResonanceMapEngine>((ref) {
  return ref.watch(localResonanceEngineProvider);
});

final resonanceThreadReconciliationServiceProvider =
    Provider<ResonanceThreadReconciliationService>((ref) {
  return ResonanceThreadReconciliationService(
    engine: ref.watch(resonanceEngineProvider),
  );
});

final resonanceMapReconciliationServiceProvider =
    Provider<ResonanceMapReconciliationService>((ref) {
  return ResonanceMapReconciliationService(
    engine: ref.watch(resonanceMapEngineProvider),
  );
});

final resonanceMapFormationServiceProvider =
    Provider<ResonanceMapFormationService>((ref) {
  return ResonanceMapFormationService(
    engine: ref.watch(resonanceMapEngineProvider),
  );
});

final resonanceMapEvolutionServiceProvider =
    Provider<ResonanceMapEvolutionService>((ref) {
  return ResonanceMapEvolutionService(
    engine: ref.watch(resonanceMapEngineProvider),
    reconciliationService: ref.watch(
      resonanceMapReconciliationServiceProvider,
    ),
  );
});

final resonanceMapEventServiceProvider =
    Provider<ResonanceMapEventService>((ref) {
  return ResonanceMapEventService(
    mapEngine: ref.watch(resonanceMapEngineProvider),
    evolutionService: ref.watch(resonanceMapEvolutionServiceProvider),
  );
});

final resonanceMapDiscoveryServiceProvider =
    Provider<ResonanceMapDiscoveryService>((ref) {
  return ResonanceMapDiscoveryService(
    engine: ref.watch(resonanceMapEngineProvider),
    reconciliationService: ref.watch(
      resonanceMapReconciliationServiceProvider,
    ),
  );
});

final resonanceMapThreadIntegrationServiceProvider =
    Provider<ResonanceMapThreadIntegrationService>((ref) {
  return ResonanceMapThreadIntegrationService(
    resonanceEngine: ref.watch(resonanceEngineProvider),
    mapEngine: ref.watch(resonanceMapEngineProvider),
    reconciliationService: ref.watch(
      resonanceMapReconciliationServiceProvider,
    ),
  );
});

final resonanceRelationshipFormationServiceProvider =
    Provider<ResonanceRelationshipFormationService>((ref) {
  return ResonanceRelationshipFormationService(
    threadFormationService: ref.watch(
      resonanceThreadFormationServiceProvider,
    ),
    mapFormationService: ref.watch(
      resonanceMapFormationServiceProvider,
    ),
  );
});

final resonanceConnectionServiceProvider =
    Provider<ResonanceConnectionService>((ref) {
  return ResonanceConnectionService(
    engine: ref.watch(resonanceEngineProvider),
    threadReconciliationService: ref.watch(
      resonanceThreadReconciliationServiceProvider,
    ),
    mapEventService: ref.watch(resonanceMapEventServiceProvider),
    relationshipFormationService: ref.watch(
      resonanceRelationshipFormationServiceProvider,
    ),
  );
});

final resonanceThreadServiceProvider = Provider<ResonanceThreadService>((ref) {
  return ResonanceThreadService(
    engine: ref.watch(resonanceEngineProvider),
  );
});

final resonanceThreadFormationServiceProvider =
    Provider<ResonanceThreadFormationService>((ref) {
  final engine = ref.watch(resonanceEngineProvider);
  return ResonanceThreadFormationService(
    engine: engine,
    threadService: ref.watch(resonanceThreadServiceProvider),
  );
});

final resonanceThreadDiscoveryServiceProvider =
    Provider<ResonanceThreadDiscoveryService>((ref) {
  return ResonanceThreadDiscoveryService(
    engine: ref.watch(resonanceEngineProvider),
    reconciliationService: ref.watch(
      resonanceThreadReconciliationServiceProvider,
    ),
  );
});

final ventResonanceDiscoveryServiceProvider =
    Provider<VentResonanceDiscoveryService>((ref) {
  return VentResonanceDiscoveryService(
    engine: ref.watch(resonanceEngineProvider),
  );
});

final spaceResonanceDiscoveryServiceProvider =
    Provider<SpaceResonanceDiscoveryService>((ref) {
  return SpaceResonanceDiscoveryService(
    engine: ref.watch(resonanceEngineProvider),
  );
});
