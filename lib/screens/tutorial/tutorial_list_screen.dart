// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:flutter/material.dart';
import '../../data/game_data.dart';
import '../../models/game.dart';
import '../../theme/app_colors.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/game_tile.dart';
import 'game_tutorial_screen.dart';

class TutorialListScreen extends StatefulWidget {
  const TutorialListScreen({super.key});

  @override
  State<TutorialListScreen> createState() => _TutorialListScreenState();
}

class _TutorialListScreenState extends State<TutorialListScreen> {
  List<Game> filteredGames = [];
  String query = '';

  @override
  void initState() {
    super.initState();
    filteredGames = List.of(gamesSampleData);
  }

  void _onSearchChanged(String s) {
    setState(() {
      query = s;
      final lower = query.toLowerCase();
      filteredGames = gamesSampleData
          .where((g) => g.title.toLowerCase().contains(lower))
          .toList();
    });
  }

  void _openTutorial(BuildContext context, Game game) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameTutorialScreen(game: game)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GradientScaffold(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    'How to Play',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'ChildstoneDemo',
                      fontSize: screenWidth * 0.075,
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),

            SizedBox(height: screenHeight * 0.02),

            TextField(
              onChanged: _onSearchChanged,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'ChildstoneDemo',
              ),
              decoration: InputDecoration(
                hintText: 'Search games...',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.02),

            Expanded(
              child: filteredGames.isEmpty
                  ? const Center(
                      child: Text(
                        'No games found',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredGames.length,
                      itemBuilder: (context, index) {
                        final game = filteredGames[index];
                        return GameTile(
                          game: game,
                          onTap: (g) => _openTutorial(context, g),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
