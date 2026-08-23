import 'package:flutter/material.dart';
import 'widgets/trackpad.dart';
import 'services/udp_service.dart';

const String serverIp = "192.168.1.196";
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
  late final UdpService _udpService;

  @override
  void initState() {
    super.initState;
    _udpService = UdpService(hostIp: serverIp, port: serverPort);
    _udpService.init();
  }

  @override
  void dispose() {
    _udpService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SimpleRemote Client',
      theme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(title: const Text('SimpleRemote')),
        body: Center(child: TrackpadWidget(udpService: _udpService)),
      ),
    );
  }
}

class TrackpadScreen extends StatelessWidget {
  const TrackpadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SimpleRemote Trackpad')),
      body: Center(
        child: TrackpadWidget(
          udpService: UdpService(hostIp: serverIp, port: serverPort),
        ),
      ),
    );
  }
}
