import 'package:flutter/material.dart';

class CreateCrashoutScreen extends StatefulWidget { const CreateCrashoutScreen({super.key}); @override State<CreateCrashoutScreen> createState() => _CreateCrashoutScreenState(); }
class _CreateCrashoutScreenState extends State<CreateCrashoutScreen> {
  final controller = TextEditingController(); String mode = 'Just Listen'; String mood = 'Thinking';
  @override void dispose() { controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Create a Crash Out'), actions: [TextButton(onPressed: controller.text.trim().isEmpty ? null : () => Navigator.pop(context), child: const Text('Post'))]), body: ListView(padding: const EdgeInsets.all(20), children: [
    Text('Let it out.', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 8), const Text('Share only what feels right. You are in control.', style: TextStyle(color: Color(0xFFAAA8B8))), const SizedBox(height: 24),
    TextField(controller: controller, maxLines: 8, onChanged: (_) => setState(() {}), autofocus: true, decoration: const InputDecoration(hintText: 'What is on your mind?')),
    const SizedBox(height: 24), const Text('How do you feel?', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 10), Wrap(spacing: 8, children: ['Thinking', 'Stressed', 'Sad', 'Hopeful', 'Angry'].map((value) => ChoiceChip(label: Text(value), selected: mood == value, onSelected: (_) => setState(() => mood = value))).toList()),
    const SizedBox(height: 24), const Text('Choose your Space', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 10), SegmentedButton<String>(segments: const [ButtonSegment(value: 'Just Listen', label: Text('Just Listen'), icon: Icon(Icons.hearing)), ButtonSegment(value: 'Open Discussion', label: Text('Open Discussion'), icon: Icon(Icons.chat_bubble_outline))], selected: {mode}, onSelectionChanged: (values) => setState(() => mode = values.first)),
    const SizedBox(height: 20), Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white.withAlpha(8), borderRadius: BorderRadius.circular(14)), child: const Row(children: [Icon(Icons.lock_outline, size: 18), SizedBox(width: 10), Expanded(child: Text('Your private details are never shown with your public Voice.'))])),
  ]));
}
