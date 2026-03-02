// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:flutter/material.dart';

import '../../models/charades_word.dart';
import '../../models/charades_category.dart';

import '../../data/charades/charades_words.dart';
import '../../data/charades/charades_categories.dart';

import '../../theme/app_colors.dart';

import '../../widgets/category_chip.dart';
import '../../widgets/category_header.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/labeled_slider.dart';
import '../../widgets/language_popup.dart';
import '../../widgets/settings_top_bar.dart';
import '../../widgets/styled_button.dart';
import '../../widgets/team_panel.dart';
import '../../widgets/rename_team_popup.dart';

import 'charades_active.dart';

class CharadesSettingsScreen extends StatefulWidget {
  final List<String> players;

  const CharadesSettingsScreen({required this.players, super.key});

  @override
  State<CharadesSettingsScreen> createState() => _CharadesSettingsScreenState();
}

class _CharadesSettingsScreenState extends State<CharadesSettingsScreen> {
  late List<CharadesWord> wordsDB;
  late List<CharadesCategory> categoriesDB;
  late Map<String, bool> selectedCategories;

  String teamAName = 'Team A';
  String teamBName = 'Team B';

  late List<String> teamAPlayers;
  late List<String> teamBPlayers;

  String? selectedPlayer;
  bool? selectedFromTeamA;

  int timerPerTurn = 90;
  int numRounds = 5;
  bool manualWordSelection = false;
  String language = 'en';

  @override
  void initState() {
    super.initState();
    wordsDB = charadesWordsDB;
    categoriesDB = charadesCategoriesDB;
    selectedCategories = {for (final c in categoriesDB) c.id: true};
    _shuffleTeams();
  }

  void _shuffleTeams() {
    final shuffled = List<String>.from(widget.players)..shuffle();
    final half = (shuffled.length / 2).ceil();
    teamAPlayers = shuffled.sublist(0, half);
    teamBPlayers = shuffled.sublist(half);
    setState(() {
      selectedPlayer = null;
      selectedFromTeamA = null;
    });
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

    setState(() {
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

      selectedPlayer = null;
      selectedFromTeamA = null;
    });
  }

  bool get selectAll => selectedCategories.values.every((v) => v);

  void _toggleSelectAll(bool value) {
    setState(() {
      for (final k in selectedCategories.keys) {
        selectedCategories[k] = value;
      }
      manualWordSelection = !value;
    });
  }

  void _toggleCategory(String id) {
    setState(() {
      if (manualWordSelection) return;
      selectedCategories[id] = !selectedCategories[id]!;
      if (selectedCategories.values.any((v) => v)) {
        manualWordSelection = false;
      } else {
        manualWordSelection = true;
      }
    });
  }

  String _catLabel(CharadesCategory c) {
    switch (language) {
      case 'fr':
        return c.fr;
      case 'ar':
        return c.ar;
      default:
        return c.en;
    }
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
                title: 'Charades Settings',
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

                      CategoryHeader(
                        title: 'Categories',
                        toggleLabel: 'All',
                        selectAll: selectAll,
                        onToggleAll: _toggleSelectAll,
                      ),

                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: categoriesDB.map((c) {
                          return CategoryChip(
                            label: _catLabel(c),
                            isActive: selectedCategories[c.id]!,
                            onTap: manualWordSelection
                                ? null
                                : () => _toggleCategory(c.id),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Manual Word Selection',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white70),
                          ),
                          Switch(
                            value: manualWordSelection,
                            onChanged: (value) {
                              setState(() {
                                manualWordSelection = value;
                                for (final k in selectedCategories.keys) {
                                  selectedCategories[k] = !value;
                                }
                              });
                            },
                            activeColor: AppColors.goldDark,
                            activeTrackColor:
                                AppColors.goldDark.withValues(alpha: 0.3),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      LabeledSlider(
                        label: 'Timer per turn',
                        valueText: '$timerPerTurn s',
                        min: 30,
                        max: 180,
                        value: timerPerTurn.toDouble(),
                        onChanged: (v) =>
                            setState(() => timerPerTurn = v.toInt()),
                      ),

                      const SizedBox(height: 16),

                      LabeledSlider(
                        label: 'Number of rounds',
                        valueText: '$numRounds',
                        min: teamAPlayers.length.toDouble(),
                        max: 12,
                        divisions: 11,
                        value: numRounds.toDouble(),
                        onChanged: (v) =>
                            setState(() => numRounds = v.toInt()),
                      ),

                      const SizedBox(height: 24),
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
                      builder: (_) => CharadesActiveScreen(
                        teamA: teamAPlayers,
                        teamB: teamBPlayers,
                        teamAName: teamAName,
                        teamBName: teamBName,
                        categories: categoriesDB
                            .where((c) => selectedCategories[c.id]!)
                            .map((c) => c.id)
                            .toList(),
                        numRounds: numRounds,
                        timerPerTurn: timerPerTurn,
                        manualWordSelection: manualWordSelection,
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
