import 'package:flutter/material.dart';

class VentsIntentScreen extends StatelessWidget {
  const VentsIntentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const SizedBox(height: 40),

                const Text(
                  'What do you need right now?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  'Choose the kind of response you are hoping for.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 40),

                _IntentCard(
                  title: '🎧 Just Listen',
                  description: 'I just need someone to hear me.',
                ),

                _IntentCard(
                  title: '💡 Advice',
                  description: 'I need honest advice or practical suggestions.',
                ),

                _IntentCard(
                  title: '🌍 Similar Experiences',
                  description:
                      'I want to hear from people who have been through something similar.',
                ),

                _IntentCard(
                  title: '🌱 Encouragement',
                  description:
                      'A few kind words could really help right now.',
                ),

                _IntentCard(
                  title: '🎉 Celebrating',
                  description:
                      'I want to share something good with others.',
                ),

                const SizedBox(height: 40),

              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _IntentCard extends StatelessWidget {
  final String title;
  final String description;

  const _IntentCard({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),

        ],
      ),
    );
  }
}