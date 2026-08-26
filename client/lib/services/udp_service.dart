import 'dart:io';
import '../models/remote_command.dart';

class UdpService {
  final InternetAddress host;
  final int port;
  RawDatagramSocket? _socket;

  UdpService({required String hostIp, required this.port})
    : host = InternetAddress(hostIp);

  Future<void> init() async {
    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
  }

  void sendRemoteCommand(RemoteCommand command) {
    if (_socket == null) return;
    _socket!.send(command.toUtf8Bytes(), host, port);
  }

  void dispose() {
    _socket?.close();
  }
}
