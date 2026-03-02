// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../models/twenty_questions_entry.dart';
import '../../theme/app_colors.dart';
import '../../utils/report_utils.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/report_game_header.dart';
import '../../widgets/report_top_bar.dart';
import '../../widgets/styled_button.dart';

class TwentyQuestionsReportScreen extends StatefulWidget {
  final String chooser;
  final String secret;
  final bool giveUp;
  final List<TwentyQuestionEntry> questions;
  final List<String> players;

  const TwentyQuestionsReportScreen({
    required this.giveUp,
    required this.chooser,
    required this.secret,
    required this.questions,
    required this.players,
    super.key,
  });

  @override
  State<TwentyQuestionsReportScreen> createState() =>
      _TwentyQuestionsReportScreenState();
}

class _TwentyQuestionsReportScreenState
    extends State<TwentyQuestionsReportScreen> {
  final GlobalKey _reportKey = GlobalKey();

  bool get wordFound => widget.questions.length < 20 && widget.giveUp == false;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final party = widget.players.where((p) => p != widget.chooser).toList();
    final partyNames = party.join(', ');

    return GradientScaffold(
      child: Column(
        children: [
          const ReportTopBar(),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: RepaintBoundary(
                key: _reportKey,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const ReportGameHeader(
                        imagePath: 'assets/images/games/20-questions.png',
                        gameName: '20 Questions',
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'The Word/Description',
                        style: TextStyle(
                          fontSize: screenW * 0.05,
                          fontFamily: 'ChildstoneDemo',
                          color: AppColors.goldDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AutoSizeText(
                        widget.secret,
                        maxLines: 2,
                        minFontSize: 22,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenW * 0.12,
                          fontFamily: 'ChildstoneDemo',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 24),

                      wordFound
                          ? Column(
                              children: [
                                AutoSizeText(
                                  'The party \n $partyNames \n found the word',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 5,
                                  minFontSize: 20,
                                ),
                                AutoSizeText(
                                  '${widget.chooser} lost',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  minFontSize: 20,
                                ),
                              ],
                            )
                          : AutoSizeText(
                              '${widget.chooser} \n won against \n $partyNames',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 5,
                              minFontSize: 20,
                            ),
                      const SizedBox(height: 24),

                      Column(
                        children: widget.questions.asMap().entries.map((
                          entry,
                        ) {
                          final q = entry.value;
                          return Container(
                            width: screenW * 0.9,
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    q.question,
                                    style: TextStyle(
                                      fontSize: screenW * 0.05,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  q.answerYes ? 'YES' : 'NO',
                                  style: TextStyle(
                                    fontSize: screenW * 0.05,
                                    color: q.answerYes
                                        ? Colors.greenAccent
                                        : Colors.redAccent,
                                    fontWeight: FontWeight.bold,
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
      ReportUtils.captureAndSave(context, _reportKey, 'twenty_questions');
}
