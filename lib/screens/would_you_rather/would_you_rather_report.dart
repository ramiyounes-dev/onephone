// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:flutter/material.dart';
import '../../data/would_you_rather/would_you_rather_questions.dart';
import '../../models/would_you_rather_question.dart';
import '../../models/would_you_rather_answer.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/report_utils.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/report_game_header.dart';
import '../../widgets/report_top_bar.dart';
import '../../widgets/styled_button.dart';

class WouldYouRatherReportScreen extends StatefulWidget {
  final List<String> players;
  final List<WouldYouRatherQuestion> questions;
  final Map<int, Map<String, WouldYouRatherChoice>> answers;
  final String language;

  const WouldYouRatherReportScreen({
    required this.players,
    required this.questions,
    required this.answers,
    this.language = 'en',
    super.key,
  });

  @override
  State<WouldYouRatherReportScreen> createState() =>
      _WouldYouRatherReportScreenState();
}

class _WouldYouRatherReportScreenState
    extends State<WouldYouRatherReportScreen> {
  final GlobalKey _reportKey = GlobalKey();

  List<String> _getCategories() {
    final categoriesSet = <String>{};
    for (final q in widget.questions) {
      categoriesSet.addAll(q.categories.map((c) => _translateCategory(c)));
    }
    return categoriesSet.toList();
  }

  String _translateCategory(String cat) {
    final mapping = wouldYouRatherCategories.firstWhere(
      (c) => c['en'] == cat,
      orElse: () => {'en': cat, 'fr': cat, 'ar': cat},
    );
    return (mapping[widget.language] as String?) ?? cat;
  }

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
                        imagePath: 'assets/images/games/would-you-rather.png',
                        gameName: 'Would You Rather',
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'Categories:',
                        style: AppTextStyles.sectionTitle(screenWidth * 0.05),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _getCategories().join(', '),
                        style: AppTextStyles.contentText(screenWidth * 0.042),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'Questions:',
                        style: AppTextStyles.sectionTitle(screenWidth * 0.05),
                      ),
                      const SizedBox(height: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(widget.questions.length, (
                          index,
                        ) {
                          final q = widget.questions[index];
                          final answerMap = widget.answers[index] ?? {};
                          final total = widget.players.length;
                          final aCount = answerMap.values
                              .where((c) => c == WouldYouRatherChoice.a)
                              .length;
                          final bCount = answerMap.values
                              .where((c) => c == WouldYouRatherChoice.b)
                              .length;

                          final aPercent = total == 0
                              ? 0
                              : ((aCount / total) * 100).round();
                          final bPercent = total == 0
                              ? 0
                              : ((bCount / total) * 100).round();

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
                                  Center(
                                    child: Text(
                                      'Question ${index + 1}',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.contentText(
                                        screenWidth * 0.045,
                                        color: AppColors.goldDark,
                                        bold: true,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'A: ${q.partA(widget.language)} ($aPercent%)',
                                    style: AppTextStyles.contentText(
                                      screenWidth * 0.042,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'B: ${q.partB(widget.language)} ($bPercent%)',
                                    style: AppTextStyles.contentText(
                                      screenWidth * 0.042,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),

                      Text(
                        'Party\'s Choices:',
                        style: AppTextStyles.sectionTitle(screenWidth * 0.05),
                      ),
                      const SizedBox(height: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: widget.players.map((player) {
                          final choices = List.generate(
                            widget.questions.length,
                            (index) => widget.answers[index]?[player],
                          );

                          return Center(
                            child: Container(
                              width: screenWidth * 0.9,
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 0, 0, 0)
                                    .withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    player,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.contentText(
                                      screenWidth * 0.042,
                                      color: Colors.white70,
                                      bold: true,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    alignment: WrapAlignment.center,
                                    children: choices.map((c) {
                                      if (c == WouldYouRatherChoice.a) {
                                        return Text(
                                          'A',
                                          style: AppTextStyles.contentText(
                                            screenWidth * 0.04,
                                            color: Colors.red,
                                            bold: true,
                                          ),
                                        );
                                      } else if (c == WouldYouRatherChoice.b) {
                                        return Text(
                                          'B',
                                          style: AppTextStyles.contentText(
                                            screenWidth * 0.04,
                                            color: Colors.blue,
                                            bold: true,
                                          ),
                                        );
                                      } else {
                                        return const SizedBox();
                                      }
                                    }).toList(),
                                  ),
                                ],
                              ),
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
      ReportUtils.captureAndSave(context, _reportKey, 'would_you_rather_full');
}
