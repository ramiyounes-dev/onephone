// Copyright (c) 2026 Rami YOUNES - MIT License

import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'styled_button.dart';

typedef OnSettingsSelected = void Function(int timer);

class RoundSettingsPopup extends StatefulWidget {
  final int currentTimer;
  final String playerName;
  final OnSettingsSelected onSelected;

  const RoundSettingsPopup({
    required this.currentTimer,
    required this.playerName,
    required this.onSelected,
    super.key,
  });

  @override
  State<RoundSettingsPopup> createState() => _RoundSettingsPopupState();
}

class _RoundSettingsPopupState extends State<RoundSettingsPopup> {
  late int selectedTimer;

  @override
  void initState() {
    super.initState();
    selectedTimer = widget.currentTimer;
  }

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
              Text(
                'Next Round Settings',
                style: TextStyle(
                  fontFamily: 'ChildstoneDemo',
                  fontSize: screenWidth * 0.06,
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenWidth * 0.03),
              Text(
                'Player: ${widget.playerName}',
                style: TextStyle(color: Colors.white70, fontSize: screenWidth * 0.045),
              ),
              SizedBox(height: screenWidth * 0.03),

              // Timer slider
              Row(
                children: [
                  const Text('Timer:', style: TextStyle(color: Colors.white70)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Slider(
                      min: 30,
                      max: 300,
                      divisions: 270,
                      value: selectedTimer.toDouble(),
                      onChanged: (v) => setState(() => selectedTimer = v.toInt()),
                      activeColor: AppColors.goldDark,
                      thumbColor: AppColors.goldDark,
                      inactiveColor: AppColors.goldDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${selectedTimer}s',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              SizedBox(height: screenWidth * 0.04),

              SizedBox(
                width: double.infinity,
                child: StyledButton(
                  text: 'Start Next Round',
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onSelected(selectedTimer);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
