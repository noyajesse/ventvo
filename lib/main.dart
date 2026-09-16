import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/ventvo_colors.dart';
import 'features/onboarding/welcome_screen.dart';
import 'features/ventvo_voice/providers/voice_provider.dart';
import 'features/ventvo_voice/screens/voice_space_screen.dart';

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
    final voice = ref.watch(ventvoVoiceProvider);

    return voice.when(
      loading: () => const _AppLoadingScreen(),
      error: (error, stackTrace) => const WelcomeScreen(),
      data: (value) {
        if (value == null) return const WelcomeScreen();
        return const VoiceSpaceScreen();
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
