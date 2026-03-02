// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/sound_manager.dart';

class ShareButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const ShareButton({this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Dynamically set size based on screen screenHeight
    double buttonSize;
      buttonSize = screenWidth * 0.15; // small phone

    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 255, 196, 0), // fill color
        border: Border.all(
          color: Colors.amber.shade800, // darker outline
          width: 2,
        ),
        borderRadius: BorderRadius.circular(buttonSize * 0.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(Icons.share, color: Colors.black, size: buttonSize * 0.3),
        onPressed: () {
          HapticFeedback.selectionClick();
          SoundManager().play('sounds/tap.mp3');

          if (onPressed != null) {
            onPressed!();
          } else {
            Share.share(
            'Looking for fun party games? Check out OnePhone - the all-in-one party game app!\n\n'
            'Charades, Word Blitz, Undercover, Hot Potato & more - all on one phone.\n\n'
            'Download it free on Google Play:\n'
            'https://play.google.com/store/apps/details?id=com.ramiyounes.onephone',
            subject: 'OnePhone - Party Games App',
          );
          }
        },
      ),
    );
  }
}
