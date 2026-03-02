// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:flutter/material.dart';
import '../../widgets/rename_team_popup.dart';

import '../../widgets/gradient_scaffold.dart';
import '../../widgets/labeled_slider.dart';
import '../../widgets/language_popup.dart';
import '../../widgets/settings_top_bar.dart';
import '../../widgets/styled_button.dart';
import '../../widgets/team_panel.dart';

import 'word_blitz_active.dart';

class WordBlitzSettingsScreen extends StatefulWidget {
  final List<String> players;

  const WordBlitzSettingsScreen({required this.players, super.key});

  @override
  State<WordBlitzSettingsScreen> createState() =>
      _WordBlitzSettingsScreenState();
}

class _WordBlitzSettingsScreenState extends State<WordBlitzSettingsScreen> {
  String teamAName = 'Team A';
  String teamBName = 'Team B';
  late List<String> teamAPlayers;
  late List<String> teamBPlayers;

  String? selectedPlayer;
  bool? selectedFromTeamA;

  int timerPerTurn = 45;
  bool manualWordSelection = false;
  String language = 'en';

  @override
  void initState() {
    super.initState();
    _shuffleTeams();
  }

  void _shuffleTeams() {
    final shuffled = List<String>.from(widget.players)..shuffle();
    final half = (shuffled.length / 2).ceil();
    teamAPlayers = shuffled.sublist(0, half);
    teamBPlayers = shuffled.sublist(half);
    selectedPlayer = null;
    selectedFromTeamA = null;
  }

  void _renameTeam(bool isTeamA) {
    showDialog(
      context: context,
      builder: (_) => RenameTeamPopup(
        initialName: isTeamA ? teamAName : teamBName,
        onSubmit: (name) {
          setState(() {
            if (isTeamA) {
              teamAName = name;
            } else {
              teamBName = name;
            }
          });
        },
      ),
    );
  }

  void _selectLanguage() {
    showDialog(
      context: context,
      builder: (_) => LanguagePopup(
        selectedLanguage: language,
        onSelected: (l) => setState(() => language = l),
      ),
    );
  }

  void _onSwapPressed(String player, bool fromTeamA) {
    if (selectedPlayer == null) {
      setState(() {
        selectedPlayer = player;
        selectedFromTeamA = fromTeamA;
      });
      return;
    }
    if (selectedPlayer == player && selectedFromTeamA == fromTeamA) {
      setState(() {
        selectedPlayer = null;
        selectedFromTeamA = null;
      });
      return;
    }

    final firstPlayer = selectedPlayer!;
    final firstFromTeamA = selectedFromTeamA!;

    final list1 = firstFromTeamA ? teamAPlayers : teamBPlayers;
    final list2 = fromTeamA ? teamAPlayers : teamBPlayers;

    final index1 = list1.indexOf(firstPlayer);
    final index2 = list2.indexOf(player);

    if (index1 == -1 || index2 == -1) return;

    if (firstFromTeamA == fromTeamA) {
      list1[index1] = player;
      list1[index2] = firstPlayer;
    } else {
      list1[index1] = player;
      list2[index2] = firstPlayer;
    }

    setState(() {
      selectedPlayer = null;
      selectedFromTeamA = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return GradientScaffold(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: screenH * 0.02),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SettingsTopBar(
                title: 'Word Blitz Settings',
                actions: [
                  IconButton(
                    icon: const Icon(Icons.translate, color: Colors.white),
                    onPressed: _selectLanguage,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TeamPanel(
                        teamName: teamAName,
                        players: teamAPlayers,
                        isTeamA: true,
                        height: screenH * 0.28,
                        selectedPlayer: selectedPlayer,
                        selectedFromTeamA: selectedFromTeamA,
                        onSwap: _onSwapPressed,
                        onRename: () => _renameTeam(true),
                      ),
                      const SizedBox(height: 16),
                      TeamPanel(
                        teamName: teamBName,
                        players: teamBPlayers,
                        isTeamA: false,
                        height: screenH * 0.28,
                        selectedPlayer: selectedPlayer,
                        selectedFromTeamA: selectedFromTeamA,
                        onSwap: _onSwapPressed,
                        onRename: () => _renameTeam(false),
                      ),
                      const SizedBox(height: 24),

                      LabeledSlider(
                        label: 'Timer per turn',
                        valueText: '$timerPerTurn s',
                        min: 30,
                        max: 90,
                        value: timerPerTurn.toDouble(),
                        onChanged: (v) =>
                            setState(() => timerPerTurn = v.toInt()),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: StyledButton(
                text: 'OK',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WordBlitzActiveScreen(
                        teamA: teamAPlayers,
                        teamB: teamBPlayers,
                        teamAName: teamAName,
                        teamBName: teamBName,
                        numRounds: 3,
                        timerPerTurn: timerPerTurn,
                        manualWordSelection: manualWordSelection,
                        language: language,
                      ),
                    ),
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
