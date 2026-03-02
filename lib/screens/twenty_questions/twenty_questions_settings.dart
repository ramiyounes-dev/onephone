// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:flutter/material.dart';
import 'package:onephone/widgets/enter_word_popup.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/settings_top_bar.dart';
import '../../widgets/styled_button.dart';
import 'twenty_questions_active.dart';

class TwentyQuestionsSettingsScreen extends StatefulWidget {
  final List<String> players;

  const TwentyQuestionsSettingsScreen({
    required this.players,
    super.key,
  });

  @override
  State<TwentyQuestionsSettingsScreen> createState() =>
      _TwentyQuestionsSettingsScreenState();
}

class _TwentyQuestionsSettingsScreenState
    extends State<TwentyQuestionsSettingsScreen> {
  String? selectedPlayer;

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: SettingsTopBar(title: '20 Questions Settings'),
          ),

          const SizedBox(height: 12),

          const Text(
            'Pick a player to choose the word/description \n The other party members will try to guess',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: widget.players.map((p) {
                final isSelected = selectedPlayer == p;
                return GestureDetector(
                  onTap: () => setState(() => selectedPlayer = p),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.greenAccent.withValues(alpha: 0.25)
                          : Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            p,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: isSelected
                              ? Colors.greenAccent
                              : Colors.white54,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: StyledButton(
              text: 'OK',
              onPressed: selectedPlayer == null
                  ? null
                  : () async {
                      final result = await showDialog<String>(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => EnterWordPopup(),
                      );

                      if (result != null && result.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TwentyQuestionsActiveScreen(
                              chooser: selectedPlayer!,
                              secret: result,
                              players: widget.players,
                            ),
                          ),
                        );
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }
}
