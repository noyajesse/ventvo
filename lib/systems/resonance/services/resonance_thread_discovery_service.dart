import '../models/resonance_thread.dart';
import 'resonance_engine.dart';
import 'resonance_thread_integrity_policy.dart';
import 'resonance_thread_reconciliation_service.dart';

/// Application-facing query boundary for discoverable Resonance Threads.
///
/// Product features should ask this service for Threads rather than deciding
/// which Thread states are safe or meaningful to surface themselves.
class ResonanceThreadDiscoveryService {
  final ResonanceEngine engine;
  final ResonanceThreadReconciliationService reconciliationService;
  final ResonanceThreadIntegrityPolicy integrityPolicy;

  const ResonanceThreadDiscoveryService({
    required this.engine,
    required this.reconciliationService,
    this.integrityPolicy = const ResonanceThreadIntegrityPolicy(),
  });

  /// Returns only currently discoverable Threads involving an experience.
  ///
  /// Each Thread is reconciled first so the result reflects the latest
  /// connection lifecycle state rather than stale persisted state.
  Future<List<ResonanceThread>> discoverForExperience(
    String experienceId, {
    int limit = 20,
  }) async {
    _validateExperienceId(experienceId);
    _validateLimit(limit);

    final threads = await engine.getThreadsForExperience(experienceId);
    return _reconcileAndFilter(threads, limit: limit);
  }

  /// Returns currently discoverable Threads across Resonance.
  Future<List<ResonanceThread>> discoverAll({int limit = 20}) async {
    _validateLimit(limit);

    final threads = await engine.getThreads();
    return _reconcileAndFilter(threads, limit: limit);
  }

  Future<List<ResonanceThread>> _reconcileAndFilter(
    List<ResonanceThread> threads, {
    required int limit,
  }) async {
    final discoverable = <ResonanceThread>[];
    final seenIds = <String>{};

    for (final thread in threads) {
      if (!seenIds.add(thread.id)) continue;

      final result = await reconciliationService.reconcile(thread.id);
      if (result == null) continue;

      final decision = integrityPolicy.evaluate(result.thread);
      if (!decision.isDiscoverable) continue;

      discoverable.add(result.thread);
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
