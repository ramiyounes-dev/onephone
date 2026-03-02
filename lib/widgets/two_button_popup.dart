// Copyright (c) 2026 Rami YOUNES - MIT License

import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'styled_button.dart';

class TwoButtonPopup extends StatelessWidget {
  final String title;
  final String message;
  final String yesText;
  final String noText;

  const TwoButtonPopup({
    super.key,
    required this.title,
    required this.message,
    required this.yesText,
    required this.noText,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        insetPadding: const EdgeInsets.all(12),
        backgroundColor: Colors.white.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── TITLE ────────────────────────────────────────────────
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'ChildstoneDemo',
                  fontSize: screenWidth * 0.06,
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: screenWidth * 0.03),

              // ─── MESSAGE ───────────────────────────────────────────────
              Text(
                message,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: screenWidth * 0.042,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: screenWidth * 0.05),

              // ─── BUTTONS ROW (YES / NO) ───────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: StyledButton(
                      text: noText,
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: StyledButton(
                      text: yesText,
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
