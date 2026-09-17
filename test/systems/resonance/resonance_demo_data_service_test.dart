import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ventvo/systems/resonance/providers/resonance_provider.dart';
import 'package:ventvo/systems/resonance/services/resonance_demo_data_service.dart';

void main() {
  test('bootstraps a connected demo Thread and Map', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(resonanceDemoBootstrapProvider.future);

    final engine = container.read(resonanceEngineProvider);
    final mapEngine = container.read(resonanceMapEngineProvider);
    final threads = await engine.getThreads();
    final maps = await mapEngine.getMaps();

    expect(threads, hasLength(1));
    expect(threads.single.experienceIds, containsAll(<String>[
      'demo_nera_moment',
      'demo_sol_moment',
      'demo_aven_moment',
      'demo_mira_moment',
    ]));

    expect(maps, hasLength(1));
    expect(maps.single.experienceIds, containsAll(<String>[
      'demo_nera_moment',
      'demo_sol_moment',
      'demo_aven_moment',
      'demo_mira_moment',
    ]));
    expect(maps.single.connections, hasLength(3));
  });

  test('bootstrap is idempotent inside one ProviderContainer', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(resonanceDemoBootstrapProvider.future);
    await container.read(resonanceDemoBootstrapProvider.future);

    final engine = container.read(resonanceEngineProvider);
    final mapEngine = container.read(resonanceMapEngineProvider);
    expect(await engine.getThreads(), hasLength(1));
    expect(await mapEngine.getMaps(), hasLength(1));
  });
}
