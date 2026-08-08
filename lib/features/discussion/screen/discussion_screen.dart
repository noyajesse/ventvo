import 'package:flutter/material.dart';

import '../../ventvo_voice/models/vent.dart';

class DiscussionScreen extends StatefulWidget {
  final Vent vent;

  const DiscussionScreen({
    super.key,
    required this.vent,
  });

  @override
  State<DiscussionScreen> createState() =>
      _DiscussionScreenState();
}

class _DiscussionScreenState
    extends State<DiscussionScreen> {
  final TextEditingController controller =
      TextEditingController();

  final List<String> responses = [
    "I understand what you mean.",
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
    return Scaffold(
      backgroundColor: const Color(0xFF111111),

      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,

        title: const Text(
          "Open Discussion",
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
                  "◇ ${widget.vent.voiceMark}",
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

                const SizedBox(height: 30),

                const Divider(
                  color: Colors.white12,
                ),

                const SizedBox(height: 20),

                const Text(
                  "Voices in the discussion",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                ...responses.map(
                  (response) {
                    return Container(
                      margin: const EdgeInsets.only(
                        bottom: 14,
                      ),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Text(
                        response,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(
              16,
              10,
              16,
              16,
            ),
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
                      hintText:
                          "Add your perspective...",

                      hintStyle:
                          const TextStyle(
                        color: Colors.white38,
                      ),

                      filled: true,
                      fillColor: Colors.white10,

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(22),
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