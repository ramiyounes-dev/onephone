// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:flutter/material.dart';
import 'package:onephone/models/undercover_models.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/report_utils.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/report_game_header.dart';
import '../../widgets/report_top_bar.dart';
import '../../widgets/styled_button.dart';

class UndercoverReportScreen extends StatefulWidget {
  final List<Player> roles;
  final UndercoverWordPair wordPair;
  final List<GameCycle> cycles;
  final bool civiliansWin;
  final bool undercoversWin;
  final bool mrWhiteWin;

  const UndercoverReportScreen({
    required this.roles,
    required this.cycles,
    required this.wordPair,
    required this.mrWhiteWin,
    required this.civiliansWin,
    required this.undercoversWin,
    super.key,
  });

  @override
  State<UndercoverReportScreen> createState() => _UndercoverReportScreenState();
}

class _UndercoverReportScreenState extends State<UndercoverReportScreen> {
  final GlobalKey _reportKey = GlobalKey();

  String get winningTeam {
    if (widget.civiliansWin) return 'Civilians Win';
    if (widget.mrWhiteWin && widget.undercoversWin) return 'The infiltrators Win';
    if (widget.mrWhiteWin) return 'Mr. White(s) Win';
    if (widget.undercoversWin) return 'Undercovers Win';
    return 'Game Over !!!';
  }

  List<Player> getGroup(PlayerRole role) =>
      widget.roles.where((p) => p.role == role).toList();

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return GradientScaffold(
      child: Column(
        children: [
          const ReportTopBar(),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: RepaintBoundary(
                key: _reportKey,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const ReportGameHeader(
                        imagePath: 'assets/images/games/undercover.png',
                        gameName: 'Undercover',
                      ),

                      const SizedBox(height: 12),

                      Center(
                        child: Text(
                          winningTeam,
                          style: TextStyle(
                            fontSize: screenW * 0.06,
                            fontFamily: 'ChildstoneDemo',
                            color: AppColors.goldDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      _groupSection(
                        screenW,
                        'Civilians',
                        getGroup(PlayerRole.civilian),
                        widget.wordPair.civilian['en'] ?? '',
                      ),
                      const SizedBox(height: 8),

                      _groupSection(
                        screenW,
                        'Undercovers',
                        getGroup(PlayerRole.undercover),
                        widget.wordPair.undercover['en'] ?? '',
                      ),
                      const SizedBox(height: 8),

                      _groupWhiteSection(
                        screenW,
                        'Mr. White(s)',
                        getGroup(PlayerRole.mrWhite),
                      ),

                      const SizedBox(height: 20),

                      Center(
                        child: Text(
                          'Cycles & Tie-breakers',
                          style: AppTextStyles.sectionTitle(screenW * 0.05),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 8),

                      ..._buildCycles(screenW),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: StyledButton(
              text: 'Take Screenshot',
              onPressed: _captureReport,
            ),
          ),
        ],
      ),
    );
  }

  Widget _groupWhiteSection(
    double screenWidth,
    String title,
    List<Player> players,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _roleImage(title),
            const SizedBox(width: 12),
            Text(title, style: AppTextStyles.sectionTitle(screenWidth * 0.045)),
          ],
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            players.isEmpty
                ? '---'
                : players
                    .map(
                      (p) =>
                          '${p.name} (${(p.mrWhiteGuess?.trim().isNotEmpty ?? false) ? p.mrWhiteGuess : '-'})',
                    )
                    .join(', '),
            textAlign: TextAlign.center,
            style: AppTextStyles.contentText(
              screenWidth * 0.04,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _groupSection(
    double screenWidth,
    String title,
    List<Player> players,
    String code,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                _roleImage(title),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTextStyles.sectionTitle(screenWidth * 0.045),
                ),
              ],
            ),
            Text(
              code,
              style: AppTextStyles.sectionTitle(screenWidth * 0.04)
                  .copyWith(color: Colors.white70),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            players.isEmpty ? '---' : players.map((p) => p.name).join(', '),
            textAlign: TextAlign.center,
            style: AppTextStyles.contentText(
              screenWidth * 0.04,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _roleImage(String title) {
    final img = _roleImagePath(title);
    return ClipOval(
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: 0.65,
        child: Image.asset(img, width: 38, height: 90, fit: BoxFit.cover),
      ),
    );
  }

  List<Widget> _buildCycles(double screenWidth) {
    final widgets = <Widget>[];

    for (var cycle in widget.cycles) {
      final hasWords = cycle.words.isNotEmpty;

      widgets.add(
        Text(
          cycle.isTieBreaker ? 'Tie-breaker' : 'Cycle ${cycle.roundIndex}',
          style: AppTextStyles.sectionTitle(screenWidth * 0.05),
        ),
      );
      widgets.add(const SizedBox(height: 8));

      // Header row
      widgets.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Player',
                  style: AppTextStyles.contentText(screenWidth * 0.04, bold: true),
                ),
              ),
              if (hasWords)
                Expanded(
                  child: Text(
                    'Word',
                    style: AppTextStyles.contentText(screenWidth * 0.04, bold: true),
                  ),
                ),
              Expanded(
                child: Text(
                  'Votes',
                  style: AppTextStyles.contentText(screenWidth * 0.04, bold: true),
                ),
              ),
            ],
          ),
        ),
      );
      widgets.add(const SizedBox(height: 6));

      // Data rows - use words entries when available, votes entries otherwise
      final playerNames = hasWords
          ? cycle.words.keys.toList()
          : cycle.votes.keys.toList();

      for (var playerName in playerNames) {
        final word = cycle.words[playerName] ?? '';
        final voteCount = cycle.votes[playerName] ?? 0;
        final eliminated = cycle.eliminatedPlayers.contains(playerName);

        widgets.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: BoxDecoration(
              color: eliminated
                  ? Colors.red.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    playerName,
                    style: AppTextStyles.contentText(screenWidth * 0.04),
                  ),
                ),
                if (hasWords)
                  Expanded(
                    child: Text(
                      word,
                      style: AppTextStyles.contentText(
                        screenWidth * 0.035,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                Expanded(
                  child: Text(
                    voteCount.toString(),
                    style: AppTextStyles.contentText(
                      screenWidth * 0.04,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      widgets.add(const SizedBox(height: 16));
    }

    return widgets;
  }

  Future<void> _captureReport() =>
      ReportUtils.captureAndSave(context, _reportKey, 'undercover_full');
}

/// Returns the asset path for the given role title.
String _roleImagePath(String title) {
  if (title == 'Civilians') return 'assets/images/games/undercover_c.png';
  if (title == 'Undercovers') return 'assets/images/games/undercover_u.png';
  return 'assets/images/games/undercover_w.png';
}
