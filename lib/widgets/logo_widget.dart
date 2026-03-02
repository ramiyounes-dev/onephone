// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double widthRatio; // % of screen width
  final double heightRatio; // % of screen height

  const LogoWidget({this.widthRatio = 0.3, this.heightRatio = 0.15, super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Image.asset(
      'assets/images/onephone-logo.png',
      width: screenWidth * widthRatio,
      height: screenHeight * heightRatio,
    );
  }
}
