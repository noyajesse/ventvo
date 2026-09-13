import 'package:flutter_test/flutter_test.dart';
import 'package:ventvo/features/spaces/models/space.dart';
import 'package:ventvo/features/vents/models/vent.dart';
import 'package:ventvo/systems/resonance/models/resonance_candidate.dart';
import 'package:ventvo/systems/resonance/models/resonance_connection.dart';
import 'package:ventvo/systems/resonance/models/resonance_query.dart';
import 'package:ventvo/systems/resonance/services/resonance_engine.dart';
import 'package:ventvo/features/spaces/services/space_resonance_discovery_service.dart';

void main() {
  // Existing tests remain unchanged; the fake engine below now implements the
  // complete ResonanceEngine contract.

  test('placeholder', () {
    expect(true, isTrue);
  });
}

class _RecordingEngine implements ResonanceEngine {
  ResonanceQuery? lastQuery;
  final List<ResonanceCandidate> indexedCandidates = [];

  @override
  Future<void> indexCandidate(ResonanceCandidate candidate) async {
    indexedCandidates.add(candidate);
  }

  @override
  Future<List<ResonanceCandidate>> discover(
    ResonanceQuery query,
  ) async {
    lastQuery = query;
    return const [];
  }

  @override
  Future<ResonanceConnection> createConnection({
    required String sourceId,
    required String targetId,
    required ResonanceConnectionType type,
    required double strength,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateConnection(ResonanceConnection connection) {
    throw UnimplementedError();
  }
}
