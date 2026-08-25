import 'package:flutter/material.dart';

import '../../ventvo_voice/models/vent.dart';

class SpaceMomentCard extends StatelessWidget {
  final Vent vent;

  const SpaceMomentCard({
    super.key,
    required this.vent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        vent.content,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          height: 1.45,
        ),
      ),
    );
  }
}
