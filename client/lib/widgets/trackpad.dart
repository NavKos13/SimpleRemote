import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TrackpadWidget extends StatefulWidget {
  const TrackpadWidget({super.key});

  @override
  State<StatefulWidget> createState() => _TrackpadWidgetState();
}

class _TrackpadWidgetState extends State<TrackpadWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (DragStartDetails details) {
        // 1. Log or track the starting position
        debugPrint('Pan started at local: ${details.localPosition}');
        debugPrint('Pan started at global: ${details.globalPosition}');

        // TODO 2. Initialize tracking variables or gesture state if needed
        // (e.g., ressetting momentum timers or flagging an active drag)
      },
      onPanUpdate: (DragUpdateDetails details) {
        final double dx = details.delta.dx;
        final double dy = details.delta.dy;
        debugPrint('Delta movement: dx=$dx, dy=$dy');

        // TODO: Do the necessary calculations and send the appropriate command to the server
      },
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blueAccent, width: 2),
        ),
      ),
    );
  }
}
