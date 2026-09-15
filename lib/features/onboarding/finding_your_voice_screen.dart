import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/ventvo_colors.dart';
import '../ventvo_voice/models/voice_seed.dart';
import '../ventvo_voice/models/ventvo_voice.dart';
import '../ventvo_voice/providers/voice_provider.dart';
import '../ventvo_voice/screens/voice_space_screen.dart';
import '../ventvo_voice/services/voice_seed_discovery_service.dart';
import '../ventvo_voice/widgets/voice_seed_manifestation.dart';
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

  final VoiceSeedDiscoveryService _discoveryService =
      VoiceSeedDiscoveryService();

  VoiceSeed? _seed;
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

    // No questions, no personality quiz, and no VAELOR fallback.
    // Every new Voice receives a random starting Seed from the full catalog.
    final seed = _discoveryService.discoverRandom();

    setState(() {
      _seed = seed;
      _isForming = true;
    });

    _formationController.forward(from: 0);
  }

  Future<void> _revealVoice() async {
    if (!mounted) return;

    setState(() {
      _isRevealed = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() {
      _canEnter = true;
    });
  }

  Future<void> _enterVentvo() async {
    if (_hasEntered || _seed == null) return;

    _hasEntered = true;
    final seed = _seed!;

    final now = DateTime.now();
    final voice = VentvoVoice(
      voiceId: now.microsecondsSinceEpoch.toString(),
      seedId: seed.id,
      name: seed.word,
      mark: seed.mark.symbol,
      expression: seed.meaning,
      resonance: seed.feeling,
      createdAt: now,
    );

    await ref.read(ventvoVoiceProvider.notifier).setVoice(voice);
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const VoiceSpaceScreen()),
      (route) => false,
    );
  }

  Widget _buildFindingContent(TextTheme textTheme) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.18, 0.52, curve: Curves.easeOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _introController,
            curve: const Interval(0.18, 0.58, curve: Curves.easeOutCubic),
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
              constraints: const BoxConstraints(maxWidth: 340),
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

  Widget _buildFormationContent() {
    final seed = _seed;
    if (!_isForming || seed == null) {
      return const SizedBox.shrink();
    }

    final isVaelor = seed.id == 'vaelor';
    final child = isVaelor
        ? AnimatedBuilder(
            animation: Listenable.merge([
              _formationController,
              _breathController,
            ]),
            builder: (context, _) => CustomPaint(
              size: const Size(250, 250),
              painter: VoiceFormationPainter(
                progress: _formationController.value,
                symbol: seed.mark.symbol,
                color: VentvoColors.primary,
                breath: _breathController.value,
              ),
            ),
          )
        : VoiceSeedManifestation(
            seed: seed,
            size: 250,
            reveal: true,
          );

    return child;
  }

  Widget _buildRevealContent(TextTheme textTheme) {
    final seed = _seed;
    if (!_isRevealed || seed == null) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'YOUR VOICE',
          style: textTheme.labelLarge?.copyWith(
            color: VentvoColors.textMuted,
            letterSpacing: 3.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          seed.word,
          style: textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 330),
          child: Text(
            seed.meaning,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: VentvoColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'It can grow with you.',
          style: textTheme.bodySmall?.copyWith(
            color: VentvoColors.textMuted,
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: 190,
          height: 48,
          child: ElevatedButton(
            onPressed: _canEnter ? _enterVentvo : null,
            child: const Text('Enter Ventvo'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: VentvoColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: _isRevealed
                          ? _buildRevealContent(textTheme)
                          : _buildFormationContent(),
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _isForming && !_isRevealed
                      ? _buildFindingContent(textTheme)
                      : const SizedBox(height: 120),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
