import 'dart:io';
import 'package:flutter/rendering.dart';

import '../models/remote_command.dart';

class TcpService {
  final String hostIp;
  final int port;
  Socket? _socket;
  bool _isConnected = false;

  TcpService({required this.hostIp, required this.port});

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    try {
      _socket = await Socket.connect(
        hostIp,
        port,
        timeout: const Duration(seconds: 5),
      );
      _isConnected = true;

      _socket!.listen(
        (_) {
          // No server response expected
        },
        onError: (error) {
          disconnect();
        },
        onDone: () {
          disconnect();
        },
        cancelOnError: true,
      );
    } catch (e) {
      _isConnected = false;
      rethrow;
    }
  }

  void sendCommand(RemoteCommand command) {
    if (_socket == null || !_isConnected) {
      debugPrint("socket is null or disconnected");
    }

    final String jsonStr = command.toJsonString();

    final String framedMessage = '$jsonStr\n';

    _socket!.write(framedMessage);
  }

  Future<void> disconnect() async {
    _isConnected = false;
    await _socket?.flush();
    await _socket?.close();
    _socket?.destroy();
    _socket = null;
  }
}
