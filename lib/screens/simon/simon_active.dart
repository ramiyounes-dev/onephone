import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:onephone/theme/app_gradients.dart';
import 'package:onephone/theme/app_colors.dart';
import 'package:onephone/widgets/notification_popup.dart';
import 'package:onephone/widgets/styled_button.dart';
import 'simon_report.dart';

// Copyright (c) 2026 Rami YOUNES - MIT License

class SimonActiveScreen extends StatefulWidget {
  final List<String> players;
  final int totalRounds;

  const SimonActiveScreen({
    super.key,
    required this.players,
    required this.totalRounds,
  });

  @override
  State<SimonActiveScreen> createState() => _SimonActiveScreenState();
}

class _SimonActiveScreenState extends State<SimonActiveScreen>
    with TickerProviderStateMixin {
  int currentRound = 1;
  int currentPlayerIndex = 0;

  Map<String, List<int>> playerScores = {}; // per player per round
  Map<String, List<int>> playerSequences = {}; // independent sequences

  List<int> userInput = [];
  bool inputEnabled = false;
  bool simonPlaying = false;
  int currentStep = -1; // which button is active
  late AudioPlayer _correctPlayer;
  late AudioPlayer _errorPlayer;

  late AnimationController glowController;

  @override
  void initState() {
    super.initState();
    glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    for (var p in widget.players) {
      playerScores[p] = List.generate(widget.totalRounds, (_) => 0);
      playerSequences[p] = [];
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      _showRoundPopup();
    });
    _correctPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    _errorPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

    _correctPlayer.setSource(AssetSource('sounds/correct.mp3'));
    _errorPlayer.setSource(AssetSource('sounds/incorrect.mp3'));
  }

  @override
  void dispose() {
    glowController.dispose();
    super.dispose();
  }

  /// Show the popup at the start of a player's turn
  void _showTurnPopup() {
    String player = widget.players[currentPlayerIndex];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.transparent,
          child: Dialog(
            insetPadding: const EdgeInsets.all(12),
            backgroundColor: Colors.white.withValues(alpha: 0.12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth:
                    MediaQuery.of(context).size.width * 0.38,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AutoSizeText(
                      player,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      minFontSize: 10,
                      style: const TextStyle(
                        fontSize: 28,
                        fontFamily: 'ChildstoneDemo',
                        color: AppColors.goldDark,
                      ),
                    ),
                    const SizedBox(height: 20),
                    StyledButton(
                      text: "Go",
                      onPressed: () {
                        Navigator.of(context).pop();
                        _startOrContinueTurn();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Start or continue the current player's turn
  void _startOrContinueTurn() async {
    String player = widget.players[currentPlayerIndex];
    inputEnabled = false;
    simonPlaying = true;
    userInput.clear();

    if (playerSequences[player]!.isEmpty) {
      playerSequences[player]!.add(Random().nextInt(4));
    }

    await _playSequence(playerSequences[player]!);

    setState(() {
      inputEnabled = true;
      simonPlaying = false;
      currentStep = -1;
    });
  }

  Future<void> _playSequence(List<int> sequence) async {
    await Future.delayed(const Duration(milliseconds: 500)); // anticipation

    for (int i = 0; i < sequence.length; i++) {
      int index = sequence[i];

      setState(() => currentStep = index); // highlight button
      await Future.delayed(const Duration(milliseconds: 400));
      setState(() => currentStep = -1); // remove highlight
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void _onButtonPressStart(int index) {
    if (!inputEnabled || simonPlaying) return;

    setState(() => currentStep = index);
  }

  void _onButtonPressEnd(int index) {
    if (!inputEnabled || simonPlaying) return;
    setState(() => currentStep = -1);
    _registerButtonTap(index);
  }

  /// Actual input logic after release
  void _registerButtonTap(int index) {
    userInput.add(index);
    String player = widget.players[currentPlayerIndex]!;
    int lastIndex = userInput.length - 1;

    if (userInput[lastIndex] != playerSequences[player]![lastIndex]) {
      _playToneError();
      _endTurn();
      return;
    }

    if (userInput.length == playerSequences[player]!.length) {
      _playToneCorrect();
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        playerSequences[player]!.add(Random().nextInt(4));
        _startOrContinueTurn();
      });
    }
  }

  void _playToneCorrect() {
    _correctPlayer.resume();
  }

  void _playToneError() {
    _errorPlayer.resume();
  }

  /// End turn
  void _endTurn() {
    inputEnabled = false;
    String player = widget.players[currentPlayerIndex];
    playerScores[player]![currentRound - 1] =
        playerSequences[player]!.length - 1;
    _advanceGameFlow();
  }

  void _advanceGameFlow() {
    currentPlayerIndex++;

    if (currentPlayerIndex >= widget.players.length) {
      currentPlayerIndex = 0;
      currentRound++;

      if (currentRound > widget.totalRounds) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SimonReportScreen(scores: playerScores),
          ),
        );
        return;
      }

      for (var p in widget.players) {
        playerSequences[p] = [];
      }

      _showRoundPopup();
    } else {
      if (widget.players.length > 1) {
        _showTurnPopup();
      } else {
        _startOrContinueTurn();
      }
    }
  }

  void _showRoundPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.transparent,
          child: Dialog(
            insetPadding: const EdgeInsets.all(12),
            backgroundColor: Colors.white.withValues(alpha: 0.12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.48,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Round $currentRound",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 30,
                        fontFamily: 'ChildstoneDemo',
                        color: AppColors.goldDark,
                      ),
                    ),
                    const SizedBox(height: 20),
                    StyledButton(
                      text: "Start",
                      onPressed: () {
                        Navigator.pop(context);
                        if (widget.players.length > 1) {
                          _showTurnPopup();
                        } else {
                          _startOrContinueTurn();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double W = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          inputEnabled = false;
          final leave = await _confirmExit();
          if (leave && mounted) {
            Navigator.popUntil(context, (r) => r.isFirst);
          }
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AppGradients.mainBackground.begin,
            end: AppGradients.mainBackground.end,
            colors: AppGradients.mainBackground.colors
                .map((c) => c.withValues(alpha: 0.8))
                .toList(),
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Round $currentRound / ${widget.totalRounds}',
                    style: TextStyle(
                      fontFamily: 'ChildstoneDemo',
                      fontSize: W * 0.065,
                      color: AppColors.goldDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.players[currentPlayerIndex],
                    style: TextStyle(
                      fontFamily: 'ChildstoneDemo',
                      fontSize: W * 0.06,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Level ${userInput.length + 1}',
                    style: TextStyle(
                      fontFamily: 'ChildstoneDemo',
                      fontSize: W * 0.05,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(child: Center(child: _buildSimonButtons(W))),
                  const SizedBox(height: 30),
                ],
              ),
              Positioned(
                left: 8,
                top: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () async {
                    inputEnabled = false;
                    final leave = await _confirmExit();
                    if (leave && mounted) {
                      Navigator.popUntil(context, (r) => r.isFirst);
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

  Widget _buildSimonButtons(double screenW) {
    final size = screenW * 0.8;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          _simonButton(
            0,
            const Color.fromARGB(255, 0, 255, 8),
            Alignment.topCenter,
            HouseDirection.down,
          ),
          _simonButton(
            1,
            const Color.fromARGB(255, 255, 235, 59),
            Alignment.centerLeft,
            HouseDirection.right,
          ),
          _simonButton(
            2,
            const Color.fromARGB(255, 255, 0, 0),
            Alignment.centerRight,
            HouseDirection.left,
          ),
          _simonButton(
            3,
            const Color.fromARGB(255, 174, 0, 255),
            Alignment.bottomCenter,
            HouseDirection.up,
          ),
        ],
      ),
    );
  }

  Widget _simonButton(
    int index,
    Color color,
    Alignment alignment,
    HouseDirection direction,
  ) {
    final size = MediaQuery.of(context).size.width * 0.38;

    return Align(
      alignment: alignment,
      child: GestureDetector(
        onTapDown: (_) => _onButtonPressStart(index),
        onTapUp: (_) => _onButtonPressEnd(index),
        onTapCancel: () => _onButtonPressEnd(index),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              CustomPaint(
                painter: HouseBorderPainter(
                  direction: direction,
                  borderColor: const Color.fromARGB(
                    255,
                    53,
                    46,
                    46,
                  ).withValues(alpha: 0.35),
                  borderWidth: 3,
                  shadowColor: Colors.black.withValues(alpha: 0.8),
                  shadowBlur: 12,
                ),
                child: Container(),
              ),
              ClipPath(
                clipper: HouseButtonClipper(direction: direction),
                child: AnimatedBuilder(
                  animation: glowController,
                  builder: (_, __) {
                    bool isGlowing = currentStep == index;
                    return Container(
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: isGlowing ? 1 : 0.3),
                        boxShadow: isGlowing
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.4),
                                  blurRadius: 25,
                                  spreadRadius: 10,
                                ),
                              ]
                            : [],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---- Custom Clipper for House-Shaped Buttons ----
enum HouseDirection { up, down, left, right }

class HouseButtonClipper extends CustomClipper<Path> {
  final HouseDirection direction;

  HouseButtonClipper({required this.direction});

  @override
  Path getClip(Size size) {
    final double w = size.width;
    final double h = size.height;

    final double triH = h * 0.5;
    final double triW = w * 0.5;

    final Path path = Path();

    switch (direction) {
      case HouseDirection.up:
        path
          ..moveTo(0, triH)
          ..lineTo(w / 2, 0)
          ..lineTo(w, triH)
          ..lineTo(w, h)
          ..lineTo(0, h)
          ..close();
        break;
      case HouseDirection.down:
        path
          ..moveTo(0, 0)
          ..lineTo(w, 0)
          ..lineTo(w, h - triH)
          ..lineTo(w / 2, h)
          ..lineTo(0, h - triH)
          ..close();
        break;
      case HouseDirection.left:
        path
          ..moveTo(triW, 0)
          ..lineTo(w, 0)
          ..lineTo(w, h)
          ..lineTo(triW, h)
          ..lineTo(0, h / 2)
          ..close();
        break;
      case HouseDirection.right:
        path
          ..moveTo(0, 0)
          ..lineTo(w - triW, 0)
          ..lineTo(w, h / 2)
          ..lineTo(w - triW, h)
          ..lineTo(0, h)
          ..close();
        break;
    }

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class HouseBorderPainter extends CustomPainter {
  final HouseDirection direction;
  final Color borderColor;
  final double borderWidth;
  final Color shadowColor;
  final double shadowBlur;

  HouseBorderPainter({
    required this.direction,
    required this.borderColor,
    required this.borderWidth,
    required this.shadowColor,
    required this.shadowBlur,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final clipper = HouseButtonClipper(direction: direction);
    final path = clipper.getClip(size);

    canvas.drawShadow(path, shadowColor, shadowBlur, true);

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
