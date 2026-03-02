// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/logo_widget.dart';
import '../widgets/styled_button.dart';
import '../widgets/share_button.dart';
import 'player_setup.dart';
import 'party_games.dart';
import 'tutorial/tutorial_list_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  void _click() {
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return GradientScaffold(
      useSafeArea: false,
      child: Stack(
        children: [
          Positioned(right: 12, top: 38, child: ShareButton()),

          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.05),

                const Center(
                  child: LogoWidget(widthRatio: 0.7, heightRatio: 0.4),
                ),

                SizedBox(height: screenHeight * 0.03),

                Column(
                  children: [
                    StyledButton(
                      text: 'Player Setup',
                      onPressed: () {
                        _click();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PlayerSetupScreen(),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    StyledButton(
                      text: 'Party Games',
                      onPressed: () {
                        _click();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PartyGamesScreen(),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    StyledButton(
                      text: 'How to Play',
                      onPressed: () {
                        _click();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TutorialListScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
