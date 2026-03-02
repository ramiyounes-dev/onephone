// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

/// Top bar shared across all settings screens.
/// Shows a back arrow, a title, and optional trailing action widgets.
class SettingsTopBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;

  const SettingsTopBar({required this.title, this.actions, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AutoSizeText(
            title,
            maxLines: 1,
            minFontSize: 14,
            style: const TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (actions != null) ...actions!,
      ],
    );
  }
}
