import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../../../systems/resonance/models/resonance_candidate.dart';
import '../../../systems/resonance/providers/resonance_provider.dart';
import '../../feed/widgets/vent_card.dart';
import '../../ventvo_voice/models/vent.dart';
import '../../ventvo_voice/providers/vent_provider.dart';
import '../../ventvo_voice/providers/voice_provider.dart';
import '../models/crash_out.dart';

class CrashOutResonanceScreen extends ConsumerStatefulWidget {
  final CrashOut crashOut;

  const CrashOutResonanceScreen({
    super.key,
    required this.crashOut,
  });

  @override
  ConsumerState<CrashOutResonanceScreen> createState() =>
      _CrashOutResonanceScreenState();
}

class _CrashOutResonanceScreenState
    extends ConsumerState<CrashOutResonanceScreen> {
  late Future<List<Vent>> _matchesFuture;

  @override
  void initState() {
    super.initState();
    _matchesFuture = _discover();
  }

  Future<List<Vent>> _discover() async {
    final voice = await ref.read(ventvoVoiceProvider.future);
    final vents = await ref.read(ventProvider.future);

    if (voice == null || widget.crashOut.type != CrashOutType.text) {
      return const [];
    }

    final excludedIds = vents.map((vent) => vent.id).toSet();
    final candidates = await ref
        .read(crashOutResonanceDiscoveryServiceProvider)
        .discoverForCrashOut(
          crashOut: widget.crashOut,
          voiceMark: voice.mark ?? '◇',
          excludedIds: excludedIds,
          limit: 10,
        );

    final ventsById = <String, Vent>{
      for (final vent in vents)
        if (vent.isDiscoverable) vent.id: vent,
    };

    return [
      for (final candidate in candidates)
        if (candidate.type == ResonanceCandidateType.vent)
          if (ventsById[candidate.id] case final Vent vent) vent,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VentvoColors.background,
      appBar: AppBar(
        backgroundColor: VentvoColors.background,
        elevation: 0,
        title: const Text('People who may understand'),
      ),
      body: FutureBuilder<List<Vent>>(
        future: _matchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const _EmptyState(
              title: 'We could not find matches right now.',
              subtitle: 'You can come back and try again later.',
            );
          }

          final matches = snapshot.data ?? const <Vent>[];
          if (matches.isEmpty) {
            return const _EmptyState(
              title: 'Nothing feels close enough yet.',
              subtitle:
                  'Your Crash Out stays private. We only look for public thoughts that may resonate with what you shared.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _matchesFuture = _discover();
              });
              await _matchesFuture;
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 40),
              itemCount: matches.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const Padding(
                    padding: EdgeInsets.fromLTRB(8, 8, 8, 14),
                    child: Text(
                      'These are thoughts that may share something with what you just let out.',
                      style: TextStyle(
                        color: VentvoColors.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  );
                }

                return VentCard(
                  vent: matches[index - 1],
                  index: index - 1,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.waves_outlined,
              size: 42,
              color: VentvoColors.textMuted,
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: VentvoColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: VentvoColors.textMuted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
