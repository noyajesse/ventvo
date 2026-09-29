import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/crash_out.dart';
import '../models/crash_out_reflection.dart';
import '../models/experience_thread.dart';
import '../providers/crash_out_reflection_provider.dart';

class CrashOutReflectionScreen extends ConsumerStatefulWidget {
  final CrashOut crashOut;
  final ExperienceThread thread;

  const CrashOutReflectionScreen({
    super.key,
    required this.crashOut,
    required this.thread,
  });

  @override
  ConsumerState<CrashOutReflectionScreen> createState() =>
      _CrashOutReflectionScreenState();
}

class _CrashOutReflectionScreenState
    extends ConsumerState<CrashOutReflectionScreen> {
  final TextEditingController _controller = TextEditingController();

  bool get _hasText => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    final reflection = CrashOutReflection(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      crashOutId: widget.crashOut.id,
      threadId: widget.thread.id,
      content: content,
      createdAt: DateTime.now(),
    );

    await ref
        .read(crashOutReflectionProvider.notifier)
        .addReflection(reflection);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E0E0E),
        elevation: 0,
        title: const Text(
          'Reflect',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What did seeing another side make you think about?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'You do not have to explain it perfectly. This stays private.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Write whatever came up...',
                    hintStyle: const TextStyle(color: Colors.white30),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.055),
                    contentPadding: const EdgeInsets.all(18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _hasText ? _save : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.white12,
                    disabledForegroundColor: Colors.white24,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Save reflection'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
