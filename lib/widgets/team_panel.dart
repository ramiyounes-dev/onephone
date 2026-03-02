// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A team panel showing the team name (tappable to rename) and a scrollable
/// list of players with a swap button. Used in Charades and Word Blitz settings.
class TeamPanel extends StatelessWidget {
  final String teamName;
  final List<String> players;
  final bool isTeamA;
  final double height;
  final String? selectedPlayer;
  final bool? selectedFromTeamA;
  final void Function(String player, bool fromTeamA) onSwap;
  final VoidCallback onRename;

  const TeamPanel({
    required this.teamName,
    required this.players,
    required this.isTeamA,
    required this.height,
    required this.selectedPlayer,
    required this.selectedFromTeamA,
    required this.onSwap,
    required this.onRename,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onRename,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  teamName,
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.edit, size: 16, color: Colors.white70),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: players.length,
              itemBuilder: (_, index) {
                final player = players[index];
                final isSelected =
                    selectedPlayer == player && selectedFromTeamA == isTeamA;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.goldDark.withValues(alpha: 0.8)
                        : Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          player,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.swap_horiz,
                          color: isSelected ? Colors.black : Colors.white70,
                        ),
                        onPressed: () => onSwap(player, isTeamA),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
