import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/ventvo_colors.dart';
import '../../../systems/resonance/models/resonance_candidate.dart';
import '../../../systems/resonance/providers/resonance_provider.dart'
import '../../feed/widgets/vent_card.dart';
import 'resonance_connection_screen.dart';
import '../models/vent.dart';
import '../providers/vent_provider.dart';
import '../../spaces/providers/space_provider.dart';

class FindPeopleScreen extends ConsumerStatefulWidget {
  const FindPeopleScreen({super.key});

  @override
  ConsumerState<FindPeopleScreen> createState() => _FindPeopleScreenState();
}

class _FindPeopleScreenState extends ConsumerState<FindPeopleScreen> {
  Vent? _selectedVent;
  Future<List<Vent>>? _matchesFuture;

  Future<List<Vent>> _discover(Vent vent) async {
    final spaces = await ref.read(spaceProvider.future);
    final space = spaces.where((item) => item.id == vent.spaceId).firstOrNull;
    if (space == null || !vent.isDiscoverable) return const [];

    final vents = await ref.read(ventProvider.future);
    final excludedIds = vents.map((item) => item.id).toSet();

    final candidates = await ref
        .read(ventResonanceDiscoveryServiceProvider)
        .discoverForVent(
          vent: vent,
          space: space,
          excludedIds: excludedIds,
          limit: 10,
        );

    final ventsById = <String, Vent>{
      for (final item in vents)
        if (item.isDiscoverable) item.id: item,
    };

    return [
      for (final candidate in candidates)
        if (candidate.type == ResonanceCandidateType.vent)
          if (ventsById[candidate.id] case final Vent match) match,
    ];
  }

  void _selectVent(Vent vent) {
    setState(() {
      _selectedVent = vent;
      _matchesFuture = _discover(vent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vents = ref.watch(ventProvider).asData?.value ?? const <Vent>[];
    final discoverableVents = vents.where((vent) => vent.isDiscoverable).toList();

    return Scaffold(
      backgroundColor: VentvoColors.background,
      appBar: AppBar(
        backgroundColor: VentvoColors.background,
        elevation: 0,
        title: const Text('Find People Who Understand'),
      ),
      body: SafeArea(
        child: discoverableVents.isEmpty
            ? const _EmptyState(
                title: 'Give us a moment to start from.',
                subtitle:
                    'Release a public Vent first. Then you can use that experience to find other thoughts that may resonate with it.',
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 40),
                children: [
                  const Text(
                    'Start with something you have already shared.',
                    style: TextStyle(
                      color: VentvoColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We use the experience in that Vent to look for other public thoughts that may resonate with it.',
                    style: TextStyle(
                      color: VentvoColors.textMuted,
                      fontSize: 13,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...discoverableVents.map(
                    (vent) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _VentChoice(
                        vent: vent,
                        selected: _selectedVent?.id == vent.id,
                        onTap: () => _selectVent(vent),
                      ),
                    ),
                  ),
                  if (_selectedVent != null) ...[
                    const SizedBox(height: 18),
                    FutureBuilder<List<Vent>>(
                      future: _matchesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (snapshot.hasError) {
                          return const _EmptyState(
                            title: 'We could not find matches right now.',
                            subtitle: 'Try again in a moment.',
                          );
                        }

                        final matches = snapshot.data ?? const <Vent>[];
                        if (matches.isEmpty) {
                          return const _EmptyState(
                            title: 'Nothing feels close enough yet.',
                            subtitle:
                                'Only public, approved, active thoughts are considered. Your own Vent is not returned as a match.',
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Thoughts that may understand something of it',
                              style: TextStyle(
                                color: VentvoColors.textPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...matches.asMap().entries.map(
                                  (entry) {
                                    final match = entry.value;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 18),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          VentCard(
                                            vent: match,
                                            index: entry.key,
                                          ),
                                          const SizedBox(height: 2),
                                          OutlinedButton.icon(
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      ResonanceConnectionScreen(
                                                    sourceVent: _selectedVent!,
                                                    targetVent: match,
                                                  ),
                                                ),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.waves_rounded,
                                              size: 16,
                                            ),
                                            label: const Text(
                                              'This resonates with me',
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                          ],
                        );
                      },
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _VentChoice extends StatelessWidget {
  const _VentChoice({
    required this.vent,
    required this.selected,
    required this.onTap,
  });

  final Vent vent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: VentvoColors.surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? VentvoColors.primary.withValues(alpha: .65)
                    : VentvoColors.border,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    vent.content,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: VentvoColors.textPrimary,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.arrow_forward_ios_rounded,
                  size: 19,
                  color: selected
                      ? VentvoColors.primary
                      : VentvoColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.people_outline_rounded,
                size: 44,
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
