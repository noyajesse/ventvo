import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => CustomScrollView(slivers: [
        SliverAppBar(floating: true, title: const Text('Ventvo'), actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded))]),
        SliverPadding(padding: const EdgeInsets.fromLTRB(20, 18, 20, 100), sliver: SliverList(delegate: SliverChildListDelegate([
          Text('Good to see you, Nova.', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('What feels worth sharing today?', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: const Color(0xFFAAA8B8))),
          const SizedBox(height: 28),
          const _FilterRow(),
          const SizedBox(height: 22),
          const _VentCard(voice: 'quietly_becoming', mood: 'Overwhelmed', text: 'I am learning that resting is not falling behind. It is making room to keep going.', space: 'Just Listen', resonated: true),
          const SizedBox(height: 14),
          const _VentCard(voice: 'late_night_thinker', mood: 'Hopeful', text: 'Small progress still counts. Even when nobody else can see it yet.', space: 'Open Discussion'),
          const SizedBox(height: 28),
          Center(child: Text('You are all caught up for now.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFFAAA8B8)))),
        ])))
      ]);
}

class _FilterRow extends StatelessWidget { const _FilterRow(); @override Widget build(BuildContext context) => SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: ['For you', 'Recent', 'Just Listen', 'Open Discussion'].map((label) => Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(label), selected: label == 'For you', onSelected: (_) {}))).toList())); }

class _VentCard extends StatelessWidget {
  final String voice, mood, text, space; final bool resonated;
  const _VentCard({required this.voice, required this.mood, required this.text, required this.space, this.resonated = false});
  @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [const CircleAvatar(radius: 17, child: Icon(Icons.person_outline, size: 18)), const SizedBox(width: 10), Expanded(child: Text('@$voice', style: const TextStyle(fontWeight: FontWeight.w600))), Text(mood, style: const TextStyle(color: Color(0xFFAAA8B8), fontSize: 12))]),
    const SizedBox(height: 16), Text(text, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45)), const SizedBox(height: 14),
    Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withAlpha(35), borderRadius: BorderRadius.circular(20)), child: Text(space, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12))), const Spacer(), Icon(resonated ? Icons.favorite : Icons.favorite_border, size: 20, color: resonated ? Theme.of(context).colorScheme.secondary : null), const SizedBox(width: 6), const Text('Resonate')]),
  ])));
}
