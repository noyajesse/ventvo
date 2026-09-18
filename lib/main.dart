import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/ventvo_colors.dart';
import 'features/onboarding/welcome_screen.dart';
import 'features/feed/screens/feed_screen.dart';
import 'features/ventvo_voice/providers/voice_provider.dart';
import 'features/ventvo_voice/screens/voice_space_screen.dart';
import 'systems/resonance/services/resonance_demo_data_service.dart';

void main() {
  runApp(
    const ProviderScope(
      child: VentvoApp(),
    ),
  );
}

class VentvoApp extends StatelessWidget {
  const VentvoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ventvo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppEntryGate(),
    );
  }
}

class AppEntryGate extends ConsumerWidget {
  const AppEntryGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(resonanceDemoBootstrapProvider);
    final voice = ref.watch(ventvoVoiceProvider);

    return bootstrap.when(
      loading: () => const _AppLoadingScreen(),
      error: (_, _) => _voiceEntry(voice),
      data: (_) => _voiceEntry(voice),
    );
  }

  Widget _voiceEntry(AsyncValue<dynamic> voice) {
    return voice.when(
      loading: () => const _AppLoadingScreen(),
      error: (_, _) => const WelcomeScreen(),
      data: (value) {
        if (value == null) return const WelcomeScreen();
        return const FeedScreen();
      },
    );
  }
}

class _AppLoadingScreen extends StatelessWidget {
  const _AppLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: VentvoColors.background,
      body: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: VentvoColors.primary,
          ),
        ),
      ),
    );
  }
}
