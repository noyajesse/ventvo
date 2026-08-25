import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/ventvo_colors.dart';
import '../../core/voice/ventvo_voice.dart' as voice_core;
import '../../core/voice/ventvo_voice_seed.dart';
import '../../core/voice/ventvo_voice_system.dart';
import '../ventvo_voice/models/ventvo_voice.dart' as voice_model;
import '../ventvo_voice/providers/voice_provider.dart';
import '../ventvo_voice/screens/voice_space_screen.dart';
import 'voice_formation_painter.dart';

class FindingYourVoiceScreen extends ConsumerStatefulWidget {
  const FindingYourVoiceScreen({super.key});

  @override
  ConsumerState<FindingYourVoiceScreen> createState() =>
      _FindingYourVoiceScreenState();
}

class _FindingYourVoiceScreenState
    extends ConsumerState<FindingYourVoiceScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _formationController;
  late final AnimationController _breathController;

  VentvoVoiceSeed? _seed;

  bool _isForming = false;
  bool _isRevealed = false;
  bool _canEnter = false;
  bool _hasEntered = false;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _formationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4800),
    );

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _introController.forward();

    _introController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _startFormation();
      }
    });

    _formationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _revealVoice();
      }
    });

    _breathController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _introController.dispose();
    _formationController.dispose();
    _breathController.dispose();
    super.dispose();
  }

  void _startFormation() {
    if (!mounted || _isForming) return;

    const voiceSystem = VentvoVoiceSystem();
    final seed = voiceSystem.createInitialSeed();

    setState(() {
      _seed = seed;
      _isForming = true;
    });

    _formationController.forward();
  }

  Future<void> _revealVoice() async {
    if (!mounted) return;

    setState(() {
      _isRevealed = true;
    });

    // Let the user sit with the completed Voice
    // before presenting the action.
    await Future<void>.delayed(
      const Duration(milliseconds: 900),
    );

    if (!mounted) return;

    setState(() {
      _canEnter = true;
    });
  }

  voice_core.VentvoVoice get _foundation {
    return _seed!.currentFoundation;
  }

  String get _voiceEssence {
    switch (_foundation) {
      case voice_core.VentvoVoice.vaelor:
        return 'A voice that gives what is inside a place to exist.';

      case voice_core.VentvoVoice.nyven:
        return 'A voice that finds resonance in being heard.';

      case voice_core.VentvoVoice.auren:
        return 'A voice that grows and becomes through expression.';
    }
  }

  Color get _voiceColor {
    switch (_foundation) {
      case voice_core.VentvoVoice.vaelor:
        return VentvoColors.primary;

      case voice_core.VentvoVoice.nyven:
        return VentvoColors.secondary;

      case voice_core.VentvoVoice.auren:
        return VentvoColors.primary;
    }
  }

  Future<void> _enterVentvo() async {
    if (_hasEntered || _seed == null) return;

    _hasEntered = true;

    final seed = _seed!;

    final voice = voice_model.VentvoVoice(
      voiceId: DateTime.now().microsecondsSinceEpoch.toString(),
      name: seed.name,
      mark: seed.mark,
      expression: _voiceEssence,
      resonance: _foundation.principle,
      createdAt: DateTime.now(),
    );

    await ref
        .read(ventvoVoiceProvider.notifier)
        .setVoice(voice);

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const VoiceSpaceScreen(),
      ),
      (route) => false,
    );
  }

  Widget _buildFindingContent(TextTheme textTheme) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(
        CurvedAnimation(
          parent: _introController,
          curve: const Interval(
            0.18,
            0.52,
            curve: Curves.easeOut,
          ),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _introController,
            curve: const Interval(
              0.18,
              0.58,
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Finding your voice.',
              textAlign: TextAlign.center,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 22),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 340,
              ),
              child: Text(
                'You don’t have to define yourself before you begin.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: VentvoColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your voice can grow with you.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: VentvoColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceReveal(TextTheme textTheme) {
    if (!_isRevealed || _seed == null) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _formationController,
        curve: const Interval(
          0.72,
          0.88,
          curve: Curves.easeOut,
        ),
      ),
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.88,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _formationController,
            curve: const Interval(
              0.70,
              0.90,
              curve: Curves.easeOutBack,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'YOUR VOICE',
              textAlign: TextAlign.center,
              style: textTheme.labelLarge?.copyWith(
                color: VentvoColors.textMuted,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.8,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _seed!.name,
              textAlign: TextAlign.center,
              style: textTheme.displaySmall?.copyWith(
                color: _voiceColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeaning(TextTheme textTheme) {
    if (!_isRevealed) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _formationController,
        curve: const Interval(
          0.80,
          0.94,
          curve: Curves.easeOut,
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 340,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _voiceEssence,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                color: VentvoColors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'It can grow with you.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: VentvoColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnterButton() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOut,
      opacity: _canEnter ? 1.0 : 0.0,
      child: IgnorePointer(
        ignoring: !_canEnter,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _enterVentvo,
            style: ElevatedButton.styleFrom(
              backgroundColor: VentvoColors.buttonBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              'Enter Ventvo',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisual() {
    final seed = _seed;

    if (seed == null) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: _introController,
          curve: const Interval(
            0.0,
            0.35,
            curve: Curves.easeOut,
          ),
        ),
        child: ScaleTransition(
          scale: Tween<double>(
            begin: 0.72,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: _introController,
              curve: const Interval(
                0.0,
                0.45,
                curve: Curves.easeOutBack,
              ),
            ),
          ),
          child: const _InitialMark(),
        ),
      );
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        _formationController,
        _breathController,
      ]),
      builder: (context, child) {
        final formationProgress =
            _formationController.value;

        final breath =
            Curves.easeInOut.transform(
          _breathController.value,
        );

        return CustomPaint(
          size: const Size(250, 250),
          painter: VoiceFormationPainter(
            progress: formationProgress,
            symbol: seed.mark,
            color: _voiceColor,
            breath: breath,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: VentvoColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight =
                constraints.maxHeight;

            return SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: availableHeight,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 24,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 520,
                      ),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 250,
                            height: 250,
                            child: _buildVisual(),
                          ),

                          const SizedBox(height: 22),

                          AnimatedSwitcher(
                            duration: const Duration(
                              milliseconds: 600,
                            ),
                            layoutBuilder:
                                (currentChild, previousChildren) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  ...previousChildren,
                                  ?currentChild,
                                ],
                              );
                            },
                            child: _isRevealed
                                ? _buildVoiceReveal(
                                    textTheme,
                                  )
                                : _buildFindingContent(
                                    textTheme,
                                  ),
                          ),

                          const SizedBox(height: 24),

                          _buildMeaning(textTheme),

                          const SizedBox(height: 38),

                          _buildEnterButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InitialMark extends StatelessWidget {
  const _InitialMark();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.graphic_eq_rounded,
        size: 78,
        color: VentvoColors.primary,
      ),
    );
  }
}