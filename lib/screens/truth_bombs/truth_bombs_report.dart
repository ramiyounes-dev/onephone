// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:flutter/material.dart';
import 'package:onephone/models/truth_bombs_question.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/report_utils.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/report_game_header.dart';
import '../../widgets/report_top_bar.dart';
import '../../widgets/styled_button.dart';

class TruthBombsReportScreen extends StatefulWidget {
  final List<String> players;
  final List<TruthBombQuestion> questions;
  final Map<int, Map<String, int>> answers;
  final String language;

  const TruthBombsReportScreen({
    required this.players,
    required this.questions,
    required this.answers,
    this.language = 'en',
    super.key,
  });

  @override
  State<TruthBombsReportScreen> createState() => _TruthBombsReportScreenState();
}

class _TruthBombsReportScreenState extends State<TruthBombsReportScreen> {
  final GlobalKey _reportKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ReportGameHeader(
                        imagePath: 'assets/images/games/truth-bombs.png',
                        gameName: 'Truth Bombs',
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Players:',
                        style: AppTextStyles.sectionTitle(screenWidth * 0.05),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          widget.players.join(', '),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.contentText(
                            screenWidth * 0.065,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Questions & Answers:',
                        style: AppTextStyles.sectionTitle(screenWidth * 0.05),
                      ),
                      const SizedBox(height: 6),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children:
                            List.generate(widget.questions.length, (index) {
                          final q = widget.questions[index];
                          final answerMap = widget.answers[index] ?? {};

                          final counts = <String, int>{};
                          for (var entry in answerMap.entries) {
                            counts[entry.key] = entry.value;
                          }

                          final sortedAnswers = counts.entries.toList()
                            ..sort((a, b) => b.value.compareTo(a.value));

                          final totalVotes =
                              counts.values.fold(0, (sum, v) => sum + v);
                          final percentages = sortedAnswers.map((e) {
                            if (totalVotes == 0) return 0.0;
                            return (e.value / totalVotes * 100);
                          }).toList();

                          final highestValue = sortedAnswers.isNotEmpty
                              ? sortedAnswers.first.value
                              : -1;

                          return Center(
                            child: Container(
                              width: screenWidth * 0.9,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 0, 0, 0)
                                    .withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Q${index + 1}: ${q.getText(widget.language)}',
                                    style: AppTextStyles.contentText(
                                      screenWidth * 0.045,
                                      color: AppColors.goldDark,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: List.generate(
                                        sortedAnswers.length, (i) {
                                      final answer = sortedAnswers[i].key;
                                      final percent = percentages[i];
                                      final value = sortedAnswers[i].value;
                                      final isTop = value == highestValue;

                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 3,
                                          horizontal: 4,
                                        ),
                                        decoration: isTop
                                            ? BoxDecoration(
                                                color: AppColors.goldDark
                                                    .withValues(alpha: 0.07),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              )
                                            : null,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 4,
                                              child: Text(
                                                answer,
                                                style:
                                                    AppTextStyles.contentText(
                                                  screenWidth * 0.042,
                                                  color: isTop
                                                      ? AppColors.goldDark
                                                      : Colors.white,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                '${percent.toStringAsFixed(1)}%',
                                                textAlign: TextAlign.right,
                                                style:
                                                    AppTextStyles.contentText(
                                                  screenWidth * 0.042,
                                                  color: isTop
                                                      ? AppColors.goldDark
                                                      : Colors.white70,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
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
      ReportUtils.captureAndSave(context, _reportKey, 'truth_bombs_full');
}
