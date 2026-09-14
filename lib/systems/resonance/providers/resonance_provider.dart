import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/local_resonance_repository.dart';
import '../repositories/resonance_repository.dart';
import '../services/resonance_connection_service.dart';
import '../services/resonance_engine.dart';
import '../services/resonance_map_discovery_service.dart';
import '../services/resonance_map_formation_service.dart';
import '../services/resonance_map_reconciliation_service.dart';
import '../services/resonance_thread_discovery_service.dart';
import '../services/resonance_thread_formation_service.dart';
import '../services/resonance_thread_reconciliation_service.dart';
import '../services/resonance_thread_service.dart';
import '../services/space_resonance_discovery_service.dart';
import '../services/vent_resonance_discovery_service.dart';

/// Shared local Resonance repository.
///
/// Product features depend on the contract rather than constructing storage
/// themselves. The provider can later be overridden with a backend repository.
final resonanceRepositoryProvider = Provider<ResonanceRepository>((ref) {
  return LocalResonanceRepository();
});

/// Concrete local engine instance shared by all Resonance capabilities.
final localResonanceEngineProvider = Provider<LocalResonanceEngine>((ref) {
  return LocalResonanceEngine(
    repository: ref.watch(resonanceRepositoryProvider),
  );
});

/// Shared Resonance engine exposed through the core capability contract.
final resonanceEngineProvider = Provider<ResonanceEngine>((ref) {
  return ref.watch(localResonanceEngineProvider);
});

/// Shared Map capability exposed from the same concrete engine instance.
final resonanceMapEngineProvider = Provider<ResonanceMapEngine>((ref) {
  return ref.watch(localResonanceEngineProvider);
});

/// Shared Thread reconciliation boundary.
final resonanceThreadReconciliationServiceProvider =
    Provider<ResonanceThreadReconciliationService>((ref) {
  return ResonanceThreadReconciliationService(
    engine: ref.watch(resonanceEngineProvider),
  );
});

/// Shared Map reconciliation boundary.
final resonanceMapReconciliationServiceProvider =
    Provider<ResonanceMapReconciliationService>((ref) {
  return ResonanceMapReconciliationService(
    engine: ref.watch(resonanceMapEngineProvider),
  );
});

/// Application-facing Map formation service.
///
/// Formation decides whether meaningful Resonance evidence is strong enough
/// for a Map to exist. It is deliberately separate from Map discovery and
/// reconciliation.
final resonanceMapFormationServiceProvider =
    Provider<ResonanceMapFormationService>((ref) {
  return ResonanceMapFormationService(
    engine: ref.watch(resonanceMapEngineProvider),
  );
});

/// Shared Map discovery/query boundary.
final resonanceMapDiscoveryServiceProvider =
    Provider<ResonanceMapDiscoveryService>((ref) {
  return ResonanceMapDiscoveryService(
    engine: ref.watch(resonanceMapEngineProvider),
    reconciliationService: ref.watch(
      resonanceMapReconciliationServiceProvider,
    ),
  );
});

/// Application-facing connection service for Resonance relationships.
final resonanceConnectionServiceProvider =
    Provider<ResonanceConnectionService>((ref) {
  return ResonanceConnectionService(
    engine: ref.watch(resonanceEngineProvider),
    threadReconciliationService: ref.watch(
      resonanceThreadReconciliationServiceProvider,
    ),
  );
});

/// Application-facing Thread service for Resonance Threads.
final resonanceThreadServiceProvider = Provider<ResonanceThreadService>((ref) {
  return ResonanceThreadService(
    engine: ref.watch(resonanceEngineProvider),
  );
});

/// Application-facing Thread formation service for Resonance.
final resonanceThreadFormationServiceProvider =
    Provider<ResonanceThreadFormationService>((ref) {
  final engine = ref.watch(resonanceEngineProvider);
  return ResonanceThreadFormationService(
    engine: engine,
    threadService: ref.watch(resonanceThreadServiceProvider),
  );
});

/// Application-facing Thread discovery/query boundary.
final resonanceThreadDiscoveryServiceProvider =
    Provider<ResonanceThreadDiscoveryService>((ref) {
  return ResonanceThreadDiscoveryService(
    engine: ref.watch(resonanceEngineProvider),
    reconciliationService: ref.watch(
      resonanceThreadReconciliationServiceProvider,
    ),
  );
});

/// Application-facing discovery service for Vent experiences.
final ventResonanceDiscoveryServiceProvider =
    Provider<VentResonanceDiscoveryService>((ref) {
  return VentResonanceDiscoveryService(
    engine: ref.watch(resonanceEngineProvider),
  );
});

/// Application-facing discovery service for Space experiences.
final spaceResonanceDiscoveryServiceProvider =
    Provider<SpaceResonanceDiscoveryService>((ref) {
  return SpaceResonanceDiscoveryService(
    engine: ref.watch(resonanceEngineProvider),
  );
});
