import 'package:flutter/material.dart';

class ResonanceScreen extends StatelessWidget {
  const ResonanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resonance')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Find what connects.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Resonance is about meaningful relationships, not popularity.',
            style: TextStyle(color: Color(0xFFAAA8B8)),
          ),
          const SizedBox(height: 26),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.hub,
                    color: Color(0xFF5CD6E8),
                    size: 30,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your recent resonance',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Three people shared an experience that echoes yours.',
                    style: TextStyle(color: Color(0xFFAAA8B8)),
                  ),
                  const SizedBox(height: 18),
                  LinearProgressIndicator(
                    value: .72,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const _Insight(
            title: 'Threads',
            text: 'A chain of experiences growing around rest and recovery.',
            icon: Icons.account_tree_outlined,
          ),
          const SizedBox(height: 12),
          const _Insight(
            title: 'Maps',
            text: 'A wider pattern connecting personal stories and perspectives.',
            icon: Icons.scatter_plot_outlined,
          ),
          const SizedBox(height: 30),
          Center(
            child: Text(
              'No new connections right now.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFAAA8B8),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Insight extends StatelessWidget {
  final String title;
  final String text;
  final IconData icon;

  const _Insight({
    required this.title,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(text),
        ),
      ),
    );
  }
}
