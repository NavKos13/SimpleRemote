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
  final List<Service> _discoveredDevices = [];
  final TextEditingController _ipController = TextEditingController();
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _startNetworkScan();
  }

  Future<void> _startNetworkScan() async {
    setState(() {
      _isScanning = true;
    });
    try {
      _discovery = await startDiscovery('_simpleremote._udp');

      _discovery!.addServiceListener((Service service, ServiceStatus status) {
        if (status == ServiceStatus.found) {
          setState(() {
            if (!_discoveredDevices.any((d) => d.name == service.name)) {
              _discoveredDevices.add(service);
            }
          });
        } else if (status == ServiceStatus.lost) {
          setState(() {
            _discoveredDevices.removeWhere((d) => d.name == service.name);
          });
        }
      });
    } catch (e) {
      debugPrint("Discovery failed: $e");
    }
  }

  Future<void> _connectToServer(String ip, int port) async {
    if (_discovery != null) await stopDiscovery(_discovery!);

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
    _ipController.dispose();
    super.dispose();
  }

  Widget _buildDeviceCard(Service service, ShadThemeData theme) {
    final ip = service.host ?? 'Unknown IP';
    final port = service.port ?? 8080;

    return ShadCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(LucideIcons.computer, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name ?? 'Unknown Device',
                  style: theme.textTheme.large.copyWith(fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(ip, style: theme.textTheme.muted),
              ],
            ),
          ),
          ShadButton(
            size: ShadButtonSize.sm,
            child: const Text('CONNECT'),
            onPressed: () => _connectToServer(ip, port),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withAlpha(50),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.colorScheme.primary),
                        ),
                        child: Icon(
                          LucideIcons.wifiCog,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SimpleRemote', style: theme.textTheme.h4),
                          Text(
                            'Desktop Link',
                            style: theme.textTheme.small.copyWith(
                              color: theme.colorScheme.secondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (_isScanning)
                    ShadBadge.outline(
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.greenAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text('SCANNING'),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              // Device List section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DETECTED COMPUTERS',
                    style: theme.textTheme.muted.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_discoveredDevices.length} Found',
                    style: theme.textTheme.muted,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _discoveredDevices.isEmpty
                    ? Center(
                        child: Text(
                          'Searching for local servers...',
                          style: theme.textTheme.muted,
                        ),
                      )
                    : ListView.builder(
                        itemCount: _discoveredDevices.length,
                        itemBuilder: (context, index) {
                          return _buildDeviceCard(
                            _discoveredDevices[index],
                            theme,
                          );
                        },
                      ),
              ),
              // Manual Ip section
              const SizedBox(height: 16),
              ShadCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connect via IP Address',
                      style: theme.textTheme.small.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ShadInput(
                            controller: _ipController,
                            placeholder: const Text('192.168.1.'),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ShadIconButton(
                          icon: Icon(LucideIcons.moveRight),
                          onPressed: () {
                            if (_ipController.text.isNotEmpty) {
                              _connectToServer(_ipController.text.trim(), 8080);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Footer
              Center(
                child: Column(
                  children: [
                    Text(
                      'SECURE ENCRYPTED WEBSOCKET CONNECTION',
                      style: theme.textTheme.muted.copyWith(fontSize: 10),
                    ),
                    Text(
                      'v1.4.2 stable',
                      style: theme.textTheme.muted.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

    // return Padding(
    //   padding: const EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 14.0),
    //   child: Scaffold(
    //     appBar: AppBar(
    //       title: Text(
    //         'SimpleRemote',
    //         style: ShadTheme.of(context).textTheme.h3,
    //       ),
    //       leading: Padding(
    //         padding: const EdgeInsets.all(6.0),
    //         child: ShadIconButton(icon: Icon(LucideIcons.rocket)),
    //       ),
    //       actions: [
    //         ShadIconButton.ghost(
    //           icon: Icon(Icons.settings),
    //           onPressed: () {
    //             // TODO: handle settings screen
    //             // Navigator.of(context).push
    //           },
    //         ),
    //       ],
    //     ),
    //     body: Sliver(
    //       child: Column(

    //       ),
    //     ),
    //   ),
    // );
    // return Scaffold(
    //   body: Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: [
    //         ShadIconButton(
    //           icon: SizedBox.square(
    //             dimension: 16,
    //             child: CircularProgressIndicator(
    //               strokeWidth: 2,
    //               color: ShadTheme.of(context).colorScheme.primaryForeground,
    //             ),
    //           ),
    //         ),
    //         const SizedBox(height: 20),
    //         Text(_status, style: const TextStyle(color: Colors.white70)),
    //       ],
    //     ),
    //   ),
    // );
