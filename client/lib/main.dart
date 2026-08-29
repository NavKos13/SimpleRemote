import 'package:client/screens/connect_screen.dart';
import 'package:flutter/material.dart';
import 'widgets/trackpad.dart';
import 'services/udp_service.dart';

const String serverIp = "192.168.68.61";
const int serverPort = 8080;

void main() {
  runApp(const SimpleRemoteApp());
}

class SimpleRemoteApp extends StatefulWidget {
  const SimpleRemoteApp({super.key});

  @override
  State<StatefulWidget> createState() => _SimpleRemoteAppState();
}

class _SimpleRemoteAppState extends State<SimpleRemoteApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SimpleRemote Client',
      theme: ThemeData.dark(),
      // home: TrackpadScreen(udpService: _udpService),
      home: const ConnectScreen(),
    );
  }
}

class TrackpadScreen extends StatefulWidget {
  final UdpService udpService;
  const TrackpadScreen({super.key, required this.udpService});

  @override
  State<TrackpadScreen> createState() => _TrackpadScreenState();
}

class _TrackpadScreenState extends State<TrackpadScreen> {
  double _sensitivity = 2.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SimpleRemote Trackpad')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TrackpadWidget(
            udpService: widget.udpService,
            sensitivity: _sensitivity,
          ),
          SensitivitySlider(
            currentValue: _sensitivity,
            onChanged: (newValue) {
              setState(() {
                _sensitivity = newValue;
              });
            },
          ),
        ],
      ),
    );
  }
}
