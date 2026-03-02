// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../utils/report_utils.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/report_game_header.dart';
import '../../widgets/report_top_bar.dart';
import '../../widgets/styled_button.dart';
import '../../models/charades_game_result.dart';

class CharadesReportScreen extends StatefulWidget {
  final List<CharadesGameResult> results;
  final String teamAName;
  final String teamBName;
  final List<String> categories;

  const CharadesReportScreen({
    required this.results,
    required this.teamAName,
    required this.teamBName,
    required this.categories,
    super.key,
  });

  @override
  State<CharadesReportScreen> createState() => _CharadesReportScreenState();
}

class _CharadesReportScreenState extends State<CharadesReportScreen> {
  final GlobalKey _reportKey = GlobalKey();

  int _teamScore(String team) => widget.results
      .where((r) => r.teamName == team)
      .fold(0, (sum, r) => sum + r.points);

  int _teamUsedTime(String team) => widget.results
      .where((r) => r.teamName == team)
      .fold(0, (sum, r) => sum + r.usedTime);

  String getWinner() {
    final scoreA = _teamScore(widget.teamAName);
    final scoreB = _teamScore(widget.teamBName);
    final timeA = _teamUsedTime(widget.teamAName);
    final timeB = _teamUsedTime(widget.teamBName);

    if (scoreA > scoreB) return widget.teamAName;
    if (scoreB > scoreA) return widget.teamBName;
    if (timeA < timeB) return widget.teamAName;
    if (timeB < timeA) return widget.teamBName;
    return 'Draw';
  }

  List<String> _getCategories() {
    if (widget.categories.isEmpty) return ['Manual Selection'];
    return widget.categories;
  }

  @override
  Widget build(BuildContext context) {
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const ReportGameHeader(
                        imagePath: 'assets/images/games/charades.png',
                        gameName: 'Charades',
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Categories:',
                        style: TextStyle(
                          fontSize: screenW * 0.05,
                          fontWeight: FontWeight.bold,
                          color: AppColors.goldDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _getCategories().join(', '),
                        style: TextStyle(
                          fontSize: screenW * 0.042,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Winner',
                              style: TextStyle(
                                fontSize: screenW * 0.05,
                                fontFamily: 'ChildstoneDemo',
                                color: AppColors.goldDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: screenW * 0.8,
                              child: AutoSizeText(
                                getWinner(),
                                maxLines: 1,
                                minFontSize: 18,
                                stepGranularity: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: screenW * 0.12,
                                  fontFamily: 'ChildstoneDemo',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                widget.teamAName,
                                style: TextStyle(
                                  fontSize: screenW * 0.045,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.goldDark,
                                ),
                              ),
                              Text(
                                '${_teamScore(widget.teamAName)} pts',
                                style: TextStyle(
                                  fontSize: screenW * 0.04,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                'Time: ${_teamUsedTime(widget.teamAName)}s',
                                style: TextStyle(
                                  fontSize: screenW * 0.038,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                widget.teamBName,
                                style: TextStyle(
                                  fontSize: screenW * 0.045,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.goldDark,
                                ),
                              ),
                              Text(
                                '${_teamScore(widget.teamBName)} pts',
                                style: TextStyle(
                                  fontSize: screenW * 0.04,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                'Time: ${_teamUsedTime(widget.teamBName)}s',
                                style: TextStyle(
                                  fontSize: screenW * 0.038,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Column(
                        children: widget.results.map((r) {
                          Color tileColor;
                          if (r.points > 0) {
                            tileColor = const Color.fromARGB(255, 13, 107, 16)
                                .withValues(alpha: 0.4);
                          } else if (r.remainingTime > 0) {
                            tileColor = const Color.fromARGB(255, 255, 2, 2)
                                .withValues(alpha: 0.4);
                          } else {
                            tileColor = Colors.black.withValues(alpha: 0.6);
                          }

                          return Container(
                            width: screenW * 0.9,
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: tileColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Round ${r.round} - ${r.teamName} - ${r.playerName}',
                                  style: TextStyle(
                                    fontSize: screenW * 0.045,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.goldDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Word: ${r.word}',
                                  style: TextStyle(
                                    fontSize: screenW * 0.04,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  'Points: ${r.points}',
                                  style: TextStyle(
                                    fontSize: screenW * 0.04,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  'Time Used: ${r.usedTime}s / Remaining: ${r.remainingTime}s',
                                  style: TextStyle(
                                    fontSize: screenW * 0.038,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12.0),
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
      ReportUtils.captureAndSave(context, _reportKey, 'charades_full');
}
