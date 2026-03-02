// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../utils/report_utils.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/report_game_header.dart';
import '../../widgets/report_top_bar.dart';
import '../../widgets/styled_button.dart';
import '../../models/word_blitz_result.dart';
import 'package:onephone/data/word_blitz/word_blitz_word.dart';

class WordBlitzReportScreen extends StatefulWidget {
  final List<WordBlitzResult> results;
  final String teamAName;
  final String teamBName;
  final List<WordBlitzWord> pack;
  final String language;

  const WordBlitzReportScreen({
    super.key,
    required this.results,
    required this.teamAName,
    required this.teamBName,
    required this.pack,
    required this.language,
  });

  @override
  State<WordBlitzReportScreen> createState() => _WordBlitzReportScreenState();
}

class _WordBlitzReportScreenState extends State<WordBlitzReportScreen> {
  final GlobalKey _reportKey = GlobalKey();

  int _teamScore(String team) =>
      widget.results.where((r) => r.team == team).length;

  String getWinner() {
    final a = _teamScore(widget.teamAName);
    final b = _teamScore(widget.teamBName);
    if (a > b) return widget.teamAName;
    if (b > a) return widget.teamBName;
    return 'Draw';
  }

  Map<String, List<String>> _groupedResults(int round) {
    final Map<String, List<String>> map = {};
    for (var r in widget.results.where((r) => r.round == round)) {
      final key = '${r.team}|${r.player}';
      if (!map.containsKey(key)) map[key] = [];
      map[key]!.add(r.word);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final totalRounds = widget.results.map((r) => r.round).toSet().length;

    return GradientScaffold(
      child: Column(
        children: [
          const ReportTopBar(),

          Expanded(
            child: SingleChildScrollView(
              child: RepaintBoundary(
                key: _reportKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const ReportGameHeader(
                        imagePath: 'assets/images/games/word-blitz.png',
                        gameName: 'Word Blitz',
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'Winner',
                        style: TextStyle(
                          fontSize: screenW * 0.06,
                          color: AppColors.goldDark,
                          fontFamily: 'ChildstoneDemo',
                        ),
                      ),
                      Text(
                        getWinner(),
                        style: TextStyle(
                          fontSize: screenW * 0.11,
                          color: Colors.white,
                          fontFamily: 'ChildstoneDemo',
                        ),
                      ),
                      const SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                widget.teamAName,
                                style: TextStyle(
                                  fontSize: screenW * 0.05,
                                  color: AppColors.goldDark,
                                ),
                              ),
                              Text(
                                '${_teamScore(widget.teamAName)} points',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: screenW * 0.045,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                widget.teamBName,
                                style: TextStyle(
                                  fontSize: screenW * 0.05,
                                  color: AppColors.goldDark,
                                ),
                              ),
                              Text(
                                '${_teamScore(widget.teamBName)} points',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: screenW * 0.045,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      Column(
                        children: List.generate(totalRounds, (i) {
                          final round = i + 1;
                          final grouped = _groupedResults(round);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Round $round',
                                style: TextStyle(
                                  fontSize: screenW * 0.05,
                                  color: AppColors.goldDark,
                                  fontFamily: 'ChildstoneDemo',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...grouped.entries.map((entry) {
                                final parts = entry.key.split('|');
                                final team = parts[0];
                                final player = parts[1];
                                final words = entry.value.join(', ');
                                return Container(
                                  width: screenW * 0.9,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$team • $player',
                                        style: TextStyle(
                                          fontSize: screenW * 0.045,
                                          color: AppColors.goldDark,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        words,
                                        style: TextStyle(
                                          fontSize: screenW * 0.04,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              const SizedBox(height: 20),
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: StyledButton(
              text: 'Screenshot',
              onPressed: _captureReport,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _captureReport() =>
      ReportUtils.captureAndSave(context, _reportKey, 'word_blitz_report');
}
