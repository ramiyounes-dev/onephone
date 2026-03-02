// Copyright (c) 2026 Rami YOUNES - MIT License

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:onephone/screens/undercover/undercover_active.dart';
import 'package:onephone/theme/app_colors.dart';
import 'package:onephone/theme/app_gradients.dart';
import 'package:onephone/widgets/language_popup.dart';
import 'package:onephone/widgets/styled_button.dart';
import '../../models/undercover_models.dart';
import '../../data/undercover/undercover_words.dart';

class UndercoverRevealScreen extends StatefulWidget {
  final List<Player> roles;
  final bool trackWords;

  const UndercoverRevealScreen({
    required this.roles,
    this.trackWords = true,
    super.key,
  });

  @override
  State<UndercoverRevealScreen> createState() =>
      _UndercoverRevealScreenState();
}

class _UndercoverRevealScreenState extends State<UndercoverRevealScreen>
    with SingleTickerProviderStateMixin {
  late List<Player> playerOrder;
  int currentPlayerIndex = 0;
  bool showPassPopup = true;
  bool showWordPopup = false;
  bool revealStarted = false;
  bool _isPopupVisible = false;
  String popupLanguage = 'en';

  late UndercoverWordPair wordPair;
  late AnimationController fadeController;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Pick word pair randomly
    wordPair = undercoverWordPairs[
        DateTime.now().millisecondsSinceEpoch % undercoverWordPairs.length];

    // Setup fade animation for dimming background
    fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    fadeAnimation =
        Tween<double>(begin: 1.0, end: 0.4).animate(fadeController);

    // Prepare player order cycle
    playerOrder = _generatePlayerOrder(widget.roles);

    // Delay initial reveal until the user clicks Reveal
  }

  @override
  void dispose() {
    fadeController.dispose();
    super.dispose();
  }

  List<Player> _generatePlayerOrder(List<Player> roles) {
    List<Player> active = List.from(roles);

    // First round cannot start with Mr. White
    if (active[0].role == PlayerRole.mrWhite) {
      final nonWhite = active.firstWhere(
          (p) => p.role != PlayerRole.mrWhite,
          orElse: () => active[0]);
      active.remove(nonWhite);
      active.insert(0, nonWhite);
    }
    return active;
  }

  void _startReveal() {
    setState(() => revealStarted = true);
    _showPopup();
  }

  void _showPopup() {
    final player = playerOrder[currentPlayerIndex];

    fadeController.forward();
    setState(() => _isPopupVisible = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) {
          void _selectLanguage() {
            showDialog(
              context: context,
              builder: (_) => LanguagePopup(
                selectedLanguage: popupLanguage,
                onSelected: (l) {
                  setStateDialog(() => popupLanguage = l);
                },
              ),
            );
          }

          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Material(
              color: Colors.transparent,
              child: Dialog(
                insetPadding: const EdgeInsets.all(12),
                backgroundColor: Colors.white.withValues(alpha: 0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SizedBox(
                  width: 300,
                  height: 250,
                  child: Column(
                    children: [
                      // ----- HEADER WITH TRANSLATE BUTTON -----
                      Padding(
                        padding: const EdgeInsets.only(top: 6, right: 6),
                        child: showPassPopup
                            ? null
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.translate,
                                        color: Colors.white),
                                    onPressed: _selectLanguage,
                                  ),
                                ],
                              ),
                      ),
                      // ---------------- CONTENT AREA ----------------
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Center(
                            child: showPassPopup
                                ? RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      text: "Pass the phone to\n\n",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontFamily: 'ChildstoneDemo',
                                      ),
                                      children: [
                                        TextSpan(
                                          text: player.name,
                                          style: const TextStyle(
                                            color: AppColors.goldDark,
                                            fontSize: 32,
                                            fontFamily: 'ChildstoneDemo',
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Text(
                                    player.role == PlayerRole.mrWhite
                                        ? "You are Mr. White!\nBluff your way out of this.."
                                        : (player.role == PlayerRole.civilian
                                            ? wordPair.civilian[popupLanguage] ??
                                                wordPair.civilian['en']!
                                            : wordPair.undercover[popupLanguage] ??
                                                wordPair.undercover['en']!),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: AppColors.goldDark,
                                      fontSize: 28,
                                      fontFamily: 'ChildstoneDemo',
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      // ---- BUTTON FIXED AT THE BOTTOM ----
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, bottom: 20),
                        child: StyledButton(
                          text: showPassPopup ? "Reveal" : "Hide",
                          onPressed: () {
                            if (showPassPopup) {
                              setStateDialog(() {
                                showPassPopup = false;
                                showWordPopup = true;
                              });
                            } else {
                              Navigator.of(context).pop();
                              fadeController.reverse();
                              setState(() => _isPopupVisible = false);
                              _nextPlayer();
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
        },
      ),
    ).then((_) {
      setState(() => _isPopupVisible = false);
    });
  }

  void _nextPlayer() {
    if (currentPlayerIndex < playerOrder.length - 1) {
      setState(() {
        currentPlayerIndex++;
        showPassPopup = true;
        showWordPopup = false;
      });
      _showPopup();
    } else {
      // All players have seen their roles, navigate to active screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UndercoverActiveScreen(
            roles: widget.roles,
            wordPair: wordPair,
            trackWords: widget.trackWords,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
        children: [
          AnimatedBuilder(
            animation: fadeAnimation,
            builder: (context, child) {
              return Container(
                decoration: const BoxDecoration(
                    gradient: AppGradients.mainBackground),
                child: Opacity(
                  opacity: fadeAnimation.value,
                  child: child,
                ),
              );
            },
            child: Stack(
              children: [
                Positioned(
                  top: screenHeight * 0.2,
                  left: 0,
                  right: 0,
                  child: const Center(
                    child: Text(
                      "Let's seeee\n\n    Who's a civilian?\n\nMr. White?\n\n    An undercover?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontFamily: 'ChildstoneDemo',
                      ),
                    ),
                  ),
                ),
                if (!revealStarted)
                  Positioned(
                    bottom: 100,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: StyledButton(
                        text: "Reveal",
                        onPressed: _startReveal,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ---------- BACKGROUND BLUR WHEN POPUP IS VISIBLE ----------
          if (_isPopupVisible)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withValues(alpha: 0.2),
              ),
            ),
        ],
        ),
      ),
    );
  }
}
