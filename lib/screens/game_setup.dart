// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:flutter/material.dart';
import 'package:onephone/screens/simon/simon_settings.dart';
import 'package:onephone/screens/spin_the_bottle/spin_the_bottle_settings.dart';
import 'package:onephone/screens/truth_bombs/truth_bombs_settings.dart';
import 'package:onephone/screens/undercover/undercover_settings.dart';
import 'package:onephone/screens/word_blitz/word_blitz_settings.dart';
import '../models/game.dart';
import '../storage/player_storage.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/styled_button.dart';
import '../screens/game_play_placeholder.dart';
import 'charades/charades_settings.dart';
import 'hot_potato/hot_potato_settings.dart';
import 'twenty_questions/twenty_questions_settings.dart';
import 'would_you_rather/would_you_rather_settings.dart';

class GameSetupScreen extends StatefulWidget {
  final Game game;
  const GameSetupScreen({required this.game, super.key});

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  List<String> players = [];
  Map<String, bool> selected = {};
  bool selectAll = false;
  String? errorText;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    players = await PlayerStorage.loadPlayers();
    setState(() {
      selected = {for (var p in players) p: false};
    });
  }

  void _togglePlayer(String name) {
    setState(() {
      selected[name] = !(selected[name] ?? false);
      selectAll = selected.values.every((v) => v == true);
    });
  }

  void _toggleSelectAll(bool v) {
    setState(() {
      selectAll = v;
      for (var k in selected.keys) selected[k] = v;
    });
  }

  void _onGoPressed() {
    final selectedPlayers = selected.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (selectedPlayers.length < widget.game.minPlayers) {
      setState(
        () => errorText = 'Select at least ${widget.game.minPlayers} players.',
      );
      return;
    }

    final routes = <String, Widget>{
      'hotpotato': HotPotatoSettingsScreen(players: selectedPlayers),
      'undercover': UndercoverSettingsScreen(players: selectedPlayers),
      'charades': CharadesSettingsScreen(players: selectedPlayers),
      'wouldyourather': WouldYouRatherSettingsScreen(players: selectedPlayers),
      '20questions': TwentyQuestionsSettingsScreen(players: selectedPlayers),
      'spinthebottle': SpinTheBottleSettingsScreen(players: selectedPlayers),
      'truthbombs': TruthBombsSettingsScreen(players: selectedPlayers),
      'simon': SimonSettingsScreen(players: selectedPlayers),
      'wordblitz': WordBlitzSettingsScreen(players: selectedPlayers),
    };

    final destination = routes[widget.game.id] ??
        GamePlayPlaceholderScreen(game: widget.game, players: selectedPlayers);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    return GradientScaffold(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenW * 0.04,
          vertical: screenH * 0.04,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    widget.game.imageAsset,
                    width: screenW * 0.12,
                    height: screenW * 0.12,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: screenW * 0.03),
                Expanded(
                  child: Text(
                    widget.game.title,
                    style: TextStyle(
                      fontFamily: 'ChildstoneDemo',
                      color: AppColors.primaryText,
                      fontSize: screenW * 0.055,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: screenH * 0.03),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select party members',
                  style: TextStyle(
                    fontSize: screenW * 0.05,
                    color: AppColors.primaryText,
                    fontFamily: 'ChildstoneDemo',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Min players: ${widget.game.minPlayers}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),

            SizedBox(height: screenH * 0.01),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),
                Row(
                  children: [
                    const Text(
                      'Select All',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: 8),
                    Transform.scale(
                      scale: 0.9,
                      child: Switch(
                        value: selectAll,
                        onChanged: _toggleSelectAll,
                        activeThumbColor: Colors.greenAccent,
                        activeTrackColor: Colors.green.withValues(alpha: 0.3),
                        inactiveThumbColor: Colors.redAccent,
                        inactiveTrackColor: Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: screenH * 0.02),

            Expanded(
              child: players.isEmpty
                  ? const Center(
                      child: Text(
                        'No players saved. Add players in Player Setup.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView(
                      children: players.map((p) {
                        final isSelected = selected[p] ?? false;
                        return GestureDetector(
                          onTap: () => _togglePlayer(p),
                          child: Container(
                            margin: EdgeInsets.only(bottom: screenH * 0.015),
                            padding: EdgeInsets.symmetric(
                              vertical: screenH * 0.02,
                              horizontal: screenW * 0.04,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.greenAccent.withValues(alpha: 0.25)
                                  : Colors.redAccent.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.06),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    p,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenW * 0.045,
                                    ),
                                  ),
                                ),
                                Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.remove_circle,
                                  color: isSelected
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),

            if (errorText != null)
              Text(
                errorText!,
                style: const TextStyle(color: Colors.yellowAccent),
              ),

            SizedBox(height: screenH * 0.02),

            SizedBox(
              width: double.infinity,
              child: StyledButton(text: 'GO', onPressed: _onGoPressed),
            ),
          ],
        ),
      ),
    );
  }
}
