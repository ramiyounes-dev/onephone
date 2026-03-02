// Copyright (c) 2026 Rami YOUNES - MIT License

import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:onephone/models/charades_word.dart';
import 'package:onephone/theme/app_gradients.dart';
import 'package:onephone/widgets/language_popup.dart';

import '../../widgets/notification_popup.dart';
import '../../widgets/styled_button.dart';
import '../../widgets/frosted_popup.dart';
import '../../theme/app_colors.dart';
import '../../models/charades_game_result.dart';
import '../../data/charades/charades_words.dart';
import 'charades_report.dart';

class CharadesActiveScreen extends StatefulWidget {
  final List<String> teamA;
  final List<String> teamB;
  final String teamAName;
  final String teamBName;
  final List<String> categories;
  final int numRounds;
  final int timerPerTurn;
  final bool manualWordSelection;

  const CharadesActiveScreen({
    required this.teamA,
    required this.teamB,
    required this.teamAName,
    required this.teamBName,
    required this.categories,
    required this.numRounds,
    required this.timerPerTurn,
    required this.manualWordSelection,
    super.key,
  });

  @override
  State<CharadesActiveScreen> createState() => _CharadesActiveScreenState();
}

class _CharadesActiveScreenState extends State<CharadesActiveScreen> {
  // ---- GAME PROGRESSION ----
  int _currentRound = 1; // 1..numRounds
  int _turnInRound = 1; // 1 = teamA turn, 2 = teamB turn
  int _playerIndexA = 0;
  int _playerIndexB = 0;

  // ---- CURRENT TURN INFO ----
  String _currentTeam = "";
  String _opposingTeam = "";
  String _currentPlayer = "";
  String _currentWord = "";
  int _currentPoints = 1;

  // ---- TIMER ----
  Timer? _turnTimer;
  int _remainingTime = 0;

  // ---- RESULTS STORAGE ----
  final List<CharadesGameResult> _results = [];

  bool isPaused = false;

  bool _shotClockPlayed = false;
  final Set<String> _usedWords = {};
  bool _turnInitialized = false;
  String language = 'en';
  bool _gameFinished = false;

  String startBell = 'sounds/start-box-bell.mp3';
  String correct = 'sounds/correct.mp3';
  String incorrect = 'sounds/incorrect.mp3';
  String shotClock = 'sounds/shot-clock.mp3';

  @override
  void initState() {
    super.initState();

    // Delay the first turn until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_turnInitialized) {
        _turnInitialized = true;
        _startTurn();
      }
    });
  }

  // --------------------------------------------------------
  //                     TURN START
  // --------------------------------------------------------
  Future<void> _startTurn() async {
    if (!mounted || _gameFinished) return;

    if (_currentRound > widget.numRounds) {
      _finishGame();
      return;
    }
    _shotClockPlayed = false;

    // determine which team plays
    if (_turnInRound == 1) {
      _currentTeam = widget.teamAName;
      _opposingTeam = widget.teamBName;
      _currentPlayer = widget.teamA[_playerIndexA];
      _playerIndexA = (_playerIndexA + 1) % widget.teamA.length;
    } else {
      _currentTeam = widget.teamBName;
      _opposingTeam = widget.teamAName;
      _currentPlayer = widget.teamB[_playerIndexB];
      _playerIndexB = (_playerIndexB + 1) % widget.teamB.length;
    }

    // Show popup before turn starts
    await _showTurnPopup();

    // select a word BEFORE timer starts
    if (widget.manualWordSelection) {
      _currentWord = await _manualWordPopup(
        opposingTeamName: _opposingTeam,
      );
      _currentPoints = 1;
    } else {
      final data = await _chooseWordFromDatabase();
      _currentWord = data["word"];
      _currentPoints = data["points"];
    }
    _usedWords.add(_currentWord.toLowerCase().trim());

    // now start the timer AFTER selection
    _remainingTime = widget.timerPerTurn;
    _startTimer();

    await playSound(startBell, wait: true);

    if (!mounted || _gameFinished) return;

    setState(() {});
  }

  // --------------------------------------------------------
  //                     TIMER LOGIC
  // --------------------------------------------------------
  void _startTimer() {
    _turnTimer?.cancel();
    _turnTimer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!mounted || _gameFinished) {
        t.cancel();
        return;
      }

      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
        return;
      }

      // time hit zero
      if (!_shotClockPlayed) {
        _shotClockPlayed = true;

        // BEFORE awaiting audio:
        if (!mounted || _gameFinished) return;

        await playSound(shotClock, wait: true);

        if (!mounted || _gameFinished) return;

        _endTurn(found: false);
      }
    });
  }

  Future<void> _showTurnPopup() async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: FrostedPopup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$_currentTeam",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "$_currentPlayer",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              StyledButton(text: "GO", onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------
  //                     END TURN
  // --------------------------------------------------------
  void _endTurn({required bool found}) {
    if (_gameFinished) return;

    _turnTimer?.cancel();

    final word = _currentWord;

    _results.add(
      CharadesGameResult(
        round: _currentRound,
        teamName: _currentTeam,
        playerName: _currentPlayer,
        word: word,
        points: found ? _currentPoints : 0,
        usedTime: widget.timerPerTurn - _remainingTime,
        remainingTime: _remainingTime,
      ),
    );

    // next turn
    if (_turnInRound == 1) {
      _turnInRound = 2;
    } else {
      _turnInRound = 1;
      _currentRound++;
    }

    if (_currentRound > widget.numRounds) {
      _finishGame();
      return;
    }

    _showWordRevealPopup(word, found);
  }

  Future<void> _showWordRevealPopup(String word, bool found) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => FrostedPopup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Text(
              found ? 'Correct!' : 'Time\'s up!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: found ? Colors.greenAccent : Colors.redAccent,
                fontSize: 18,
                fontFamily: 'ChildstoneDemo',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'The word was',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontFamily: 'ChildstoneDemo',
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AutoSizeText(
                word,
                textAlign: TextAlign.center,
                maxLines: 1,
                minFontSize: 14,
                style: const TextStyle(
                  color: AppColors.goldDark,
                  fontSize: 32,
                  fontFamily: 'ChildstoneDemo',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: StyledButton(
                text: 'Next',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );

    if (mounted) _startTurn();
  }

  // --------------------------------------------------------
  //                 MANUAL WORD POPUP
  // --------------------------------------------------------
  Future<String> _manualWordPopup({
    required String opposingTeamName,
    int minChars = 2,
    int maxChars = 20,
  }) async {
    final controller = TextEditingController();

    Future<void> showError(String msg) async {
      await showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: FrostedPopup(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  msg,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                StyledButton(
                  text: "OK",
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: FrostedPopup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$opposingTeamName chooses a word",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              TextField(
                controller: controller,
                autofocus: true,
                maxLength: maxChars,
                maxLines: 1,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Enter the secret word...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white30),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              StyledButton(
                text: "Validate",
                onPressed: () async {
                  final text = controller.text.trim();

                  if (text.length < minChars) {
                    await showError(
                      "Word must be at least $minChars characters.",
                    );
                    return;
                  }

                  if (text.length > maxChars) {
                    await showError("Word must be under $maxChars characters.");
                    return;
                  }

                  Navigator.pop(context, text);
                },
              ),
            ],
          ),
        ),
      ),
    );

    return (result == null || result.trim().isEmpty)
        ? "Unknown Word"
        : result.trim();
  }

  Future<void> playSound(String assetPath, {bool wait = false}) async {
    if (_gameFinished || !mounted) return;

    final player = AudioPlayer();

    try {
      await player.setSource(AssetSource(assetPath));
      await player.resume();

      if (wait) {
        await player.onPlayerComplete.first;
      }
    } catch (_) {
      // prevent audio crashes
    } finally {
      player.dispose();
    }
  }

  // --------------------------------------------------------
  //              DATABASE WORD SELECTION POPUP
  // --------------------------------------------------------
  Future<Map<String, dynamic>> _chooseWordFromDatabase() async {
    final rnd = Random();

    // Filter words by selected categories and not used yet
    final filtered = charadesWordsDB
        .where((w) => w.categories.any((c) => widget.categories.contains(c)))
        .where((w) => !_usedWords.contains(w.en.toLowerCase().trim()))
        .toList();

    if (filtered.isEmpty) {
      return {"word": "No more words", "points": 1};
    }

    // Helper to pick a random word by difficulty
    Map<String, dynamic> pick(String difficulty, int points) {
      final list = filtered
          .where((w) => w.difficulty.toLowerCase() == difficulty)
          .toList();

      final chosen = list.isNotEmpty
          ? list[rnd.nextInt(list.length)]
          : filtered[rnd.nextInt(filtered.length)];

      return {"wordObj": chosen, "points": points};
    }

    final easy = pick("easy", 1);
    final medium = pick("medium", 2);
    final hard = pick("hard", 3);

    Map<String, dynamic> chosen = {};

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setPopupState) {
          // local popup language
          String popupLanguage = language;

          String getWord(CharadesWord w) {
            switch (popupLanguage) {
              case 'fr':
                return w.fr;
              case 'ar':
                return w.ar;
              default:
                return w.en;
            }
          }

          void _selectLanguage() {
            showDialog(
              context: context,
              builder: (_) => LanguagePopup(
                selectedLanguage: popupLanguage,
                onSelected: (l) {
                  setPopupState(() => popupLanguage = l);
                  setState(() => language = l); // update global language state
                },
              ),
            );
          }

          return FrostedPopup(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Choose your word",
                      style: TextStyle(
                        color: AppColors.goldDark,
                        fontSize: 18,
                        fontFamily: 'ChildstoneDemo',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.translate, color: Colors.white),
                      onPressed: _selectLanguage,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                StyledButton(
                  text: "${getWord(easy['wordObj'])} (+${easy['points']} pts)",
                  autoSize: true,
                  onPressed: () {
                    chosen = {
                      "word": getWord(easy['wordObj']),
                      "points": easy['points'],
                    };
                    _usedWords.add(
                      getWord(easy['wordObj']).toLowerCase().trim(),
                    );
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 8),
                StyledButton(
                  text:
                      "${getWord(medium['wordObj'])} (+${medium['points']} pts)",
                  autoSize: true,
                  onPressed: () {
                    chosen = {
                      "word": getWord(medium['wordObj']),
                      "points": medium['points'],
                    };
                    _usedWords.add(
                      getWord(medium['wordObj']).toLowerCase().trim(),
                    );
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 8),
                StyledButton(
                  text: "${getWord(hard['wordObj'])} (+${hard['points']} pts)",
                  autoSize: true,
                  onPressed: () {
                    chosen = {
                      "word": getWord(hard['wordObj']),
                      "points": hard['points'],
                    };
                    _usedWords.add(
                      getWord(hard['wordObj']).toLowerCase().trim(),
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );

    return chosen;
  }

  // --------------------------------------------------------
  //                        POPUPS
  // --------------------------------------------------------
  Future<bool> _confirm(String action) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: FrostedPopup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Title ---
              Text(
                "Are you sure you want to $action?",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // --- Buttons ---
              Row(
                children: [
                  Expanded(
                    child: StyledButton(
                      text: "Cancel",
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StyledButton(
                      text: "Yes",
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return result ?? false;
  }

  Future<void> _peekWord() async {
    if (!await _confirm("peek")) return;

    _turnTimer?.cancel();

    await showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Dialog(
            backgroundColor: Colors.white.withValues(alpha: 0.20),
            insetPadding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Word",
                    style: TextStyle(
                      fontSize: 22,
                      color: AppColors.goldDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    _currentWord,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Close",
                      style: TextStyle(color: AppColors.goldDark, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    _startTimer();
  }

  void _showScores() {
    _turnTimer?.cancel();

    final scoreA = _results
        .where((r) => r.teamName == widget.teamAName)
        .fold(0, (s, r) => s + r.points);

    final scoreB = _results
        .where((r) => r.teamName == widget.teamBName)
        .fold(0, (s, r) => s + r.points);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Dialog(
            backgroundColor: Colors.white.withValues(alpha: 0.20),
            insetPadding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Scores",
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    "${widget.teamAName}: $scoreA",
                    style: const TextStyle(
                      fontSize: 20,
                      color: AppColors.goldDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${widget.teamBName}: $scoreB",
                    style: const TextStyle(
                      fontSize: 20,
                      color: AppColors.goldDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Close",
                      style: TextStyle(color: AppColors.goldDark, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    _startTimer();
  }

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

  void _stopTimer() {
    _turnTimer?.cancel();
  }

  // --------------------------------------------------------
  //                        END OF GAME
  // --------------------------------------------------------
  void _finishGame() {
    if (_gameFinished) return; // avoid double-trigger
    _gameFinished = true;

    _turnTimer?.cancel();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CharadesReportScreen(
          results: _results,
          teamAName: widget.teamAName,
          teamBName: widget.teamBName,
          categories: widget.categories,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _turnTimer?.cancel();
    super.dispose();
  }

  // --------------------------------------------------------
  //                          UI
  // --------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final leave = await _confirmExit();
          if (leave && mounted) {
            _stopTimer();
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
              // TOP BAR
              SizedBox(
                height: 60,
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        "Round $_currentRound / ${widget.numRounds}",
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
                            _stopTimer();
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

              // ROUND INFO & TIMER
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    Center(
                      child: SizedBox(
                        width:
                            MediaQuery.of(context).size.width *
                            0.80,
                        child: AutoSizeText(
                          "$_currentTeam\n$_currentPlayer",
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          minFontSize: 40,
                          maxFontSize: 60,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                    Center(
                      child: Text(
                        '${_remainingTime.clamp(0, 999)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenW * 0.4,
                          color: AppColors.goldDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: MediaQuery.of(context).size.width * 0.90,
                height: MediaQuery.of(context).size.height * 0.18,
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 3,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    StyledButton(text: "Peek", onPressed: _peekWord),
                    StyledButton(text: "Score", onPressed: _showScores),
                    StyledButton(
                      text: "Give Up",
                      color: Colors.red,
                      onPressed: () async {
                        if (await _confirm("Give Up")) {
                          await playSound(incorrect, wait: true);
                          _endTurn(found: false);
                        }
                      },
                    ),
                    StyledButton(
                      text: "Found",
                      color: Colors.green,
                      onPressed: () async {
                        if (await _confirm("mark Found")) {
                          await playSound(correct, wait: true);
                          _endTurn(found: true);
                        }
                      },
                    ),
                    
                  ],
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
