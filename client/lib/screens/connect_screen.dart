import 'package:client/services/tcp_service.dart';
import 'package:nsd/nsd.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../services/udp_service.dart';
import 'trackpad_screen.dart';

const String serviceTypeDiscover = '_simpleremote._udp';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  Discovery? _discovery;
  String _status = "Scanning local network...";

  @override
  void initState() {
    super.initState();
    _startNetworkScan();
  }

  Future<void> _startNetworkScan() async {
    try {
      _discovery = await startDiscovery('_simpleremote._udp');

      _discovery!.addServiceListener((Service service, ServiceStatus status) {
        if (status == ServiceStatus.found) {
          final String? hostIp = service.host;
          final int? port = service.port;

          if (hostIp != null && port != null) {
            _handleServerFound(hostIp, port);
          }
        }
      });
    } catch (e) {
      setState(() {
        _status = "Discovery failed: $e";
      });
    }
  }

  Future<void> _handleServerFound(String ip, int port) async {
    await stopDiscovery(_discovery!);

    final udpService = UdpService(hostIp: ip, port: port);
    await udpService.init();

    final tcpService = TcpService(hostIp: ip, port: port);
    await tcpService.connect();

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TrackpadScreen(udpService: udpService, tcpService: tcpService),
      ),
    );
  }

  @override
  void dispose() {
    if (_discovery != null) stopDiscovery(_discovery!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShadIconButton(
              icon: SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ShadTheme.of(context).colorScheme.primaryForeground,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(_status, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
