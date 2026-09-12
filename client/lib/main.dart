import 'package:client/controllers/settings_controller.dart';
import 'package:client/screens/connect_screen.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:google_fonts/google_fonts.dart';

const String serverIp = "192.168.68.61";
const int serverPort = 8080;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settingsController = SettingsController();
  await settingsController.init();

  runApp(SimpleRemoteApp(settingsController: settingsController));
}

class SimpleRemoteApp extends StatefulWidget {
  const SimpleRemoteApp({super.key, required this.settingsController});

  final SettingsController settingsController;
  @override
  State<StatefulWidget> createState() => _SimpleRemoteAppState();
}

class _SimpleRemoteAppState extends State<SimpleRemoteApp> {
  @override
  Widget build(BuildContext context) {
    final firaSansTextTheme = ShadTextTheme.fromGoogleFont(
      GoogleFonts.firaSans,
    );
    return ListenableBuilder(
      listenable: widget.settingsController,
      builder: (context, child) {
        return ShadApp(
          title: 'SimpleRemote Client',
          theme: ShadThemeData(
            brightness: Brightness.light,
            colorScheme: const ShadGreenColorScheme.light(),
            textTheme: firaSansTextTheme,
          ),
          darkTheme: ShadThemeData(
            brightness: Brightness.dark,
            colorScheme: const ShadGreenColorScheme.dark(),
            textTheme: firaSansTextTheme,
          ),
          themeMode: widget.settingsController.themeMode,
          home: ConnectScreen(settingsController: widget.settingsController),
        );
      },
    );
  }
}
