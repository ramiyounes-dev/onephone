// Copyright (c) 2026 Rami YOUNES - MIT License

import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/styled_button.dart';

typedef OnLanguageSelected = void Function(String languageCode);

class LanguagePopup extends StatelessWidget {
  final String selectedLanguage;
  final OnLanguageSelected onSelected;

  const LanguagePopup({
    required this.selectedLanguage,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Dialog(
        insetPadding: const EdgeInsets.all(12),
        backgroundColor: Colors.white.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Language',
                style: TextStyle(
                  fontFamily: 'ChildstoneDemo',
                  fontSize: screenWidth * 0.06,
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: screenWidth * 0.04),

              _languageButton(
                context,
                label: 'English',
                code: 'en',
                screenWidth: screenWidth,
              ),
              SizedBox(height: screenWidth * 0.02),

              _languageButton(
                context,
                label: 'Français',
                code: 'fr',
                screenWidth: screenWidth,
              ),
              SizedBox(height: screenWidth * 0.02),

              _languageButton(
                context,
                label: 'العربية',
                code: 'ar',
                screenWidth: screenWidth,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _languageButton(
    BuildContext context, {
    required String label,
    required String code,
    required double screenWidth,
  }) {
    final bool isSelected = selectedLanguage == code;

    return SizedBox(
      width: double.infinity,
      child: StyledButton(
        text: isSelected ? '* $label' : label,
        onPressed: () {
          onSelected(code);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
