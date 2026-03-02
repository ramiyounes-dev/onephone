// Copyright (c) 2026 Rami YOUNES - MIT License

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../models/hot_potato_player_result.dart';
import '../../theme/app_gradients.dart';
import '../../theme/app_colors.dart';
import '../../widgets/notification_popup.dart';
import '../../widgets/round_settings_popup.dart';
import 'hot_potato_report.dart';

class HotPotatoActiveScreen extends StatefulWidget {
  final List<String> players;
  final int timerSeconds;

  const HotPotatoActiveScreen({
    required this.players,
    required this.timerSeconds,
    super.key,
  });

  @override
  State<HotPotatoActiveScreen> createState() => _HotPotatoActiveScreenState();
}

class _HotPotatoActiveScreenState extends State<HotPotatoActiveScreen> {
  late List<String> remainingPlayers;
  late int roundTimer;
  late int roundInitialTimer;

  Timer? _roundTicker;

  late PageController _pageController;
  int currentPlayerIndex = 0;
  bool isPaused = false;

  final AudioPlayer _beepPlayer = AudioPlayer();
  final String beepAsset = 'sounds/time-5sec-bomb.mp3';

  bool _beepStarted = false;
  bool _beepWasPlaying = false;

  final List<HotPotatoPlayerResult> roundHistory = [];
  int roundNumber = 1;

  @override
  void initState() {
    super.initState();
    remainingPlayers = List.from(widget.players);
    roundInitialTimer = widget.timerSeconds;
    roundTimer = widget.timerSeconds;

    _pageController = PageController(initialPage: currentPlayerIndex);
    _beepPlayer.setReleaseMode(ReleaseMode.loop);

    _startRoundTicker();
  }

  void _startRoundTicker() {
    _roundTicker?.cancel();
    isPaused = false;

    _roundTicker = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (isPaused) return;

      if (roundTimer < 0) {
        _eliminateCurrentPlayer();
        _stopRoundTicker();
        return;
      }

      // Start the countdown beep when 2+5 seconds remain
      if (roundTimer == 7 && !_beepStarted) {
        _beepStarted = true;
        _startBeep();
      }

      setState(() => roundTimer--);
    });
  }

  void _stopRoundTicker() {
    _roundTicker?.cancel();
    _stopBeep();
  }

  // -----------------------
  // Swipe
  // -----------------------
  void _swipeNext() {
    if (remainingPlayers.isEmpty) return;
    HapticFeedback.heavyImpact();

    setState(() {
      currentPlayerIndex = (currentPlayerIndex + 1) % remainingPlayers.length;
    });

    _pageController.animateToPage(
      currentPlayerIndex,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _swipePrevious() {
    if (remainingPlayers.isEmpty) return;
    HapticFeedback.heavyImpact();

    setState(() {
      currentPlayerIndex =
          (currentPlayerIndex - 1 + remainingPlayers.length) %
          remainingPlayers.length;
    });

    _pageController.animateToPage(
      currentPlayerIndex,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  // -----------------------
  // Sounds
  // -----------------------
  Future<void> _startBeep() async {
    try {
      await _beepPlayer.setReleaseMode(ReleaseMode.loop);
      _beepWasPlaying = true;
      await _beepPlayer.play(AssetSource(beepAsset));
    } catch (_) {}
  }

  Future<void> _stopBeep() async {
    try {
      _beepWasPlaying = false;
      await _beepPlayer.stop();
    } catch (_) {}
  }

  // -----------------------
  // Elimination & next round
  // -----------------------
  void _eliminateCurrentPlayer() async {
    if (remainingPlayers.isEmpty) return;

    final eliminated = remainingPlayers[currentPlayerIndex];

    // Record using the initial timer for the round, not the decremented value
    roundHistory.add(
      HotPotatoPlayerResult(
        name: eliminated,
        round: roundNumber,
        timerSeconds: roundInitialTimer,
      ),
    );

    await _showPlayerOutPopup(eliminated);

    setState(() {
      remainingPlayers.removeAt(currentPlayerIndex);
      if (currentPlayerIndex >= remainingPlayers.length &&
          remainingPlayers.isNotEmpty) {
        currentPlayerIndex = 0;
      }
    });

    if (remainingPlayers.length == 1) {
      final last = remainingPlayers.first;
      roundHistory.add(
        HotPotatoPlayerResult(
          name: last,
          round: roundNumber,
          timerSeconds: roundInitialTimer,
        ),
      );

      await _showWinnerPopup(last);
      _goToReport();
      return;
    }

    await _showNextRoundSettings();

    roundNumber++;
    roundTimer = roundInitialTimer;
    _beepStarted = false;
    _startRoundTicker();

    _pageController.jumpToPage(currentPlayerIndex);
  }

  // -----------------------
  // Popups
  // -----------------------
  Future<void> _showPlayerOutPopup(String playerName) async {
    await showDialog(
      context: context,
      builder: (_) => NotificationPopup(
        title: 'Player Out!',
        message: '$playerName is out!',
        buttonText: 'Continue',
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  Future<void> _showNextRoundSettings() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RoundSettingsPopup(
        currentTimer: roundInitialTimer,
        playerName: remainingPlayers[currentPlayerIndex],
        onSelected: (timer) {
          setState(() {
            roundInitialTimer = timer;
            roundTimer = timer;
          });
        },
      ),
    );
  }

  Future<void> _showWinnerPopup(String winner) async {
    await showDialog(
      context: context,
      builder: (_) => NotificationPopup(
        title: 'Winner!',
        message: winner,
        buttonText: 'Continue',
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  // -----------------------
  // Pause / Resume
  // -----------------------
  Future<void> _pauseGame() async {
    if (isPaused) return;
    setState(() => isPaused = true);

    _roundTicker?.cancel();

    if (_beepWasPlaying) await _beepPlayer.pause();

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

    if (_beepWasPlaying) _beepPlayer.resume();

    _startRoundTicker();
  }

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

  void _goToReport() {
    _stopRoundTicker();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HotPotatoReportScreen(results: roundHistory),
      ),
    );
  }

  @override
  void dispose() {
    _roundTicker?.cancel();
    _beepPlayer.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final halfH = MediaQuery.of(context).size.height / 2;

    if (remainingPlayers.isEmpty) return const SizedBox.shrink();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final leave = await _confirmExit();
          if (leave && mounted) {
            _stopRoundTicker();
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
              // TOP HALF - countdown timer
              SizedBox(
                height: halfH,
                width: double.infinity,
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        '${roundTimer.clamp(0, 999)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenW * 0.4,
                          color: AppColors.goldDark,
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
                            _stopRoundTicker();
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
                          size: 36,
                        ),
                        onPressed: _pauseGame,
                      ),
                    ),
                  ],
                ),
              ),

              // BOTTOM HALF - current player name, swipeable
              Expanded(
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: remainingPlayers.length,
                      itemBuilder: (context, index) {
                        final player = remainingPlayers[index];
                        return Center(
                          child: FractionallySizedBox(
                            widthFactor: 0.9,
                            child: Text(
                              player,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: screenW * 0.22,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Text(
                        'Swipe >>',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: Text(
                        '<< Swipe',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                    Positioned.fill(
                      child: GestureDetector(
                        onHorizontalDragEnd: (details) {
                          final v = details.primaryVelocity ?? 0;
                          if (v > 0) _swipePrevious();
                          if (v < 0) _swipeNext();
                        },
                      ),
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
