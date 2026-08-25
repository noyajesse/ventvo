import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../spaces/providers/space_provider.dart';
import '../../spaces/screens/space_screen.dart';
import '../../ventvo_voice/models/vent.dart';

class VentCard extends ConsumerStatefulWidget {
  final Vent vent;

  const VentCard({
    super.key,
    required this.vent,
  });

  @override
  ConsumerState<VentCard> createState() => _VentCardState();
}

class _VentCardState extends ConsumerState<VentCard> {
  bool heard = false;

  @override
  Widget build(BuildContext context) {
    final spaces = ref.watch(spaceProvider);
    final space = spaces.where((item) => item.id == widget.vent.spaceId).firstOrNull;
    final isJustListen = space?.isJustListen ?? false;
    final isOpenDiscussion = space?.isOpenDiscussion ?? false;
    final voiceName = widget.vent.voiceName?.trim();
    final identity = voiceName == null || voiceName.isEmpty ? 'Voice' : voiceName;

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
              Text(widget.vent.voiceMark, style: const TextStyle(color: Colors.white70, fontSize: 22)),
              const SizedBox(width: 10),
              Text(identity, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 18),
          Text(widget.vent.content, style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.4)),
          const SizedBox(height: 20),
          if (space != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(20)),
              child: Text(
                isJustListen ? '🌊 Just Listen Space' : '💬 Open Discussion Space',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          const SizedBox(height: 22),
          const Divider(color: Colors.white12),
          const SizedBox(height: 14),
          if (isJustListen) ...[
            Text(
              heard ? 'You showed up. That is enough.' : 'No advice. No fixing. Just listen.',
              style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: heard ? null : () => setState(() => heard = true),
                icon: Icon(heard ? Icons.check_circle_outline : Icons.headphones_outlined, size: 18),
                label: Text(heard ? 'Heard' : 'I’m listening'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white54,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
              ),
            ),
          ] else if (isOpenDiscussion) ...[
            const Text(
              'Open Discussion',
              style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: space == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SpaceScreen(space: space),
                          ),
                        );
                      },
                child: const Text('Enter Space'),
              ),
            ),
          ] else ...[
            const Text(
              'This Space is unavailable in the current session.',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}
