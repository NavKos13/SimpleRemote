import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SensitivitySlider extends StatelessWidget {
  final double currentValue;
  final ValueChanged<double> onChanged;

  const SensitivitySlider({
    super.key,
    required this.currentValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 8.0,
        activeTrackColor: theme.colorScheme.ring,
        inactiveTrackColor: theme.colorScheme.secondary,
        thumbColor: theme.colorScheme.primary,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14.0),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
      ),
      child: Slider(
        value: currentValue,
        min: 0,
        max: 10.0,
        onChanged: onChanged,
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return ShadSlider(
  //     initialValue: currentValue,
  //     min: 1.0,
  //     max: 10.0,
  //     onChanged: onChanged,
  //     thumbRadius: 15.0,
  //     trackHeight: 10.0,
  //   );
  // }
}
