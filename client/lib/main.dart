import 'package:client/screens/connect_screen.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
    return ShadApp(
      title: 'SimpleRemote Client',
      darkTheme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadGreenColorScheme.dark(),
      ),
      themeMode: ThemeMode.dark,
      home: const ConnectScreen(),
    );
  }
}
