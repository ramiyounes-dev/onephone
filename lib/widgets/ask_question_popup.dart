// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:flutter/material.dart';
import '../models/twenty_questions_entry.dart';
import '../../widgets/styled_button.dart';
import '../../widgets/frosted_popup.dart';

class AskQuestionPopup extends StatefulWidget {
  final TwentyQuestionEntry? initial;

  const AskQuestionPopup({
    super.key,
    this.initial,
  });

  @override
  State<AskQuestionPopup> createState() => _AskQuestionPopupState();
}

class _AskQuestionPopupState extends State<AskQuestionPopup> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(
      text: widget.initial?.question ?? '',
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: FrostedPopup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.initial == null ? 'Ask a Question' : 'Edit Question',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Is it ... ?',
                hintStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StyledButton(
                    text: 'YES',
                    onPressed: () {
                      Navigator.pop(
                        context,
                        TwentyQuestionEntry(
                          question: controller.text.trim(),
                          answerYes: true,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StyledButton(
                    text: 'NO',
                    onPressed: () {
                      Navigator.pop(
                        context,
                        TwentyQuestionEntry(
                          question: controller.text.trim(),
                          answerYes: false,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
