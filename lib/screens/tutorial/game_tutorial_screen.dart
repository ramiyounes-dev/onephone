// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:flutter/material.dart';
import '../../data/tutorial_data.dart';
import '../../models/game.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gradient_scaffold.dart';

class GameTutorialScreen extends StatelessWidget {
  final Game game;

  const GameTutorialScreen({required this.game, super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tutorial = tutorialData[game.id];

    if (tutorial == null) {
      return GradientScaffold(
        child: Center(
          child: Text(
            'No tutorial available.',
            style: TextStyle(color: Colors.white70, fontSize: screenWidth * 0.045),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: tutorial.sections.length,
      child: GradientScaffold(
        child: Column(
          children: [
            // ── TOP BAR ──
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.02,
                vertical: screenWidth * 0.02,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'How to Play',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'ChildstoneDemo',
                        fontSize: screenWidth * 0.065,
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // ── GAME HEADER ──
            Column(
              children: [
                ClipOval(
                  child: Image.asset(
                    game.imageAsset,
                    width: screenWidth * 0.22,
                    height: screenWidth * 0.22,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: screenWidth * 0.03),
                Text(
                  game.title,
                  style: TextStyle(
                    fontFamily: 'ChildstoneDemo',
                    fontSize: screenWidth * 0.07,
                    color: AppColors.goldDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            SizedBox(height: screenWidth * 0.04),

            // ── TABS ──
            TabBar(
              tabs: tutorial.sections
                  .map((s) => Tab(text: s.title))
                  .toList(),
              indicatorColor: AppColors.goldDark,
              labelColor: AppColors.goldDark,
              unselectedLabelColor: Colors.white54,
              labelStyle: TextStyle(
                fontFamily: 'ChildstoneDemo',
                fontSize: screenWidth * 0.042,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: TextStyle(
                fontFamily: 'ChildstoneDemo',
                fontSize: screenWidth * 0.042,
              ),
              indicatorWeight: 2.5,
            ),

            // ── TAB CONTENT ──
            Expanded(
              child: TabBarView(
                children: tutorial.sections
                    .map((section) => _SectionContent(
                          section: section,
                          screenWidth: screenWidth,
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionContent extends StatelessWidget {
  final TutorialSection section;
  final double screenWidth;

  const _SectionContent({
    required this.section,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.06,
        vertical: screenWidth * 0.05,
      ),
      itemCount: section.points.length,
      separatorBuilder: (_, __) => SizedBox(height: screenWidth * 0.04),
      itemBuilder: (_, index) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: screenWidth * 0.01),
              child: Icon(
                Icons.circle,
                size: screenWidth * 0.022,
                color: AppColors.goldDark,
              ),
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: Text(
                section.points[index],
                style: TextStyle(
                  fontFamily: 'ChildstoneDemo',
                  fontSize: screenWidth * 0.045,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
