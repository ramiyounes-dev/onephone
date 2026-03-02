// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Section header for category lists with a "Select All" toggle switch.
/// Used in Charades and Would You Rather settings screens.
class CategoryHeader extends StatelessWidget {
  final String title;
  final String toggleLabel;
  final bool selectAll;
  final ValueChanged<bool> onToggleAll;

  const CategoryHeader({
    required this.selectAll,
    required this.onToggleAll,
    this.title = 'Categories',
    this.toggleLabel = 'All',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 24, color: Colors.white70),
        ),
        Row(
          children: [
            Text(toggleLabel, style: const TextStyle(color: Colors.white70)),
            Switch(
              value: selectAll,
              onChanged: onToggleAll,
              activeThumbColor: AppColors.goldDark,
              activeTrackColor: AppColors.goldDark.withValues(alpha: 0.3),
            ),
          ],
        ),
      ],
    );
  }
}
