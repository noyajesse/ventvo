import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/local_resonance_repository.dart';
import '../repositories/resonance_repository.dart';
import '../services/resonance_connection_service.dart';
import '../services/resonance_engine.dart';
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

/// Shared Resonance engine for the current local deterministic implementation.
final resonanceEngineProvider = Provider<ResonanceEngine>((ref) {
  return LocalResonanceEngine(
    repository: ref.watch(resonanceRepositoryProvider),
  );
});

/// Shared Map capability exposed by the same Resonance engine instance.
final resonanceMapEngineProvider = Provider<ResonanceMapEngine>((ref) {
  final engine = ref.watch(resonanceEngineProvider);
  if (engine is ResonanceMapEngine) {
    return engine;
  }
  throw StateError('The configured Resonance engine does not support Maps.');
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
///
/// Product features should use this boundary for Thread creation and
/// extension rather than mutating Thread models directly.
final resonanceThreadServiceProvider = Provider<ResonanceThreadService>((ref) {
  return ResonanceThreadService(
    engine: ref.watch(resonanceEngineProvider),
  );
});

/// Application-facing Thread formation service for Resonance.
///
/// This service decides whether a new experience meaningfully continues an
/// existing Thread. It reuses the shared engine and Thread service rather than
/// introducing matching logic into product features.
final resonanceThreadFormationServiceProvider =
    Provider<ResonanceThreadFormationService>((ref) {
  final engine = ref.watch(resonanceEngineProvider);
  return ResonanceThreadFormationService(
    engine: engine,
    threadService: ref.watch(resonanceThreadServiceProvider),
  );
});

/// Application-facing Thread discovery/query boundary.
///
/// Product surfaces should use this provider when they need discoverable
/// Threads. They should not implement Thread-state filtering themselves.
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
///
/// Feed, Space, and Crash Out should consume this boundary rather than create
/// a Resonance engine or repository directly.
final ventResonanceDiscoveryServiceProvider =
    Provider<VentResonanceDiscoveryService>((ref) {
  return VentResonanceDiscoveryService(
    engine: ref.watch(resonanceEngineProvider),
  );
});

/// Application-facing discovery service for Space experiences.
///
/// Space uses the same Resonance engine as every other product surface. It
/// does not perform candidate matching or repository access itself.
final spaceResonanceDiscoveryServiceProvider =
    Provider<SpaceResonanceDiscoveryService>((ref) {
  return SpaceResonanceDiscoveryService(
    engine: ref.watch(resonanceEngineProvider),
  );
});
