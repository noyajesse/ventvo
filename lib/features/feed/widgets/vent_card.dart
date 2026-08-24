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
    if (widget.vent.isJustListen) {
      return '🌊 Listening Space';
    }

    if (widget.vent.isOpenDiscussion) {
      return '💬 Open Discussion Space';
    }

    return '🌱 Open Space';
  }

  void _acknowledgeListening() {
    if (heard) return;

    setState(() {
      heard = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isJustListen = widget.vent.isJustListen;
    final voiceName = widget.vent.voiceName?.trim();
    final identity = voiceName == null || voiceName.isEmpty
        ? 'Voice'
        : voiceName;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.vent.voiceMark,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 22,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                identity,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            widget.vent.content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
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
          const Divider(color: Colors.white12),
          const SizedBox(height: 14),
          if (isJustListen) ...[
            Text(
              heard
                  ? 'You showed up. That is enough.'
                  : 'No advice. No fixing. Just listen.',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: heard ? null : _acknowledgeListening,
                icon: Icon(
                  heard
                      ? Icons.check_circle_outline
                      : Icons.headphones_outlined,
                  size: 18,
                ),
                label: Text(
                  heard ? 'Heard' : 'I’m listening',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white54,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ] else if (widget.vent.isOpenDiscussion) ...[
            const Text(
              Vent.openDiscussion,
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
                child: const Text('Join Discussion'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
