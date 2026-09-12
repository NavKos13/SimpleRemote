import 'package:client/controllers/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

final themes = {
  ThemeMode.light: 'Light',
  ThemeMode.dark: 'Dark',
  ThemeMode.system: 'System',
};

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    required this.description,
    required this.trailingWidget,
  });

  final String title;
  final String description;
  final Widget trailingWidget;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.h4.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.muted.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          trailingWidget,
        ],
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.settingsController});

  final SettingsController settingsController;

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    
    ShadThemeData theme = ShadTheme.of(context);
    ShadBorder cardBorder = ShadBorder.all(
      color: theme.colorScheme.primaryForeground,
    );

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Settings', style: theme.textTheme.h3),
          leading: ShadIconButton.ghost(
            icon: Icon(LucideIcons.chevronLeft300),
            iconSize: 36,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
              child: Text(
                'TRACKPAD',
                style: theme.textTheme.h2.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            ShadCard(
              border: cardBorder,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
                children: [
                  _SettingsTile(
                    title: 'Natural Scrolling',
                    description: 'Scrolling tracks finger movement directly',
                    trailingWidget: ShadSwitch(
                      value: widget.settingsController.naturalScrolling,
                      onChanged: (v) =>
                          widget.settingsController.toggleNaturalScrolling(v),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: theme.colorScheme.border.withValues(alpha: 0.2),
                  ),
                  _SettingsTile(
                    title: 'Haptic Feedback',
                    description: 'Vibrate slightly on tap actions and clicks',
                    trailingWidget: ShadSwitch(
                      value: widget.settingsController.hapticsEnabled,
                      onChanged: (v) =>
                          widget.settingsController.toggleHapticsEnabled(v),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsetsGeometry.symmetric(
                horizontal: 4,
                vertical: 8,
              ),
              child: Text(
                'THEME CUSTOMIZATION',
                style: theme.textTheme.h2.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            ShadCard(
              border: cardBorder,
              padding: const EdgeInsetsGeometry.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              child: Column(
                children: [
                  _SettingsTile(
                    title: 'Theme Selection',
                    description: 'Light, dark, or follow system defaults',
                    trailingWidget: SizedBox(
                      width: 110,
                      child: ShadSelect<ThemeMode>(
                        initialValue: ThemeMode.dark,
                        options: [
                          ...themes.entries.map(
                            (e) =>
                                ShadOption(value: e.key, child: Text(e.value)),
                          ),
                        ],
                        selectedOptionBuilder: (context, value) =>
                            Text(themes[value]!),
                        onChanged: (value) {
                          widget.settingsController.updateThemeMode(value!);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // child: Column(
          //   children: [
          //     ShadCard(
          //       border: cardBorder,
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Column(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: [
          //               Text(
          //                 'Natural Scrolling',
          //                 style: ShadTheme.of(
          //                   context,
          //                 ).textTheme.h4.copyWith(fontSize: 16),
          //               ),
          //               Text(
          //                 'Content tracks finger movement directly',
          //                 style: ShadTheme.of(
          //                   context,
          //                 ).textTheme.blockquote.copyWith(fontSize: 12),
          //               ),
          //             ],
          //           ),
          //           ShadSwitch(
          //             value: widget.settingsController.naturalScrolling,
          //             onChanged: (v) =>
          //                 widget.settingsController.toggleNaturalScrolling(v),
          //           ),
          //         ],
          //       ),
          //     ),
          //     spacer,
          //     ShadCard(
          //       border: cardBorder,
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Column(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: [
          //               Text(
          //                 'Toggle Haptic Feedback',
          //                 style: theme.textTheme.h4.copyWith(fontSize: 16),
          //               ),
          //               Text(
          //                 'Vibrate on tap actions',
          //                 style: theme.textTheme.blockquote.copyWith(
          //                   fontSize: 12,
          //                 ),
          //               ),
          //             ],
          //           ),
          //           ShadSwitch(
          //             value: widget.settingsController.hapticsEnabled,
          //             onChanged: (v) =>
          //                 widget.settingsController.toggleHapticsEnabled(v),
          //           ),
          //         ],
          //       ),
          //     ),
          //     spacer,
          //     ShadCard(
          //       border: cardBorder,
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Column(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: [
          //               Text(
          //                 'Theme',
          //                 style: theme.textTheme.h4.copyWith(fontSize: 16),
          //               ),
          //               Text(
          //                 'Light, dark or system theme',
          //                 style: theme.textTheme.blockquote.copyWith(
          //                   fontSize: 12,
          //                 ),
          //               ),
          //             ],
          //           ),
          //           ShadSelect<ThemeMode>(
          //             initialValue: ThemeMode.dark,
          //             options: [
          //               ...themes.entries.map(
          //                 (e) =>
          //                     ShadOption(value: e.key, child: Text(e.value)),
          //               ),
          //             ],
          //             selectedOptionBuilder: (context, value) =>
          //                 Text(themes[value]!),
          //             onChanged: (value) {
          //               widget.settingsController.updateThemeMode(value!);
          //             },
          //           ),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
        ),
      ),
    );
  }
}
