// Copyright (c) 2026 Rami YOUNES - MIT License

import 'dart:async';
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_gradients.dart';
import '../../models/spin_the_bottle_result.dart';
import '../../widgets/notification_popup.dart';
import '../../widgets/vote_popup.dart';
import '../../widgets/styled_button.dart';
import 'spin_the_bottle_report.dart';

enum SpinPhase { spinChoice, actionChoice }

class SpinTheBottleActiveScreen extends StatefulWidget {
  final List<String> players;
  final int maxRounds;

  const SpinTheBottleActiveScreen({
    required this.players,
    required this.maxRounds,
    super.key,
  });

  @override
  State<SpinTheBottleActiveScreen> createState() =>
      _SpinTheBottleActiveScreenState();
}

class _SpinTheBottleActiveScreenState extends State<SpinTheBottleActiveScreen>
    with SingleTickerProviderStateMixin {
  final Random _rand = Random();
  final AudioPlayer _audioPlayer = AudioPlayer();

  late List<String> remainingPlayers;
  late String asker;
  late String target;

  int round = 1;
  SpinPhase phase = SpinPhase.spinChoice;

  final List<SpinTheBottleResult> results = [];

  late AnimationController _spinController;
  late Animation<double> _rotationAnim;

  Timer? _shuffleTimer;
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();

    if (widget.players.length < 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
      return;
    }

    remainingPlayers = List.from(widget.players);
    _pickInitialPair();

    _spinController = AnimationController(vsync: this);
    _rotationAnim = AlwaysStoppedAnimation(0.0);

    _audioPlayer.setSource(AssetSource('sounds/bottle-spin.mp3'));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _spinAskerOnly();
    });
  }

  @override
  void dispose() {
    _spinController.dispose();
    _audioPlayer.dispose();
    _shuffleTimer?.cancel();
    super.dispose();
  }

  void _pickInitialPair() {
    final shuffled = List<String>.from(remainingPlayers)..shuffle();
    asker = shuffled[0];
    target = shuffled[1];
  }

  Future<void> _spinAskerOnly() async {
    if (_isSpinning) return;

    final candidates = remainingPlayers.where((p) => p != target).toList();
    if (candidates.length <= 1) return;

    setState(() => _isSpinning = true);

    final finalAsker = candidates.where((p) => p != asker).toList()..shuffle();

    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource('sounds/bottle-spin.mp3'));

    final duration =
        await _audioPlayer.getDuration() ?? const Duration(seconds: 4);

    final int turns = 6 + _rand.nextInt(5);
    final double totalAngle = -2 * pi * turns;

    _spinController.duration = duration;

    _rotationAnim = Tween<double>(begin: 0, end: totalAngle).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeOutCubic),
    );

    _shuffleTimer?.cancel();
    _shuffleTimer = Timer.periodic(const Duration(milliseconds: 90), (_) {
      setState(() {
        asker = finalAsker[_rand.nextInt(finalAsker.length)];
      });
    });

    await Future.delayed(const Duration(milliseconds: 120));

    _spinController
      ..reset()
      ..forward();

    await Future.delayed(duration);

    _shuffleTimer?.cancel();

    setState(() {
      asker = finalAsker.first;
      _isSpinning = false;
    });
  }

  void _advanceRound({bool skipVote = false}) {
    if (skipVote) {
      results.add(
        SpinTheBottleResult(
          round: round,
          asker: asker,
          target: target,
          eliminated: null,
          outPercentage: null,
        ),
      );
    }

    if (round >= widget.maxRounds || remainingPlayers.length <= 1) {
      _endGame();
      return;
    }

    setState(() {
      round++;
      target = asker;
      final others = remainingPlayers.where((p) => p != target).toList()
        ..shuffle();
      asker = others.first;
      phase = SpinPhase.spinChoice;
      _spinAskerOnly();
    });
  }

  void _resolveVote(bool eliminated, double percent) {
    results.add(
      SpinTheBottleResult(
        round: round,
        asker: asker,
        target: target,
        eliminated: eliminated,
        outPercentage: percent,
      ),
    );

    if (eliminated) remainingPlayers.remove(target);
    _advanceRound();
  }

  void _endGame() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SpinTheBottleReportScreen(
          results: results,
          survivors: remainingPlayers,
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

  void _openVotePopup() async {
    final res = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          VotePopup(players: widget.players, target: target),
    );

    if (res != null) {
      _resolveVote(res['eliminated'] as bool, res['percent'] as double);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    Widget nameText(String name, Color color, double screenW) {
      return SizedBox(
        width: screenW * 0.9,
        child: AutoSizeText(
          name,
          textAlign: TextAlign.center,
          maxLines: 3,
          minFontSize: 12,
          style: TextStyle(
            fontSize: screenW * 0.18,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

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
              SizedBox(
                height: 90,
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        'Round $round / ${widget.maxRounds}',
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
                  ],
                ),
              ),

              Expanded(child: Center(child: nameText(asker, Colors.white, screenW))),

              AnimatedBuilder(
                animation: _spinController,
                builder: (_, child) {
                  return Transform.rotate(
                    angle: _rotationAnim.value,
                    child: child,
                  );
                },
                child: Image.asset(
                  'assets/images/games/spin-the-bottle/bottle.png',
                  width: screenW * 0.5,
                ),
              ),

              Expanded(child: Center(child: nameText(target, AppColors.gold, screenW))),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: StyledButton(
                        text: phase == SpinPhase.spinChoice
                            ? 'Spin Again?'
                            : 'Vote to Eliminate',
                        color: phase == SpinPhase.actionChoice
                            ? Colors.red
                            : null,
                        onPressed: _isSpinning
                            ? null
                            : phase == SpinPhase.spinChoice
                            ? _spinAskerOnly
                            : _openVotePopup,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StyledButton(
                        text: phase == SpinPhase.spinChoice
                            ? 'Go'
                            : 'Next Round',
                        color: phase == SpinPhase.actionChoice
                            ? Colors.green
                            : null,
                        onPressed: _isSpinning
                            ? null
                            : () {
                                setState(() {
                                  if (phase == SpinPhase.spinChoice) {
                                    phase = SpinPhase.actionChoice;
                                  } else {
                                    _advanceRound(skipVote: true);
                                  }
                                });
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
