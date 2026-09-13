import 'dart:io';

import 'package:client/controllers/settings_controller.dart';
import 'package:client/screens/settings_screen.dart';
import 'package:client/services/tcp_service.dart';
import 'package:nsd/nsd.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../services/udp_service.dart';
import 'trackpad_screen.dart';

const String serviceTypeDiscover = '_simpleremote._udp';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key, required this.settingsController});

  final SettingsController settingsController;

  @override
  State<StatefulWidget> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  Discovery? _discovery;
  final List<Service> _discoveredDevices = [];
  bool _isScanning = false;
  final TextEditingController _ipController = TextEditingController();

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
    FocusManager.instance.primaryFocus?.unfocus();

    if (_discovery != null) await _safeStopDiscovery();

    final udpService = UdpService(hostIp: ip, port: port);
    await udpService.init();

    final tcpService = TcpService(hostIp: ip, port: port);
    try {
      await tcpService.connect();
    } catch (e) {
      udpService.dispose();
      rethrow;
    }

    if (!mounted) return;
    await Navigator.push(
      context,
      ShadDialogRoute(
        pageBuilder: (context) => TrackpadScreen(
          udpService: udpService,
          tcpService: tcpService,
          settingsController: widget.settingsController,
        ),
      ),
    );
  }

  Future<void> _safeStopDiscovery() async {
    final discovery = _discovery;
    _discovery = null;

    if (discovery != null) {
      try {
        await stopDiscovery(discovery);
      } catch (e) {
        debugPrint("ignored stopDiscovery error: $e");
      }
    }
  }

  @override
  void dispose() {
    if (_discovery != null) _safeStopDiscovery();
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
                  style: theme.textTheme.large.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(ip, style: theme.textTheme.muted),
              ],
            ),
          ),
          SizedBox(width: 4),
          ShadButton(
            size: ShadButtonSize.sm,
            child: const Text('CONNECT'),
            onPressed: () async {
              try {
                await _connectToServer(ip, port);
              } on SocketException catch (e) {
                if (!context.mounted) return;

                ShadToaster.of(context).show(
                  ShadToast.destructive(
                    title: const Text("Couldn't connect to server..."),
                    description: Text('Error: $e'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
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
                            border: Border.all(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          child: Icon(
                            LucideIcons.smartphoneNfc,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SimpleRemote', style: theme.textTheme.h4),
                            // Text(
                            //   'Desktop Link',
                            //   style: theme.textTheme.small.copyWith(
                            //     color: theme.colorScheme.secondary,
                            //     fontSize: 10,
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                    if (_isScanning)
                      ShadBadge.secondary(
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
                      )
                    else
                      ShadBadge(
                        backgroundColor: Colors.grey,
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('SCANNING'),
                          ],
                        ),
                      ),
                    ShadIconButton.ghost(
                      icon: Icon(LucideIcons.settings),
                      onPressed: () async {
                        await Navigator.of(context).push(
                          ShadDialogRoute(
                            pageBuilder: (context) => SettingsScreen(
                              settingsController: widget.settingsController,
                            ),
                          ),
                        );
                      },
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
                  child: RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        _discoveredDevices.clear();
                        _isScanning = false;
                      });
                      await _safeStopDiscovery();

                      await _startNetworkScan();

                      await Future.delayed(const Duration(milliseconds: 1000));
                    },
                    child: _discoveredDevices.isEmpty
                        ? LayoutBuilder(
                            builder: (context, constraints) =>
                                SingleChildScrollView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: constraints.maxHeight,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Searching for local servers...',
                                        style: theme.textTheme.muted,
                                      ),
                                    ),
                                  ),
                                ),
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _discoveredDevices.length,
                            itemBuilder: (context, index) {
                              return _buildDeviceCard(
                                _discoveredDevices[index],
                                theme,
                              );
                            },
                          ),
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
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ShadIconButton(
                            icon: Icon(LucideIcons.moveRight),
                            onPressed: () {
                              if (_ipController.text.isNotEmpty) {
                                _connectToServer(
                                  _ipController.text.trim(),
                                  8080,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
