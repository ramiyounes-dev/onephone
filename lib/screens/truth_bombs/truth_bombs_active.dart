// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:onephone/models/truth_bombs_question.dart';
import '../../theme/app_gradients.dart';
import '../../widgets/styled_button.dart';
import '../../widgets/language_popup.dart';
import '../../widgets/notification_popup.dart';
import 'truth_bombs_report.dart';

class TruthBombsActiveScreen extends StatefulWidget {
  final List<String> players;
  final List<TruthBombQuestion> questions;

  const TruthBombsActiveScreen({
    required this.players,
    required this.questions,
    super.key,
  });

  @override
  State<TruthBombsActiveScreen> createState() =>
      _TruthBombsActiveScreenState();
}

class _TruthBombsActiveScreenState extends State<TruthBombsActiveScreen> {
  int questionIndex = 0;
  String language = 'en';

  /// votes[questionIndex][player] = voteCount
  final Map<int, Map<String, int>> votes = {};

  TruthBombQuestion get q => widget.questions[questionIndex];

  // ─────────────────────────────────────────────
  // CHECK IF ALL VOTES ARE ASSIGNED
  bool get _isVoteComplete {
    final map = votes[questionIndex] ?? {};
    final total = map.values.fold(0, (a, b) => a + b);
    return total == widget.players.length;
  }

  int get _votesRemaining {
    final map = votes[questionIndex] ?? {};
    final total = map.values.fold(0, (a, b) => a + b);
    return widget.players.length - total;
  }

  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;
    final btnSize = screenW * 0.13;

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
              // ─── TOP BAR ───
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

              // ─── LANGUAGE BUTTON ───
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: const Icon(Icons.translate, color: Colors.white),
                    onPressed: _selectLanguage,
                  ),
                ),
              ),

              // ─── QUESTION CONTENT ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: screenW * 0.9,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: AutoSizeText(
                    q.getText(language),
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    minFontSize: 12,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenW * 0.055,
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenH * 0.02),

              // ─── PLAYERS ───
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: widget.players
                      .map((p) => _playerTile(p, screenW, btnSize))
                      .toList(),
                ),
              ),

              // ─── VOTE REMAINING INDICATOR ───
              _voteIndicator(screenW),

              SizedBox(height: screenH * 0.01),

              // ─── NEXT BUTTON ───
              Padding(
                padding: const EdgeInsets.all(12),
                child: StyledButton(
                  text: questionIndex == widget.questions.length - 1
                      ? 'Finish'
                      : 'Next',
                  onPressed: _isVoteComplete ? _confirmNext : null,
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  // ─── VOTE REMAINING INDICATOR ───
  Widget _voteIndicator(double screenW) {
    final remaining = _votesRemaining;
    final String msg = remaining > 0
        ? '$remaining vote(s) remaining'
        : remaining < 0
            ? '${remaining.abs()} vote(s) too many'
            : 'All votes assigned!';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: screenW * 0.04,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────

  Widget _playerTile(String player, double screenW, double btnSize) {
    votes.putIfAbsent(questionIndex, () => {});
    final count = votes[questionIndex]![player] ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _voteButton(
            icon: Icons.remove,
            color: Colors.red,
            size: btnSize,
            onTap: () {
              setState(() {
                if (count > 0) votes[questionIndex]![player] = count - 1;
              });
            },
          ),
          Expanded(
            child: AutoSizeText(
              '$player\n$count',
              textAlign: TextAlign.center,
              maxLines: 2,
              minFontSize: 10,
              style: TextStyle(
                color: Colors.black,
                fontSize: screenW * 0.045,
              ),
            ),
          ),
          _voteButton(
            icon: Icons.add,
            color: Colors.green,
            size: btnSize,
            onTap: () {
              setState(() {
                votes[questionIndex]![player] = count + 1;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _voteButton({
    required IconData icon,
    required Color color,
    required double size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.55),
      ),
    );
  }

  // ─────────────────────────────────────────────

  void _confirmNext() async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => NotificationPopup(
        title: questionIndex == widget.questions.length - 1
            ? 'Finish Game'
            : 'Next Question',
        message: 'Are you sure?',
        buttonText: 'Yes',
        onClose: () => Navigator.pop(context, true),
      ),
    );

    if (res == true) _nextQuestion();
  }

  void _nextQuestion() {
    if (questionIndex == widget.questions.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TruthBombsReportScreen(
            questions: widget.questions,
            answers: votes,
            players: widget.players,
            language: language,
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
