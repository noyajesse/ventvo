import '../models/resonance_map.dart';
import 'resonance_engine.dart';
import 'resonance_map_integrity_policy.dart';
import 'resonance_map_reconciliation_service.dart';

/// Application-facing query boundary for discoverable Resonance Maps.
///
/// Product features should ask this service for Maps rather than deciding
/// which Map states are safe or meaningful to surface themselves.
class ResonanceMapDiscoveryService {
  final ResonanceMapEngine engine;
  final ResonanceMapReconciliationService reconciliationService;
  final ResonanceMapIntegrityPolicy integrityPolicy;

  const ResonanceMapDiscoveryService({
    required this.engine,
    required this.reconciliationService,
    this.integrityPolicy = const ResonanceMapIntegrityPolicy(),
  });

  /// Returns only currently discoverable Maps involving an experience.
  ///
  /// Each Map is reconciled first so the result reflects the latest
  /// connection lifecycle state rather than stale persisted state.
  Future<List<ResonanceMap>> discoverForExperience(
    String experienceId, {
    int limit = 20,
  }) async {
    _validateExperienceId(experienceId);
    _validateLimit(limit);

    final maps = await engine.getMapsForExperience(experienceId);
    return _reconcileAndFilter(maps, limit: limit);
  }

  /// Returns currently discoverable Maps across Resonance.
  Future<List<ResonanceMap>> discoverAll({int limit = 20}) async {
    _validateLimit(limit);

    final maps = await engine.getMaps();
    return _reconcileAndFilter(maps, limit: limit);
  }

  Future<List<ResonanceMap>> _reconcileAndFilter(
    List<ResonanceMap> maps, {
    required int limit,
  }) async {
    final discoverable = <ResonanceMap>[];
    final seenIds = <String>{};

    for (final map in maps) {
      if (!seenIds.add(map.id)) continue;

      final result = await reconciliationService.reconcile(map.id);
      if (result == null) continue;

      final decision = integrityPolicy.evaluate(result.map);
      if (!decision.isDiscoverable) continue;

      discoverable.add(result.map);
      if (discoverable.length >= limit) break;
    }

    return List.unmodifiable(discoverable);
  }

  void _validateExperienceId(String experienceId) {
    if (experienceId.trim().isEmpty) {
      throw ArgumentError.value(
        experienceId,
        'experienceId',
        'Experience id cannot be empty.',
      );
    }
  }

  void _validateLimit(int limit) {
    if (limit <= 0) {
      throw ArgumentError.value(
        limit,
        'limit',
        'Limit must be greater than zero.',
      );
    }
  }
}
