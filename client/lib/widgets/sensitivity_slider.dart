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
    return ShadSlider(
      initialValue: currentValue,
      min: 1.0,
      max: 10.0,
      onChanged: onChanged,
      thumbRadius: 15.0,
      trackHeight: 10.0,
    );
  }
}
