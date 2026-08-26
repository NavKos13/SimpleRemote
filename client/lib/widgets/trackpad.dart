import 'package:client/models/remote_command.dart';
import 'package:client/services/udp_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TrackpadWidget extends StatefulWidget {
  final UdpService udpService;
  final double sensitivity;

  TrackpadWidget({
    super.key,
    required this.udpService,
    required this.sensitivity,
  });

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
      },
      onPanUpdate: (DragUpdateDetails details) {
        final double dx = details.delta.dx * widget.sensitivity;
        final double dy = details.delta.dy * widget.sensitivity;
        debugPrint('Delta movement: dx=$dx, dy=$dy');

        final RemoteCommand command = MouseMoveCommand(dx: dx, dy: dy);
        widget.udpService.sendRemoteCommand(command);
      },
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blueAccent, width: 2),
        ),
      ),
    );
  }
}

class SensitivitySlider extends StatelessWidget {
  final double currentValue;
  final ValueChanged<double> onChanged;

  const SensitivitySlider({
    super.key,
    required this.currentValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: currentValue,
      min: 1.0,
      max: 10.0,
      onChanged: onChanged,
    );
  }
}
