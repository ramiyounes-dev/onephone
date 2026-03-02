// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A labeled slider with a gold value display.
/// Used across settings screens for timers, round counts, etc.
class LabeledSlider extends StatelessWidget {
  final String label;
  final String valueText;
  final double min;
  final double max;
  final double value;
  final int? divisions;
  final ValueChanged<double> onChanged;

  const LabeledSlider({
    required this.label,
    required this.valueText,
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
    this.divisions,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 24, color: Colors.white70),
        ),
        Center(
          child: Text(
            valueText,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: AppColors.goldDark,
            ),
          ),
        ),
        Slider(
          min: min,
          max: max,
          divisions: divisions,
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.goldDark,
          thumbColor: AppColors.goldDark,
          inactiveColor: AppColors.goldDark,
        ),
      ],
    );
  }
}
