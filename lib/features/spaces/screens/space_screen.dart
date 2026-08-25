import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ventvo_voice/providers/vent_provider.dart';
import '../models/space.dart';

class SpaceScreen extends ConsumerStatefulWidget {
  final Space space;

  const SpaceScreen({
    super.key,
    required this.space,
  });

  @override
  ConsumerState<SpaceScreen> createState() => _SpaceScreenState();
}

class _SpaceScreenState extends ConsumerState<SpaceScreen> {
  final TextEditingController controller = TextEditingController();
  final List<String> responses = [
    'I understand what you mean.',
    "You don't have to figure everything out at once.",
  ];
  bool heard = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void addResponse() {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      responses.add(text);
      controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ventsAsync = ref.watch(ventProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        title: Text(
          widget.space.modeLabel,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text('Unable to load this Space.', style: TextStyle(color: Colors.white70)),
        ),
        data: (vents) {
          final vent = vents.where((item) => item.id == widget.space.originatingVentId).firstOrNull;

          if (vent == null) {
            return const Center(
              child: Text('This Space is empty.', style: TextStyle(color: Colors.white54)),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      '◇ ${vent.voiceMark}',
                      style: const TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      vent.content,
                      style: const TextStyle(color: Colors.white, fontSize: 20, height: 1.5),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      widget.space.isJustListen ? 'Just Listen' : 'Open Discussion',
                      style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.space.isJustListen
                          ? 'No advice. No fixing. Just presence.'
                          : 'Share your perspective with the Voice who opened this Space.',
                      style: const TextStyle(color: Colors.white54, fontSize: 15, height: 1.4),
                    ),
                    const SizedBox(height: 26),
                    if (widget.space.isOpenDiscussion)
                      ...responses.map(
                        (response) => Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            response,
                            style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (widget.space.isJustListen)
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: heard ? null : () => setState(() => heard = true),
                        icon: Icon(heard ? Icons.check_circle_outline : Icons.headphones_outlined),
                        label: Text(heard ? 'Heard' : 'I’m listening'),
                      ),
                    ),
                  ),
                )
              else
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Add your perspective...',
                              hintStyle: const TextStyle(color: Colors.white38),
                              filled: true,
                              fillColor: Colors.white10,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          onPressed: addResponse,
                          icon: const Icon(Icons.arrow_upward, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
