// Copyright (c) 2026 Rami YOUNES - MIT License
import 'package:flutter/material.dart';
import '../models/game.dart';
import '../theme/app_colors.dart';

typedef OnGameTap = void Function(Game game);

class GameTile extends StatelessWidget {
  final Game game;
  final OnGameTap onTap;

  const GameTile({required this.game, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth * 0.14;
    final fontSize = screenWidth * 0.045;

    return GestureDetector(
      onTap: () => onTap(game),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: screenWidth * 0.02, horizontal: screenWidth * 0.03),
        padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03, horizontal: screenWidth * 0.03),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10), // translucent tile
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            ClipOval(
              child: Image.asset(
                game.imageAsset,
                width: imageSize,
                height: imageSize,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: screenWidth * 0.04),
            Expanded(
              child: Text(
                game.title,
                style: TextStyle(
                  fontFamily: 'ChildstoneDemo',
                  color: AppColors.primaryText,
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white70, size: fontSize * 1.1),
          ],
        ),
      ),
    );
  }
}
