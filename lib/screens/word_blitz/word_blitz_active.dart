// Copyright (c) 2026 Rami YOUNES - MIT License

import 'dart:async';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:onephone/data/word_blitz/word_blitz_word.dart';
import 'package:onephone/widgets/notification_popup.dart';
import 'package:onephone/widgets/language_popup.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_gradients.dart';
import '../../widgets/styled_button.dart';
import '../../models/word_blitz_result.dart';
import 'word_blitz_report.dart';

class WordBlitzActiveScreen extends StatefulWidget {
  final List<String> teamA;
  final List<String> teamB;
  final String teamAName;
  final String teamBName;
  final int numRounds;
  final int timerPerTurn;
  final bool manualWordSelection;
  final String language;

  const WordBlitzActiveScreen({
    super.key,
    required this.teamA,
    required this.teamB,
    required this.teamAName,
    required this.teamBName,
    required this.numRounds,
    required this.timerPerTurn,
    required this.manualWordSelection,
    required this.language,
  });

  @override
  State<WordBlitzActiveScreen> createState() => _WordBlitzActiveScreenState();
}

class _WordBlitzActiveScreenState extends State<WordBlitzActiveScreen> {
  late List<WordBlitzWord> originalPack;
  late List<WordBlitzWord> currentPack;

  int currentRound = 1;
  int currentTeamIndex = 0; // 0 = teamA, 1 = teamB
  int _packIndex = 0;
  Timer? _turnTimer;
  int remainingTime = 0;

  int _playerIndexA = 0;
  int _playerIndexB = -1;

  List<WordBlitzResult> results = [];

  bool _gameFinished = false;
  bool isPaused = false;

  // ---- audio assets ----
  String soundGotIt = 'sounds/correct.mp3';
  String soundTimerEnd = 'sounds/shot-clock.mp3';

  String language = 'en';

  @override
  void initState() {
    super.initState();
    _loadWords();
    _startNewRound();
  }

  void _loadWords() {
    originalPack = List<WordBlitzWord>.from(WordBlitzWord.words)..shuffle();
    originalPack = originalPack.take(35).toList();
  }

  void _startNewRound() {
    currentPack = List<WordBlitzWord>.from(originalPack);
    _packIndex = 0;
    _showRoundPopup();
  }

  void _showRoundPopup() {
    final teamName = currentTeamName;
    final playerName = currentPlayer;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            insetPadding: EdgeInsets.all(12),
            backgroundColor: Colors.white.withValues(alpha: 0.12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Round $currentRound",
                    style: TextStyle(
                      fontFamily: 'ChildstoneDemo',
                      fontSize: screenWidth * 0.06,
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenWidth * 0.03),
                  Text(
                    "${_roundDescription(currentRound)}",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: screenWidth * 0.042,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenWidth * 0.02),
                  Text(
                    "$teamName",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    "$playerName",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  SizedBox(
                    width: double.infinity,
                    child: StyledButton(
                      text: "GO",
                      onPressed: () {
                        Navigator.pop(context);
                        _startPlayerTurn();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  void _startPlayerTurn() {
    remainingTime = widget.timerPerTurn;
    _turnTimer?.cancel();
    _startTimer();
    setState(() {});
  }

  void _startTimer() {
    _turnTimer?.cancel();
    _turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted || _gameFinished) return;

      setState(() => remainingTime--);

      if (remainingTime <= 0) {
        _endTurn();

        await playSound(soundTimerEnd, wait: true);
      }
    });
  }

  WordBlitzWord? get currentWord =>
      currentPack.isNotEmpty ? currentPack[_packIndex] : null;

  String get currentTeamName =>
      currentTeamIndex == 0 ? widget.teamAName : widget.teamBName;

  String get currentPlayer => currentTeamIndex == 0
      ? widget.teamA[_playerIndexA]
      : widget.teamB[_playerIndexB];

  void _gotWord() async {
    if (currentWord == null || _gameFinished) return;

    final wordText = currentWord!.get(widget.language);
    results.add(
      WordBlitzResult(
        round: currentRound,
        team: currentTeamName,
        player: currentPlayer,
        word: wordText,
      ),
    );

    // Remove the word
    currentPack.removeAt(_packIndex);
    if (_packIndex >= currentPack.length) _packIndex = 0;

    await playSound(soundGotIt, wait: true);

    if (currentPack.isEmpty) {
      _endTurn(roundFinished: true);
    } else {
      setState(() {});
    }
  }

  void _skipWord() {
    if (currentWord == null || _gameFinished) return;

    _packIndex = (_packIndex + 1) % currentPack.length;
    setState(() {});
  }

  void _endTurn({bool roundFinished = false}) {
    _turnTimer?.cancel();

    if (currentTeamIndex == 0) {
      currentTeamIndex = 1;
      _playerIndexB = (_playerIndexB + 1) % widget.teamB.length;
    } else {
      currentTeamIndex = 0;
      _playerIndexA = (_playerIndexA + 1) % widget.teamA.length;
    }

    if (roundFinished) {
      if (currentRound < widget.numRounds) {
        setState(() => currentRound++);
        _startNewRound();
      } else {
        _gameFinished = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => WordBlitzReportScreen(
              results: results,
              teamAName: widget.teamAName,
              teamBName: widget.teamBName,
              pack: originalPack,
              language: widget.language,
            ),
          ),
        );
      }
      return;
    }

    _showRoundPopup();
  }

  String _roundDescription(int round) {
    switch (round) {
      case 1:
        return "Describe the word freely.";
      case 2:
        return "Use only ONE word.";
      case 3:
        return "Use gestures & sounds only!";
      default:
        return "";
    }
  }

  Future<void> playSound(String assetPath, {bool wait = false}) async {
    if (!mounted || _gameFinished) return;

    final player = AudioPlayer();
    try {
      await player.setSource(AssetSource(assetPath));
      await player.resume();
      if (wait) await player.onPlayerComplete.first;
    } catch (_) {
    } finally {
      player.dispose();
    }
  }

  @override
  void dispose() {
    _turnTimer?.cancel();
    super.dispose();
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
            _turnTimer?.cancel();
            Navigator.popUntil(context, (r) => r.isFirst);
          }
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppGradients.mainBackground),
        child: SafeArea(
          child: Column(
            children: [
              // ---------------------- TOP BAR ----------------------
              SizedBox(
                height: 60,
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        "Round $currentRound / ${widget.numRounds}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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
                            _turnTimer?.cancel();
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
                          Icons.pause_circle_filled,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: () async {
                          await _pauseGame();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ---------------------- ROUND INFO ----------------------
              Text(
                currentTeamName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenW * 0.09,
                  fontFamily: "ChildstoneDemo",
                ),
              ),
              Text(
                currentPlayer,
                style: TextStyle(
                  fontSize: screenW * 0.06,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 30),

              // ---------------------- CURRENT WORD ----------------------
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: screenW * 0.1),
                    margin: EdgeInsets.symmetric(horizontal: screenW * 0.14),
                    child: AutoSizeText(
                      currentWord?.get(language) ?? '',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      minFontSize: 10,
                      stepGranularity: 1,
                      style: TextStyle(
                        color: AppColors.goldDark,
                        fontSize: screenW * 0.12,
                        fontFamily: "ChildstoneDemo",
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Positioned(
                    right: 8,
                    top: 8,
                    child: IconButton(
                      icon: const Icon(Icons.translate, color: Colors.white),
                      onPressed: _selectLanguage,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ---------------------- TIMER ----------------------
              Center(
                child: Text(
                  '${remainingTime.clamp(0, 999)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenW * 0.4,
                    color: AppColors.goldDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Spacer(),

              // ---------------------- BUTTONS ----------------------
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: StyledButton(text: "Skip", onPressed: _skipWord),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StyledButton(text: "Got it!", onPressed: _gotWord),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      ),
    );
  }

  void _selectLanguage() async {
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (_) => LanguagePopup(
        selectedLanguage: language,
        onSelected: (l) {
          setState(() => language = l);
        },
      ),
    );
  }

  // ------------------- PAUSE / EXIT LOGIC -------------------
  Future<void> _pauseGame() async {
    if (isPaused) return;

    setState(() => isPaused = true);

    _turnTimer?.cancel();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => NotificationPopup(
        title: 'Paused',
        message: 'Game is paused.',
        buttonText: 'Resume',
        onClose: () {
          Navigator.pop(context);
          _resumeGame();
        },
      ),
    );
  }

  void _resumeGame() {
    if (!isPaused) return;

    setState(() => isPaused = false);
    _startTimer();
  }

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
}
