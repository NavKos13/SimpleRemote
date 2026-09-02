import 'package:client/models/remote_command.dart';
import 'package:client/services/udp_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart' hide Direction;

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
  double _scrollAccumulatorX = 0.0;
  double _scrollAccumulatorY = 0.0;
  static const double _scrollSensitivity = 0.08;

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
    final theme = ShadTheme.of(context);
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

      child: ShadCard(
        padding: EdgeInsets.zero,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,

          onScaleStart: (ScaleStartDetails details) {
            _scrollAccumulatorX = 0.0;
            _scrollAccumulatorY = 0.0;
            if (_pointerCount > 1) {
              _twoFingerTapCandidate = false;
            }
          },

          onScaleUpdate: (ScaleUpdateDetails details) {
            _twoFingerTapCandidate = false;

            if (details.pointerCount == 1) {
              final double dx = details.focalPointDelta.dx * widget.sensitivity;
              final double dy = details.focalPointDelta.dy * widget.sensitivity;
              widget.udpService.sendRemoteCommand(
                MouseMoveCommand(dx: dx, dy: dy),
              );
            } else if (details.pointerCount == 2) {
              _scrollAccumulatorX +=
                  -details.focalPointDelta.dx * _scrollSensitivity;
              _scrollAccumulatorY +=
                  -details.focalPointDelta.dy * _scrollSensitivity;

              final int stepX = _scrollAccumulatorX.truncate();
              final int stepY = _scrollAccumulatorY.truncate();

              if (stepX != 0 || stepY != 0) {
                _scrollAccumulatorX -= stepX;
                _scrollAccumulatorY -= stepY;

                widget.udpService.sendRemoteCommand(
                  MouseScrollCommand(
                    scrollX: stepX.toDouble(),
                    scrollY: stepY.toDouble(),
                  ),
                );
              }
            }
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

          child: SizedBox.expand(
            child: Center(
              child: Text(
                '''
Drag to move mouse\n
Tap with one finger to left-click\n
Tap with two fingers to right-click\n
Drag with two fingers to scroll\n
Long press to hold down L-click\n
Tap once to release L-click
                ''',
                style: theme.textTheme.small.copyWith(fontFamily: 'FiraSans'),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Container(
          //   width: double.infinity,
          //   height: double.infinity,
          //   margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
          //   decoration: BoxDecoration(
          //     color: Colors.grey[850],
          //     borderRadius: BorderRadius.circular(12),
          //     border: Border.all(color: Colors.blueAccent, width: 2),
          //   ),
          // ),
        ),
      ),
    );
  }
}
