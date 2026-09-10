import 'package:flutter/material.dart';

import '../ventvo_voice/models/vent.dart';
import '../ventvo_voice/screens/create_vent_screen.dart';

class VentsIntentScreen extends StatelessWidget {
  const VentsIntentScreen({super.key});

  void _selectMode(BuildContext context, VentInteractionMode mode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateVentScreen(interactionMode: mode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Start a Vent')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'How do you want this Vent to be held?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              const Text(
                'Choose what can happen after you release it.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),
              _ModeCard(
                title: 'Just Listen',
                description: 'I want to be heard without opening a discussion.',
                onTap: () => _selectMode(
                  context,
                  VentInteractionMode.justListen,
                ),
              ),
              const SizedBox(height: 14),
              _ModeCard(
                title: 'Open Discussion',
                description: 'I am open to other Voices sharing their perspectives.',
                onTap: () => _selectMode(
                  context,
                  VentInteractionMode.openDiscussion,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $description',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(description, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
