import 'package:client/controllers/settings_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.settingsController});

  final SettingsController settingsController;

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: ShadTheme.of(context).textTheme.h3),
        leading: ShadIconButton.ghost(
          icon: Icon(LucideIcons.chevronLeft300),
          iconSize: 36,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
