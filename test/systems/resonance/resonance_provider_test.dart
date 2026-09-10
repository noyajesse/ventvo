import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ventvo/systems/resonance/providers/resonance_provider.dart';
import 'package:ventvo/systems/resonance/services/vent_resonance_discovery_service.dart';

void main() {
  test('provides the shared Resonance application boundary', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final repository = container.read(resonanceRepositoryProvider);
    final engine = container.read(resonanceEngineProvider);
    final discovery = container.read(ventResonanceDiscoveryServiceProvider);

    expect(repository, isNotNull);
    expect(engine, isNotNull);
    expect(discovery, isA<VentResonanceDiscoveryService>());
  });

  test('uses the same repository instance for the engine', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final repository = container.read(resonanceRepositoryProvider);
    final engine = container.read(resonanceEngineProvider);

    expect(engine, isNotNull);
    // Reading the repository again must return the same provider-scoped object.
    expect(identical(repository, container.read(resonanceRepositoryProvider)), isTrue);
  });
}
