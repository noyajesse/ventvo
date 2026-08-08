import 'package:flutter/material.dart';

import '../../ventvo_voice/models/vent.dart';
import '../../discussion/screen/discussion_screen.dart';

class VentCard extends StatefulWidget {
  final Vent vent;

  const VentCard({
    super.key,
    required this.vent,
  });

  @override
  State<VentCard> createState() => _VentCardState();
}

class _VentCardState extends State<VentCard> {
  bool heard = false;

  String spaceName() {
    if (widget.vent.responseIntent == "Just Listen") {
      return "🌊 Listening Space";
    }

    if (widget.vent.responseIntent == "Open Discussion") {
      return "💬 Open Discussion Space";
    }

    return "🌱 Open Space";
  }

  @override
  Widget build(BuildContext context) {
    final isJustListen =
        widget.vent.responseIntent == "Just Listen";

    return Container(
      margin: const EdgeInsets.only(
        bottom: 20,
      ),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Voice identity
          Text(
            "◇ ${widget.vent.voiceMark}",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          // The moment expressed
          Text(
            widget.vent.content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          // Space / response intent
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              spaceName(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(height: 22),

          const Divider(
            color: Colors.white12,
          ),

          const SizedBox(height: 14),

          // Interaction
          if (isJustListen) ...[
            const Text(
              "Just Listen",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    heard = !heard;
                  });
                },
                icon: Icon(
                  heard
                      ? Icons.check_circle_outline
                      : Icons.headphones_outlined,
                  size: 18,
                ),
                label: const Text(
                  "Heard",
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(
                    color: heard
                        ? Colors.white54
                        : Colors.white24,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ] else ...[
            // Open Discussion
            const Text(
              "Open Discussion",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiscussionScreen(
                        vent: widget.vent,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "Join Discussion",
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

