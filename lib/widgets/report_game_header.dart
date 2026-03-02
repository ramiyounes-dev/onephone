// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:flutter/material.dart';

/// Game image + title row shown at the top of every report screen's content area.
class ReportGameHeader extends StatelessWidget {
  final String imagePath;
  final String gameName;

  const ReportGameHeader({
    required this.imagePath,
    required this.gameName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Image.asset(
          imagePath,
          width: screenW * 0.18,
          height: screenW * 0.18,
          fit: BoxFit.cover,
        ),
        const SizedBox(width: 12),
        Text(
          gameName,
          style: TextStyle(
            fontSize: screenW * 0.055,
            fontFamily: 'ChildstoneDemo',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
