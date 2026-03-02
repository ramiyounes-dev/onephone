// Copyright (c) 2026 Rami YOUNES - MIT License

import 'dart:ui';
import 'package:flutter/material.dart';

class RenameTeamPopup extends StatefulWidget {
  final String initialName;
  final void Function(String) onSubmit;

  const RenameTeamPopup({
    required this.initialName,
    required this.onSubmit,
    super.key,
  });

  @override
  State<RenameTeamPopup> createState() => _RenameTeamPopupState();
}

class _RenameTeamPopupState extends State<RenameTeamPopup> {
  late TextEditingController controller;
  final focusNode = FocusNode();

  String? errorText;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialName);

    // Autofocus after build
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) focusNode.requestFocus();
    });
  }

  void _validateAndSubmit() {
    final name = controller.text.trim();

    if (name.isEmpty) {
      setState(() => errorText = "Name cannot be empty");
      return;
    }
    if (name.length > 20) {
      setState(() => errorText = "Max 20 characters");
      return;
    }

    widget.onSubmit(name);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Dialog(
        backgroundColor: Colors.white.withValues(alpha: 0.20),
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Rename Team",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
                maxLength: 20,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter team name...",
                  counterText: "",
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.15),
                  errorText: errorText,
                  errorStyle: const TextStyle(
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.white.withValues(alpha: 0.4)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
                onSubmitted: (_) => _validateAndSubmit(),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: _validateAndSubmit,
                      child: const Text(
                        "Save",
                        style: TextStyle(color: Colors.yellow),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
