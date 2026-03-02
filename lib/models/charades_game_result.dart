// Copyright (c) 2026 Rami YOUNES - MIT License

class CharadesGameResult {
  final int round;
  final String teamName;
  final String playerName;
  final String word;
  final int points;
  final int usedTime;
  final int remainingTime;

  CharadesGameResult({
    required this.round,
    required this.teamName,
    required this.playerName,
    required this.word,
    required this.points,
    required this.usedTime,
    required this.remainingTime,
  });
}
