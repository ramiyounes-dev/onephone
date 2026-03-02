// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../models/spin_the_bottle_result.dart';
import '../../theme/app_colors.dart';
import '../../utils/report_utils.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/report_game_header.dart';
import '../../widgets/report_top_bar.dart';
import '../../widgets/styled_button.dart';

class SpinTheBottleReportScreen extends StatefulWidget {
  final List<SpinTheBottleResult> results;
  final List<String> survivors;

  const SpinTheBottleReportScreen({
    required this.results,
    required this.survivors,
    super.key,
  });

  @override
  State<SpinTheBottleReportScreen> createState() =>
      _SpinTheBottleReportScreenState();
}

class _SpinTheBottleReportScreenState extends State<SpinTheBottleReportScreen> {
  final GlobalKey _reportKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

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
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const ReportGameHeader(
                        imagePath: 'assets/images/games/spin-the-bottle.png',
                        gameName: 'Spin The Bottle',
                      ),

                      const SizedBox(height: 20),

                      Text(
                        widget.survivors.length == 1 ? 'Winner' : 'Survivors',
                        style: TextStyle(
                          fontSize: screenW * 0.05,
                          fontFamily: 'ChildstoneDemo',
                          color: AppColors.goldDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _responsiveNames(widget.survivors, screenW),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Text(
                            'Rounds',
                            style: TextStyle(
                              fontSize: screenW * 0.065,
                              fontFamily: 'ChildstoneDemo',
                              color: AppColors.goldDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      Column(
                        children: widget.results.map((r) {
                          return Container(
                            width: screenW * 0.9,
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(84, 79, 79, 79),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${r.asker} → ${r.target}',
                                  style: TextStyle(
                                    fontSize: screenW * 0.04,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _roundOutcome(r, screenW),
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
            padding: const EdgeInsets.all(12),
            child: StyledButton(
              text: 'Take Screenshot',
              onPressed: _captureReport,
            ),
          ),
        ],
      ),
    );
  }

  Widget _responsiveNames(List<String> names, double screenW,
      {Color color = Colors.white}) {
    final text = names.length == 1 ? names.first : names.join(', ');
    return AutoSizeText(
      text,
      textAlign: TextAlign.center,
      maxLines: 3,
      minFontSize: 14,
      style: TextStyle(
        fontSize: screenW * 0.04,
        color: color,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _roundOutcome(SpinTheBottleResult r, double screenW) {
    if (r.eliminated == null) {
      return Text(
        'No elimination requested',
        style: TextStyle(fontSize: screenW * 0.038, color: Colors.white70),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          r.eliminated!
              ? '${r.target} was eliminated'
              : '${r.target} was safe',
          style: TextStyle(
            fontSize: screenW * 0.038,
            color: r.eliminated! ? Colors.redAccent : Colors.greenAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${r.outPercentage!.toStringAsFixed(0)}%',
          style: TextStyle(fontSize: screenW * 0.035, color: Colors.white70),
        ),
      ],
    );
  }

  Future<void> _captureReport() =>
      ReportUtils.captureAndSave(context, _reportKey, 'spin_the_bottle');
}
