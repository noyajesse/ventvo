import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/local_resonance_repository.dart';
import '../repositories/resonance_repository.dart';
import '../services/resonance_engine.dart';
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
