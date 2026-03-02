// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Top bar shared across all game report screens.
/// Centered "Game Report" title with a home button on the left.
class ReportTopBar extends StatelessWidget {
  const ReportTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Text(
              'Game Report',
              style: TextStyle(
                fontSize: screenW * 0.06,
                fontFamily: 'ChildstoneDemo',
                color: AppColors.primaryText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            left: 0,
            child: IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
            ),
          ),
        ],
      ),
    );
  }
}
