import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../services/tcp_service.dart';
import '../services/udp_service.dart';
import '../widgets/keyboard_sheet.dart';
import '../widgets/sensitivity_slider.dart';
import '../widgets/trackpad.dart';

class TrackpadScreen extends StatefulWidget {
  final UdpService udpService;
  final TcpService tcpService;
  const TrackpadScreen({
    super.key,
    required this.udpService,
    required this.tcpService,
  });

  @override
  State<TrackpadScreen> createState() => _TrackpadScreenState();
}

class _TrackpadScreenState extends State<TrackpadScreen> {
  double _sensitivity = 2.0;

  void _openKeyboardSheet() {
    showShadSheet(
      side: ShadSheetSide.bottom,
      context: context,
      builder: (context) => RemoteKeyboardSheet(tcpService: widget.tcpService),
    );
  }

  @override
  void dispose() {
    widget.tcpService.disconnect();
    widget.udpService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 36,
          titleSpacing: 12,
          leading: ShadIconButton.ghost(
            icon: Icon(LucideIcons.chevronLeft300),
            iconSize: 36,
            onPressed: () async {
              await widget.tcpService.disconnect();
              widget.udpService.dispose();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text('SimpleRemote', style: theme.textTheme.h2),
        ),
        persistentFooterButtons: [
          ShadIconButton(
            icon: Icon(LucideIcons.keyboard),
            onPressed: _openKeyboardSheet,
          ),
        ],
        persistentFooterAlignment: AlignmentDirectional.topCenter,
        persistentFooterDecoration: BoxDecoration(),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TrackpadWidget(
                  udpService: widget.udpService,
                  sensitivity: _sensitivity,
                ),
              ),
              const SizedBox(height: 16),
              const ShadSeparator.horizontal(
                thickness: 4,
                margin: EdgeInsets.symmetric(horizontal: 0),
                radius: BorderRadius.all(Radius.circular(4)),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Sensitivity:',
                    style: theme.textTheme.small.copyWith(fontSize: 12),
                  ),
                  SizedBox(width: 6),
                  Text(
                    _sensitivity.toStringAsFixed(1),
                    style: theme.textTheme.small.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              SensitivitySlider(
                currentValue: _sensitivity,
                onChanged: (newValue) {
                  setState(() {
                    _sensitivity = newValue;
                  });
                },
              ),
              const SizedBox(height: 10.0),
            ],
          ),
        ),
      ),
    );
  }
}
