// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../utils/report_utils.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/report_game_header.dart';
import '../../widgets/report_top_bar.dart';
import '../../widgets/styled_button.dart';

class SimonReportScreen extends StatefulWidget {
  final Map<String, List<int>> scores;

  const SimonReportScreen({super.key, required this.scores});

  @override
  State<SimonReportScreen> createState() => _SimonReportScreenState();
}

class _SimonReportScreenState extends State<SimonReportScreen> {
  final GlobalKey _reportKey = GlobalKey();

  int _bestScore(String p) =>
      widget.scores[p]!.reduce((a, b) => a > b ? a : b);
  int _worstScore(String p) =>
      widget.scores[p]!.reduce((a, b) => a < b ? a : b);

  List<String> computeBestPlayers() {
    final maxBest = widget.scores.values
        .map((rounds) => rounds.reduce((a, b) => a > b ? a : b))
        .reduce((a, b) => a > b ? a : b);
    return widget.scores.keys.where((p) => _bestScore(p) == maxBest).toList()
      ..sort();
  }

  List<String> computeWorstPlayers() {
    final minWorst = widget.scores.values
        .map((rounds) => rounds.reduce((a, b) => a < b ? a : b))
        .reduce((a, b) => a < b ? a : b);
    return widget.scores.keys
        .where((p) => _worstScore(p) == minWorst)
        .toList()
      ..sort();
  }

  @override
  Widget build(BuildContext context) {
    final players = widget.scores.keys.toList()..sort();
    final bestPlayers = computeBestPlayers();
    final worstPlayers = computeWorstPlayers();
    final screenW = MediaQuery.of(context).size.width;

    return GradientScaffold(
      child: Column(
        children: [
          const ReportTopBar(),

          const SizedBox(height: 12),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: RepaintBoundary(
                key: _reportKey,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const ReportGameHeader(
                        imagePath: 'assets/images/games/simon.png',
                        gameName: 'Simon',
                      ),

                      const SizedBox(height: 20),

                      if (players.length >= 2)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Text(
                                  bestPlayers.length > 1
                                      ? 'Best Players'
                                      : 'Best Player',
                                  style: TextStyle(
                                    fontSize: screenW * 0.045,
                                    fontFamily: 'ChildstoneDemo',
                                    color: AppColors.goldDark,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                for (var p in bestPlayers)
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 2),
                                    child: AutoSizeText(
                                      p,
                                      maxLines: 1,
                                      minFontSize: 12,
                                      style: TextStyle(
                                        fontSize: screenW * 0.02,
                                        fontFamily: 'ChildstoneDemo',
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 40),
                            Column(
                              children: [
                                Text(
                                  worstPlayers.length > 1
                                      ? 'Worst Players'
                                      : 'Worst Player',
                                  style: TextStyle(
                                    fontSize: screenW * 0.04,
                                    fontFamily: 'ChildstoneDemo',
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                for (var p in worstPlayers)
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 2),
                                    child: AutoSizeText(
                                      p,
                                      maxLines: 1,
                                      minFontSize: 12,
                                      style: TextStyle(
                                        fontSize: screenW * 0.02,
                                        fontFamily: 'ChildstoneDemo',
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),

                      const SizedBox(height: 20),

                      Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Player',
                                    style: TextStyle(
                                      fontSize: screenW * 0.033,
                                      fontFamily: 'ChildstoneDemo',
                                      color: AppColors.goldDark,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                for (int i = 0;
                                    i < widget.scores.values.first.length;
                                    i++)
                                  Expanded(
                                    child: Text(
                                      'R${i + 1}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: screenW * 0.033,
                                        fontFamily: 'ChildstoneDemo',
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          for (var player in players)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              margin: const EdgeInsets.only(bottom: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      player,
                                      style: TextStyle(
                                        fontSize: screenW * 0.03,
                                        fontFamily: 'ChildstoneDemo',
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  for (var score in widget.scores[player]!)
                                    Expanded(
                                      child: Text(
                                        score.toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: screenW * 0.03,
                                          fontFamily: 'ChildstoneDemo',
                                          color: AppColors.goldDark,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: StyledButton(
              text: 'Take Screenshot',
              onPressed: _captureReport,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _captureReport() =>
      ReportUtils.captureAndSave(context, _reportKey, 'simon');
}
