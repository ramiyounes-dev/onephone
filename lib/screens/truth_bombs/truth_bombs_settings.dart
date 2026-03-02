// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:flutter/material.dart';
import '../../data/truth_bombs/truth_bombs_questions.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/labeled_slider.dart';
import '../../widgets/settings_top_bar.dart';
import '../../widgets/styled_button.dart';
import 'truth_bombs_active.dart';

class TruthBombsSettingsScreen extends StatefulWidget {
  final List<String> players;

  const TruthBombsSettingsScreen({required this.players, super.key});

  @override
  State<TruthBombsSettingsScreen> createState() =>
      _TruthBombsSettingsScreenState();
}

class _TruthBombsSettingsScreenState extends State<TruthBombsSettingsScreen> {
  int questionCount = 5;

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: SettingsTopBar(title: 'Truth Bombs'),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LabeledSlider(
              label: 'Number of Questions:',
              valueText: '$questionCount',
              min: 1,
              max: 20,
              divisions: 9,
              value: questionCount.toDouble(),
              onChanged: (v) => setState(() => questionCount = v.toInt()),
            ),
          ),

          const Spacer(),

          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: StyledButton(
                text: 'Start',
                onPressed: () {
                  final shuffled = List.of(truthBombQuestions)..shuffle();
                  final selected = shuffled.take(questionCount).toList();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TruthBombsActiveScreen(
                        players: widget.players,
                        questions: selected,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
