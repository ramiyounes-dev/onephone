// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:flutter/material.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/labeled_slider.dart';
import '../../widgets/settings_top_bar.dart';
import '../../widgets/styled_button.dart';
import 'hot_potato_active.dart';

class HotPotatoSettingsScreen extends StatefulWidget {
  final List<String> players;
  const HotPotatoSettingsScreen({required this.players, super.key});

  @override
  State<HotPotatoSettingsScreen> createState() =>
      _HotPotatoSettingsScreenState();
}

class _HotPotatoSettingsScreenState extends State<HotPotatoSettingsScreen> {
  String selectedLetter = 'A';
  int timerSeconds = 180;
  final List<String> categories = [
    'Names',
    'Last Names',
    'Companies',
    'Cars',
    'Food',
    'Cities',
    'Countries',
    'First Letter',
    'Last Letter',
    'Rhymes',
    'etc.',
  ];

  late FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(initialItem: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
            const SettingsTopBar(title: 'Hot Potato Settings'),

            SizedBox(height: screenH * 0.03),

            Text(
              'Categories (suggestion):',
              style: TextStyle(fontSize: 26, color: Colors.white70),
            ),
            Text(
              categories.join(', '),
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),

            SizedBox(height: screenH * 0.04),

            LabeledSlider(
              label: 'Timer (seconds):',
              valueText: '$timerSeconds s',
              min: 30,
              max: 300,
              divisions: 270,
              value: timerSeconds.toDouble(),
              onChanged: (v) => setState(() => timerSeconds = v.toInt()),
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
                      builder: (_) => HotPotatoActiveScreen(
                        players: widget.players,
                        timerSeconds: timerSeconds,
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
