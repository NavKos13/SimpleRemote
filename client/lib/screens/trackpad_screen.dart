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
      side: ShadSheetSide.top,
      context: context,
      builder: (context) => RemoteKeyboardSheet(tcpService: widget.tcpService),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SimpleRemote',
          style: TextStyle(fontFamily: 'FiraSans', fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: TrackpadWidget(
                  udpService: widget.udpService,
                  sensitivity: _sensitivity,
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Text(
                    'Sensitivity',
                    style: theme.textTheme.muted.copyWith(fontSize: 12),
                  ),
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
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShadIconButton(
                    icon: Icon(Icons.keyboard),
                    onPressed: _openKeyboardSheet,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
