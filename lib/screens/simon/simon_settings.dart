// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:flutter/material.dart';
import 'package:onephone/theme/app_colors.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/settings_top_bar.dart';
import '../../widgets/styled_button.dart';
import 'simon_active.dart';

class SimonSettingsScreen extends StatefulWidget {
  final List<String> players;
  const SimonSettingsScreen({super.key, required this.players});

  @override
  State<SimonSettingsScreen> createState() => _SimonSettingsScreenState();
}

class _SimonSettingsScreenState extends State<SimonSettingsScreen> {
  int rounds = 5;

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsTopBar(title: 'Simon Settings'),

            const SizedBox(height: 30),

            Text(
              'Rounds',
              style: TextStyle(
                fontSize: 22,
                color: AppColors.goldDark,
                fontFamily: 'ChildstoneDemo',
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '$rounds',
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontFamily: 'ChildstoneDemo',
                    ),
                  ),
                  Slider(
                    min: 1,
                    max: 10,
                    divisions: 9,
                    value: rounds.toDouble(),
                    onChanged: (v) => setState(() => rounds = v.toInt()),
                    activeColor: AppColors.goldDark,
                    thumbColor: Colors.white,
                  ),
                ],
              ),
            ),

            const Spacer(),

            Center(
              child: StyledButton(
                text: 'Start Simon',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SimonActiveScreen(
                        players: widget.players,
                        totalRounds: rounds,
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
