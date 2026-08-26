import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../spaces/models/space.dart';
import '../../spaces/providers/space_provider.dart';
import '../../ventvo_voice/models/vent.dart';

class DiscussionScreen extends ConsumerStatefulWidget {
  final Vent vent;

  const DiscussionScreen({
    super.key,
    required this.vent,
  });

  @override
  ConsumerState<DiscussionScreen> createState() => _DiscussionScreenState();
}

class _DiscussionScreenState extends ConsumerState<DiscussionScreen> {
  final TextEditingController controller = TextEditingController();

  final List<String> responses = [
    'I understand what you mean.',
    "You don't have to figure everything out at once.",
  ];

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
    final spacesAsync = ref.watch(spaceProvider);
    final spaces = spacesAsync.asData?.value ?? const <Space>[];

    final space = spaces
        .where((item) => item.id == widget.vent.spaceId)
        .firstOrNull;

    final isOpenDiscussion = space?.isOpenDiscussion ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        title: const Text(
          'Open Discussion',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  '◇ ${widget.vent.voiceMark}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  widget.vent.content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Open Discussion',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Divider(
                  color: Colors.white12,
                ),
                const SizedBox(height: 20),
                Text(
                  isOpenDiscussion
                      ? 'Voices in the discussion'
                      : 'This Space is not open for discussion.',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isOpenDiscussion) ...[
                  const SizedBox(height: 15),
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isOpenDiscussion)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              color: const Color(0xFF111111),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Add your perspective...',
                        hintStyle: const TextStyle(
                          color: Colors.white38,
                        ),
                        filled: true,
                        fillColor: Colors.white10,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(22),
                          ),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: addResponse,
                    icon: const Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}