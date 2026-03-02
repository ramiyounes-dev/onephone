// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:flutter/material.dart';
import '../theme/app_gradients.dart';

/// A Scaffold with the full-screen gradient background applied.
/// Replaces the repeated Scaffold + Container + gradient + SafeArea boilerplate.
/// Set [useSafeArea] to false for screens that manage SafeArea themselves
/// (e.g. when using a Stack with overlapping Positioned widgets).
class GradientScaffold extends StatelessWidget {
  final Widget child;
  final bool useSafeArea;

  const GradientScaffold({
    required this.child,
    this.useSafeArea = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(gradient: AppGradients.mainBackground),
          child: useSafeArea ? SafeArea(child: child) : child,
        ),
      ),
    );
  }
}
