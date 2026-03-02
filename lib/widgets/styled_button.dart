// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StyledButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double widthRatio;
  final double heightRatio;
  final double fontRatio;
  final double borderRadiusRatio;
  final double elevation;
  final Color? color;
  final bool autoSize;

  const StyledButton({
    required this.text,
    this.onPressed,
    this.widthRatio = 0.8,
    this.heightRatio = 0.08,
    this.fontRatio = 0.05,
    this.borderRadiusRatio = 0.02,
    this.elevation = 5,
    this.color,
    this.autoSize = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: screenWidth * widthRatio,
      height: screenHeight * heightRatio,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? const Color.fromARGB(255, 255, 196, 0),
          textStyle: TextStyle(
            fontSize: screenWidth * fontRatio,
            fontFamily: 'ChildstoneDemo',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              screenWidth * borderRadiusRatio,
            ),
          ),
          elevation: elevation,
          shadowColor: Colors.black.withValues(alpha: 0.3),
        ),
        onPressed: onPressed == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed!();
              },
        child: autoSize
            ? AutoSizeText(
                text,
                maxLines: 1,
                minFontSize: 8,
                textAlign: TextAlign.center,
              )
            : Text(text),
      ),
    );
  }
}
