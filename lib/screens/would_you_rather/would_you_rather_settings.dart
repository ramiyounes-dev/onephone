// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:flutter/material.dart';
import '../../data/would_you_rather/would_you_rather_questions.dart';
import '../../models/would_you_rather_question.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/category_header.dart';
import '../../widgets/gradient_scaffold.dart';
import '../../widgets/labeled_slider.dart';
import '../../widgets/language_popup.dart';
import '../../widgets/settings_top_bar.dart';
import '../../widgets/styled_button.dart';
import 'would_you_rather_active.dart';

class WouldYouRatherSettingsScreen extends StatefulWidget {
  final List<String> players;

  const WouldYouRatherSettingsScreen({required this.players, super.key});

  @override
  State<WouldYouRatherSettingsScreen> createState() =>
      _WouldYouRatherSettingsScreenState();
}

class _WouldYouRatherSettingsScreenState
    extends State<WouldYouRatherSettingsScreen> {
  late Map<String, bool> selectedCategories;
  String language = 'en';
  int questionCount = 5;

  @override
  void initState() {
    super.initState();
    selectedCategories = {
      for (final cat in wouldYouRatherCategories) cat['en'] as String: true,
    };
  }

  bool get selectAll => selectedCategories.values.every((v) => v);

  void _toggleSelectAll(bool value) {
    setState(() {
      for (final key in selectedCategories.keys) {
        selectedCategories[key] = value;
      }
    });
  }

  void _toggleCategory(String catEn) {
    setState(() {
      selectedCategories[catEn] = !selectedCategories[catEn]!;
    });
  }

  void _selectLanguage() {
    showDialog(
      context: context,
      builder: (_) => LanguagePopup(
        selectedLanguage: language,
        onSelected: (l) => setState(() => language = l),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    final translatedCategories = {
      for (final cat in wouldYouRatherCategories)
        cat[language] as String: selectedCategories[cat['en']]!,
    };

    return GradientScaffold(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenW * 0.06,
          vertical: screenH * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsTopBar(
              title: 'Would You Rather Settings',
              actions: [
                IconButton(
                  icon: const Icon(Icons.translate, color: Colors.white),
                  onPressed: _selectLanguage,
                ),
              ],
            ),

            SizedBox(height: screenH * 0.04),

            CategoryHeader(
              title: 'Categories:',
              toggleLabel: 'Select All',
              selectAll: selectAll,
              onToggleAll: _toggleSelectAll,
            ),

            SizedBox(height: screenH * 0.02),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: translatedCategories.entries.map((entry) {
                final label = entry.key;
                final active = entry.value;

                return CategoryChip(
                  label: label,
                  isActive: active,
                  onTap: () {
                    final enKey =
                        wouldYouRatherCategories.firstWhere(
                              (c) => c[language] == label,
                            )['en']
                            as String;
                    _toggleCategory(enKey);
                  },
                );
              }).toList(),
            ),

            SizedBox(height: screenH * 0.05),

            LabeledSlider(
              label: 'Number of Questions:',
              valueText: '$questionCount',
              min: 1,
              max: 10,
              divisions: 9,
              value: questionCount.toDouble(),
              onChanged: (v) => setState(() => questionCount = v.toInt()),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.all(16),
              child: StyledButton(
                text: 'OK',
                onPressed: () {
                  final enabledUniverse = <String>{};

                  for (final cat in wouldYouRatherCategories) {
                    if (!selectedCategories[cat['en']]!) continue;
                    enabledUniverse.add(cat['en'] as String);
                    final sub = cat['subumbrella'];
                    if (sub is List) {
                      enabledUniverse.addAll(List<String>.from(sub));
                    }
                  }

                  final shuffled = List.of(wouldYouRatherQuestions)..shuffle();
                  final selected = <WouldYouRatherQuestion>[];
                  for (final q in shuffled) {
                    if (selected.length >= questionCount) break;
                    if (q.categories.any(enabledUniverse.contains)) {
                      selected.add(q);
                    }
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WouldYouRatherActiveScreen(
                        players: widget.players,
                        questions: selected,
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
