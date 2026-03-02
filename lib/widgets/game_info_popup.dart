// Copyright (c) 2026 Rami YOUNES - MIT License
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/game.dart';
import '../theme/app_colors.dart';
import '../widgets/styled_button.dart';

typedef OnPlayPressed = void Function(Game game);

class GameInfoPopup extends StatelessWidget {
  final Game game;
  final OnPlayPressed onPlay;

  const GameInfoPopup({required this.game, required this.onPlay, super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = screenWidth * 0.26;
    final titleSize = screenWidth * 0.06;

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
              // top row: image left, title/right
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      game.imageAsset,
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.title,
                          style: TextStyle(
                            fontFamily: 'ChildstoneDemo',
                            fontSize: titleSize,
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.01),
                        Text(
                          'Min players: ${game.minPlayers}',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: screenWidth * 0.04),

              // description
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Rules',
                  style: TextStyle(
                    fontFamily: 'ChildstoneDemo',
                    fontSize: screenWidth * 0.05,
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: screenWidth * 0.02),
              Text(
                game.description,
                style: TextStyle(color: Colors.white70, fontSize: screenWidth * 0.042),
              ),

              SizedBox(height: screenWidth * 0.04),

              // play button
              SizedBox(
                width: double.infinity,
                child: StyledButton(
                  text: 'PLAY',
                  onPressed: () {
                    Navigator.of(context).pop(); // close popup
                    onPlay(game);
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
