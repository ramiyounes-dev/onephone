// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Shared text styles used across report screens.
class AppTextStyles {
  static TextStyle sectionTitle(double size) => TextStyle(
        fontFamily: 'ChildstoneDemo',
        fontSize: size,
        color: AppColors.goldDark,
        fontWeight: FontWeight.bold,
      );

  static TextStyle contentText(
    double size, {
    Color color = Colors.white70,
    bool bold = false,
  }) =>
      TextStyle(
        fontFamily: 'ChildstoneDemo',
        fontSize: size,
        color: color,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      );
}
