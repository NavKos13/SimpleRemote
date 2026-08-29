import 'package:client/models/remote_command.dart';
import 'package:client/services/udp_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TrackpadWidget extends StatefulWidget {
  final UdpService udpService;
  final double sensitivity;

  const TrackpadWidget({
    super.key,
    required this.udpService,
    required this.sensitivity,
  });

  @override
  State<StatefulWidget> createState() => _TrackpadWidgetState();
}

class _TrackpadWidgetState extends State<TrackpadWidget> {
  int _pointerCount = 0;
  bool _twoFingerTapCandidate = false;
  bool _longPress = false;

  void _sendRightClick() {
    debugPrint('Right click detected (two-finger tap)');

    final RemoteCommand command = MouseClickCommand(
      button: Button.right,
      direction: Direction.click,
    );
    widget.udpService.sendRemoteCommand(command);
  }

  void _sendLeftClick() {
    debugPrint('Left click detected');

    final RemoteCommand command = MouseClickCommand(
      button: Button.left,
      direction: Direction.click,
    );
    widget.udpService.sendRemoteCommand(command);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        _pointerCount++;
        if (_pointerCount == 2) {
          _twoFingerTapCandidate = true;
        } else if (_pointerCount > 2) {
          _twoFingerTapCandidate = false;
        }
      },

      onPointerUp: (PointerUpEvent event) {
        _pointerCount = (_pointerCount - 1).clamp(0, 10);

        if (_twoFingerTapCandidate && _pointerCount == 0) {
          _twoFingerTapCandidate = false;
          HapticFeedback.lightImpact();
          _sendRightClick();
        }
      },

      onPointerCancel: (_) {
        _pointerCount = 0;
        _twoFingerTapCandidate = false;
      },

      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (DragStartDetails details) {
          if (_pointerCount > 1) {
            _twoFingerTapCandidate = false;
          }
        },

        onPanUpdate: (DragUpdateDetails details) {
          _twoFingerTapCandidate = false;

          final double dx = details.delta.dx * widget.sensitivity;
          final double dy = details.delta.dy * widget.sensitivity;
          // debugPrint('Delta movement: dx=$dx, dy=$dy');

          final RemoteCommand command = MouseMoveCommand(dx: dx, dy: dy);
          widget.udpService.sendRemoteCommand(command);
        },

        onTap: () {
          HapticFeedback.heavyImpact();

          if (_longPress) {
            final RemoteCommand releaseCommand = MouseClickCommand(
              button: Button.left,
              direction: Direction.release,
            );
            widget.udpService.sendRemoteCommand(releaseCommand);
            _longPress = false;
          } else if (!_twoFingerTapCandidate) {
            _sendLeftClick();
          }
        },

        onLongPress: () {
          _longPress = true;
          HapticFeedback.lightImpact();

          debugPrint('Long press detected');
          final RemoteCommand pressCommand = MouseClickCommand(
            button: Button.left,
            direction: Direction.press,
          );
          widget.udpService.sendRemoteCommand(pressCommand);
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
