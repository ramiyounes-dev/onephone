// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../models/would_you_rather_question.dart';
import '../../models/would_you_rather_answer.dart';
import '../../theme/app_gradients.dart';
import '../../widgets/styled_button.dart';
import '../../widgets/language_popup.dart';
import '../../widgets/notification_popup.dart';
import 'would_you_rather_report.dart';

class WouldYouRatherActiveScreen extends StatefulWidget {
  final List<String> players;
  final List<WouldYouRatherQuestion> questions;

  const WouldYouRatherActiveScreen({
    required this.players,
    required this.questions,
    super.key,
  });

  @override
  State<WouldYouRatherActiveScreen> createState() =>
      _WouldYouRatherActiveScreenState();
}

class _WouldYouRatherActiveScreenState
    extends State<WouldYouRatherActiveScreen> {
  int questionIndex = 0;
  String language = 'en';

  /// answers[questionIndex][player] = choice
  final Map<int, Map<String, WouldYouRatherChoice>> answers = {};

  WouldYouRatherQuestion get q => widget.questions[questionIndex];

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppGradients.mainBackground),
        child: SafeArea(
          child: Column(
            children: [
              /// ─── TOP BAR ───
              SizedBox(
                height: screenH * 0.11,
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        'Question ${questionIndex + 1} / ${widget.questions.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenW * 0.055,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      top: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: _confirmExit,
                      ),
                    ),
                  ],
                ),
              ),

              /// ─── QUESTION TITLE + LANGUAGE ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Would you rather?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenW * 0.055,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.translate, color: Colors.white),
                      onPressed: _selectLanguage,
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenH * 0.01),

              /// ─── OPTION A ───
              _optionTile(
                text: q.partA(language),
                color: Colors.red,
                screenW: screenW,
              ),

              SizedBox(height: screenH * 0.008),
              Text(
                'OR',
                style: TextStyle(color: Colors.white, fontSize: screenW * 0.04),
              ),
              SizedBox(height: screenH * 0.008),

              /// ─── OPTION B ───
              _optionTile(
                text: q.partB(language),
                color: Colors.blue,
                screenW: screenW,
              ),

              SizedBox(height: screenH * 0.04),

              /// ─── PLAYERS ───
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: widget.players
                      .map((p) => _playerTile(p, screenW))
                      .toList(),
                ),
              ),

              /// ─── VALIDATE ───
              Padding(
                padding: const EdgeInsets.all(12),
                child: StyledButton(
                  text: 'Validate',
                  onPressed: _allAnswered ? _next : null,
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  // ─────────────────────────────────────────────

  Widget _optionTile({
    required String text,
    required Color color,
    required double screenW,
  }) {
    return Container(
      width: screenW * 0.9,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(12),
      ),
      child: AutoSizeText(
        text,
        textAlign: TextAlign.center,
        maxLines: 4,
        minFontSize: 12,
        style: TextStyle(
          color: Colors.white,
          fontSize: screenW * 0.055,
        ),
      ),
    );
  }

  Widget _playerTile(String player, double screenW) {
    final choice = answers[questionIndex]?[player];
    final btnSize = screenW * 0.15;

    Color bg = Colors.white.withValues(alpha: 0.5);
    if (choice == WouldYouRatherChoice.a) bg = Colors.red.withValues(alpha: 0.75);
    if (choice == WouldYouRatherChoice.b) bg = Colors.blue.withValues(alpha: 0.75);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _choiceButton(player, WouldYouRatherChoice.a, 'A', Colors.red, btnSize),
          Expanded(
            child: Text(
              player,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                color: const Color.fromARGB(255, 0, 0, 0),
                fontSize: screenW * 0.045,
              ),
            ),
          ),
          _choiceButton(player, WouldYouRatherChoice.b, 'B', Colors.blue, btnSize),
        ],
      ),
    );
  }

  Widget _choiceButton(
    String player,
    WouldYouRatherChoice c,
    String label,
    Color color,
    double size,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          answers.putIfAbsent(questionIndex, () => {});
          answers[questionIndex]![player] = c;
        });
      },
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────

  bool get _allAnswered =>
      answers[questionIndex]?.length == widget.players.length;

  void _next() {
    if (questionIndex == widget.questions.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => WouldYouRatherReportScreen(
            questions: widget.questions,
            answers: answers,
            players: widget.players,
          ),
        ),
      );
    } else {
      setState(() => questionIndex++);
    }
  }

  void _selectLanguage() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => LanguagePopup(
        selectedLanguage: language,
        onSelected: (l) {
          setState(() => language = l);
        },
      ),
    );
  }

  void _confirmExit() async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => NotificationPopup(
        title: 'Exit game',
        message: 'Are you sure?',
        buttonText: 'Yes',
        onClose: () => Navigator.pop(context, true),
      ),
    );

    if (res == true) {
      Navigator.popUntil(context, (r) => r.isFirst);
    }
  }
}
