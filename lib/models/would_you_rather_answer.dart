// Copyright (c) 2026 Rami YOUNES - MIT License

enum WouldYouRatherChoice { a, b }

class WouldYouRatherAnswer {
  final String player;
  final WouldYouRatherChoice choice;

  WouldYouRatherAnswer({
    required this.player,
    required this.choice,
  });
}
