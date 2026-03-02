// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../models/hot_potato_player_result.dart';
import '../../theme/app_colors.dart';
import '../../utils/report_utils.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/report_game_header.dart';
import '../../widgets/report_top_bar.dart';
import '../../widgets/styled_button.dart';

class HotPotatoReportScreen extends StatefulWidget {
  final List<HotPotatoPlayerResult> results;

  const HotPotatoReportScreen({required this.results, super.key});

  @override
  State<HotPotatoReportScreen> createState() => _HotPotatoReportScreenState();
}

class _HotPotatoReportScreenState extends State<HotPotatoReportScreen> {
  final GlobalKey _reportKey = GlobalKey();

  HotPotatoPlayerResult? get winner =>
      widget.results.isNotEmpty ? widget.results.last : null;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GradientScaffold(
      child: Column(
        children: [
          const ReportTopBar(),

          const SizedBox(height: 12),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: RepaintBoundary(
                key: _reportKey,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const ReportGameHeader(
                        imagePath: 'assets/images/games/hot-potato.png',
                        gameName: 'Hot Potato',
                      ),

                      const SizedBox(height: 16),

                      if (winner != null)
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Winner',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.05,
                                  fontFamily: 'ChildstoneDemo',
                                  color: AppColors.goldDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                width: screenWidth * 0.8,
                                child: AutoSizeText(
                                  winner!.name,
                                  maxLines: 1,
                                  minFontSize: 18,
                                  stepGranularity: 1,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.15,
                                    fontFamily: 'ChildstoneDemo',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 16),

                      Column(
                        children: widget.results
                            .sublist(0, widget.results.length - 1)
                            .map((result) {
                          return Container(
                            width: screenWidth * 0.9,
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Round ${result.round}',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.045,
                                    fontFamily: 'ChildstoneDemo',
                                    color: AppColors.goldDark,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Out: ${result.name}',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.042,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Timer: ${result.timerSeconds}s',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.038,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
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

  Future<void> _captureReport() =>
      ReportUtils.captureAndSave(context, _reportKey, 'hot_potato_full');
}
