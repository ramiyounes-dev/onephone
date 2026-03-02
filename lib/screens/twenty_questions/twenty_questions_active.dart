// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:flutter/material.dart';
import 'package:onephone/widgets/two_button_popup.dart';
import '../../models/twenty_questions_entry.dart';
import '../../theme/app_gradients.dart';
import '../../theme/app_colors.dart';
import '../../widgets/styled_button.dart';
import '../../widgets/ask_question_popup.dart';
import '../../widgets/notification_popup.dart';
import 'twenty_questions_report.dart';

class TwentyQuestionsActiveScreen extends StatefulWidget {
  final List<String> players;
  final String chooser;
  final String secret;

  const TwentyQuestionsActiveScreen({
    required this.players,
    required this.chooser,
    required this.secret,
    super.key,
  });

  @override
  State<TwentyQuestionsActiveScreen> createState() =>
      _TwentyQuestionsActiveScreenState();
}

class _TwentyQuestionsActiveScreenState
    extends State<TwentyQuestionsActiveScreen> {
  final List<TwentyQuestionEntry> questions = [];
  bool giveUp = false;

  // -----------------------
  // Exit
  // -----------------------
  Future<bool> _confirmExit() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => NotificationPopup(
        title: 'Exit game',
        message: 'Are you sure you want to exit?',
        buttonText: 'Yes',
        onClose: () => Navigator.pop(context, true),
      ),
    );
    return result ?? false;
  }

  // -----------------------
  // Found Word (dismissible!)
  // -----------------------
  Future<void> _confirmFoundWord() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => TwoButtonPopup(
        title: 'Word Found?',
        message: 'Are you sure?',
        yesText: 'Yes',
        noText: 'No, give up',
      ),
    );

    if (result == false) {
      setState(() => giveUp = true);
    }
    _goToReport();
  }


  void _goToReport() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TwentyQuestionsReportScreen(
          giveUp: giveUp,
          chooser: widget.chooser,
          secret: widget.secret,
          questions: questions,
          players: widget.players
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final leave = await _confirmExit();
          if (leave && mounted) {
            Navigator.popUntil(context, (r) => r.isFirst);
          }
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppGradients.mainBackground),
        child: SafeArea(
          child: Column(
            children: [
              // ─── TOP BAR ───
              SizedBox(
                height: 80,
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        '${questions.length} / 20 Questions',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      top: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () async {
                          final leave = await _confirmExit();
                          if (leave) {
                            Navigator.popUntil(context, (r) => r.isFirst);
                          }
                        },
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: IconButton(
                        icon: const Icon(
                          Icons.emoji_events,
                          color: AppColors.goldDark,
                          size: 30,
                        ),
                        onPressed: _confirmFoundWord,
                      ),
                    ),
                  ],
                ),
              ),

              // ─── QUESTIONS LIST ───
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: questions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final q = entry.value;

                    return GestureDetector(
                      onTap: () async {
                        final edited = await showDialog<TwentyQuestionEntry>(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => AskQuestionPopup(initial: q),
                        );

                        if (edited != null) {
                          setState(() {
                            questions[index] = edited;
                          });
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                q.question,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenW * 0.05,
                                ),
                              ),
                            ),
                            Text(
                              q.answerYes ? 'YES' : 'NO',
                              style: TextStyle(
                                color: q.answerYes
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // ─── ASK QUESTION ───
              Padding(
                padding: const EdgeInsets.all(16),
                child: StyledButton(
                  text: 'Ask a Question',
                  onPressed: questions.length >= 20
                      ? null
                      : () async {
                          final res = await showDialog<TwentyQuestionEntry>(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const AskQuestionPopup(),
                          );

                          if (res != null) {
                            setState(() => questions.add(res));

                            if (questions.length >= 20) {
                              _goToReport();
                            }
                          }
                        },
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
