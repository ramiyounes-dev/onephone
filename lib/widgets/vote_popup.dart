// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'styled_button.dart';

class VotePopup extends StatefulWidget {
  final List<String> players; // ALL players (even eliminated)
  final String target;

  const VotePopup({
    required this.players,
    required this.target,
    super.key,
  });

  @override
  State<VotePopup> createState() => _VotePopupState();
}

class _VotePopupState extends State<VotePopup> {
  final Map<String, bool> votes = {}; // player → vote (true = eliminate)

  bool get _allVoted => votes.length == widget.players.length;

  double get _outPercent {
    final yesVotes = votes.values.where((v) => v).length;
    return (yesVotes / widget.players.length) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: const Color.fromARGB(235, 96, 96, 96),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Vote to eliminate',
              style: TextStyle(
                fontSize: screenW * 0.055,
                color: AppColors.gold,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.target,
              style: TextStyle(
                fontSize: screenW * 0.08,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // ─── PLAYERS VOTE LIST (SCROLLABLE) ───
            SizedBox(
              height: screenH * 0.4, // limits dialog height
              child: SingleChildScrollView(
                child: Column(
                  children: widget.players.map(_playerTile).toList(),
                ),
              ),
            ),

            const SizedBox(height: 12),

            StyledButton(
              text: _allVoted
                  ? 'Validate (${_outPercent.toStringAsFixed(0)}%)'
                  : 'Waiting for votes...',
              onPressed: _allVoted
                  ? () {
                      Navigator.pop(context, {
                        'eliminated': _outPercent > 50,
                        'percent': _outPercent,
                      });
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _playerTile(String player) {
    final vote = votes[player];

    Color bg;
    if (vote == true) bg = Colors.redAccent.withValues(alpha: 0.75);
    else if (vote == false) bg = Colors.greenAccent.withValues(alpha: 0.75);
    else bg = Colors.white.withValues(alpha: 0.25);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _voteButton(player, true, 'OUT', Colors.redAccent),
          Expanded(
            child: Text(
              player,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _voteButton(player, false, 'SAFE', Colors.greenAccent),
        ],
      ),
    );
  }

  Widget _voteButton(
    String player,
    bool vote,
    String label,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          votes[player] = vote;
        });
      },
      child: Container(
        width: 50,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
