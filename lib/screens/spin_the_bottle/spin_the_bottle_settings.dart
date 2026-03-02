// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:flutter/material.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/labeled_slider.dart';
import '../../widgets/settings_top_bar.dart';
import '../../widgets/styled_button.dart';
import 'spin_the_bottle_active.dart';

class SpinTheBottleSettingsScreen extends StatefulWidget {
  final List<String> players;
  const SpinTheBottleSettingsScreen({required this.players, super.key});

  @override
  State<SpinTheBottleSettingsScreen> createState() =>
      _SpinTheBottleSettingsScreenState();
}

class _SpinTheBottleSettingsScreenState
    extends State<SpinTheBottleSettingsScreen> {
  int maxRounds = 10;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    return GradientScaffold(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenW * 0.06,
          vertical: screenH * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsTopBar(title: 'Spin The Bottle Settings'),

            SizedBox(height: screenH * 0.08),

            LabeledSlider(
              label: 'Maximum Rounds:',
              valueText: '$maxRounds',
              min: 1,
              max: 20,
              divisions: 19,
              value: maxRounds.toDouble(),
              onChanged: (v) => setState(() => maxRounds = v.toInt()),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: StyledButton(
                text: 'OK',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SpinTheBottleActiveScreen(
                        players: widget.players,
                        maxRounds: maxRounds,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
