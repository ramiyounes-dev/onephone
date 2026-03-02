// Copyright (c) 2026 Rami YOUNES - MIT License

class SpinTheBottleResult {
  final int round;
  final String asker;
  final String target;
  final bool? eliminated; // null if no elimination requested
  final double? outPercentage; // null if no vote

  SpinTheBottleResult({
    required this.round,
    required this.asker,
    required this.target,
    this.eliminated,
    this.outPercentage,
  });
}
