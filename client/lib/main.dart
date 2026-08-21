import 'package:flutter/material.dart';
import 'widgets/trackpad.dart';

void main() {
  runApp(const SimpleRemoteApp());
}

class SimpleRemoteApp extends StatelessWidget {
  const SimpleRemoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SimpleRemote Client',
      theme: ThemeData.dark(),
      home: const TrackpadScreen(),
    );
  }
}

class TrackpadScreen extends StatelessWidget {
  const TrackpadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SimpleRemote Trackpad')),
      body: const Center(child: TrackpadWidget()),
    );
  }
}
