
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/crash_out.dart';
import '../providers/crash_out_provider.dart';

class CrashOutFateScreen extends ConsumerWidget {
  final CrashOut crashOut;

  const CrashOutFateScreen({
    super.key,
    required this.crashOut,
  });

  void _updateStatus(
    BuildContext context,
    WidgetRef ref,
    CrashOutStatus status,
  ) {
    ref
        .read(crashOutProvider.notifier)
        .updateStatus(
          crashOut.id,
          status,
        );

    Navigator.pop(context);
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),

      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        title: const Text(
          'Crash Out',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 24,
          ),
          child: Column(
            children: [
              const SizedBox(height: 45),

              const Text(
                'You let it out.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                "You don't have to do anything else with it.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 17,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 50),

              Expanded(
                child: ListView(
                  children: [
                    _FateOption(
                      icon: Icons.cloud_off_outlined,
                      title: 'Let Go',
                      description:
                          'Leave it here and let it disappear.',
                      onTap: () {
                        _updateStatus(
                          context,
                          ref,
                          CrashOutStatus.letGo,
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    _FateOption(
                      icon: Icons.lock_outline,
                      title: 'Keep Private',
                      description:
                          'Keep this moment for yourself.',
                      onTap: () {
                        _updateStatus(
                          context,
                          ref,
                          CrashOutStatus.keptPrivate,
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    _FateOption(
                      icon: Icons.waves_outlined,
                      title: 'Turn into a Vent',
                      description:
                          'Bring this moment into Ventvo.',
                      onTap: () {
                        _updateStatus(
                          context,
                          ref,
                          CrashOutStatus.convertedToVent,
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    _FateOption(
                      icon: Icons.people_outline,
                      title:
                          'Find People Who Understand',
                      description:
                          'Find a small group of Voices '
                          'who may understand what you are going through.',
                      onTap: () {
                        ref
                            .read(
                              crashOutProvider.notifier,
                            )
                            .enableMatching(
                              crashOut.id,
                            );

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Finding people who understand...',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FateOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _FateOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white12,
          ),
        ),

        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,

              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white12,
              ),

              child: Icon(
                icon,
                color: Colors.white70,
                size: 22,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color: Colors.white24,
            ),
          ],
        ),
      ),
    );
  }
}

