// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:flutter/material.dart';
import 'package:onephone/models/undercover_models.dart';
import 'package:onephone/screens/undercover/undercover_reveal.dart';
import 'package:onephone/theme/app_colors.dart';
import 'package:onephone/widgets/gradient_scaffold.dart';
import 'package:onephone/widgets/settings_top_bar.dart';
import 'package:onephone/widgets/styled_button.dart';

class UndercoverSettingsScreen extends StatefulWidget {
  final List<String> players;

  const UndercoverSettingsScreen({super.key, required this.players});

  @override
  State<UndercoverSettingsScreen> createState() =>
      _UndercoverSettingsScreenState();
}

class _UndercoverSettingsScreenState extends State<UndercoverSettingsScreen> {
  late int totalPlayers;

  int civilians = 0;
  int undercovers = 1;
  int mrWhites = 1;

  bool allowCustomRoles = false;
  bool trackWords = true;

  @override
  void initState() {
    super.initState();
    totalPlayers = widget.players.length;
    _resetToRecommendedDefaults();
  }

  void _resetToRecommendedDefaults() {
    if (totalPlayers <= 4) {
      civilians = totalPlayers - 1;
      undercovers = 1;
      mrWhites = 0;
    } else if (totalPlayers <= 6) {
      civilians = totalPlayers - 2;
      undercovers = 1;
      mrWhites = 1;
    } else {
      civilians = totalPlayers - 3;
      undercovers = 2;
      mrWhites = 1;
    }
  }

  void _applyConstraints({String changed = ''}) {
    if (!allowCustomRoles) return;

    if (undercovers < 0) undercovers = 0;
    if (mrWhites < 0) mrWhites = 0;

    if (undercovers == 0 && mrWhites == 0) {
      if (changed == 'undercovers') {
        undercovers = 1;
      } else {
        mrWhites = 1;
      }
    }

    int sum = undercovers + mrWhites;
    civilians = totalPlayers - sum;

    if (civilians < sum) {
      int diff = sum - civilians;
      if (changed == 'undercovers') {
        undercovers -= diff;
        if (undercovers < 1) undercovers = 1;
      } else if (changed == 'mrWhites') {
        mrWhites -= diff;
        if (mrWhites < 0) mrWhites = 0;
      }
      civilians = totalPlayers - (undercovers + mrWhites);
    }

    if (civilians >= totalPlayers) {
      civilians = totalPlayers - 1;
      undercovers = 1;
      mrWhites = 0;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SettingsTopBar(
              title: 'Undercover Settings',
              actions: const [Spacer()],
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Players: $totalPlayers',
                  style: const TextStyle(fontSize: 22, color: Colors.white70),
                ),
                Row(
                  children: [
                    const Text(
                      'Custom',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    Switch(
                      activeColor: AppColors.goldDark,
                      value: allowCustomRoles,
                      onChanged: (v) {
                        setState(() {
                          allowCustomRoles = v;
                          if (!v) _resetToRecommendedDefaults();
                          _applyConstraints();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Type in words',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Switch(
                  activeColor: AppColors.goldDark,
                  value: trackWords,
                  onChanged: (v) => setState(() => trackWords = v),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _roleCounter(
              title: 'Civilians',
              value: civilians,
              enabled: false,
              onChanged: (_) {},
            ),
            _roleCounter(
              title: 'Undercovers',
              value: undercovers,
              enabled: allowCustomRoles,
              onChanged: (v) {
                undercovers = v;
                _applyConstraints(changed: 'undercovers');
              },
            ),
            _roleCounter(
              title: 'Mr. Whites',
              value: mrWhites,
              enabled: allowCustomRoles,
              onChanged: (v) {
                mrWhites = v;
                _applyConstraints(changed: 'mrWhites');
              },
            ),

            const SizedBox(height: 20),
            const Spacer(),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: StyledButton(
                text: 'Start',
                onPressed: () {
                  final roles = assignRolesShuffleOnly(
                    names: widget.players,
                    civilians: civilians,
                    undercovers: undercovers,
                    mrWhites: mrWhites,
                    language: 'en',
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UndercoverRevealScreen(
                        roles: roles,
                        trackWords: trackWords,
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

  Widget _roleCounter({
    required String title,
    required int value,
    required bool enabled,
    required Function(int) onChanged,
  }) {
    final img = _roleImagePath(title);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipOval(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: 0.6,
              child: Image.asset(img, width: 52, height: 120, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Opacity(
                  opacity: title != 'Civilians' ? 1.0 : 0.0,
                  child: _counterButton(
                    icon: Icons.remove,
                    enabled: enabled && value > 0,
                    onTap: () => onChanged(value - 1),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(
                      value.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
                Opacity(
                  opacity: title != 'Civilians' ? 1.0 : 0.0,
                  child: _counterButton(
                    icon: Icons.add,
                    enabled: enabled && value < totalPlayers,
                    onTap: () => onChanged(value + 1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _counterButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? AppColors.goldDark : Colors.white24,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

String _roleImagePath(String title) {
  if (title == 'Civilians') return 'assets/images/games/undercover_c.png';
  if (title == 'Undercovers') return 'assets/images/games/undercover_u.png';
  return 'assets/images/games/undercover_w.png';
}
