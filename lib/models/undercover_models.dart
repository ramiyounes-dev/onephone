// Copyright (c) 2026 Rami YOUNES - MIT License

// models.dart

import 'dart:math';

class UndercoverWordPair {
  final Map<String, String> civilian;
  final Map<String, String> undercover;

  UndercoverWordPair({
    required this.civilian,
    required this.undercover,
  });
}

enum PlayerRole {
  civilian,
  undercover,
  mrWhite,
}

String roleName(PlayerRole r) {
  switch (r) {
    case PlayerRole.civilian:
      return "Civilian";
    case PlayerRole.undercover:
      return "Undercover";
    case PlayerRole.mrWhite:
      return "Mr. White";
  }
}

// ---------------------------
// Player Model
// ---------------------------
class Player {
  final String id;
  final String name;
  final PlayerRole role;
  final String language;
  String? mrWhiteGuess = "";

  bool isEliminated;
  int? eliminatedInRound;

  int points = 0;

  void addPoints(int value) {
    points += value;
    if (points < 0) points = 0;
  }

  void setMrWhiteGuess(String guess) {
    mrWhiteGuess = guess;
  }

  final List<String> wordsPerRound;
  final List<Map<String, int>> votesPerRound;

  Player({
    required this.id,
    required this.name,
    required this.role,
    required this.language,
    this.isEliminated = false,
    this.eliminatedInRound,
    List<String>? wordsPerRound,
    List<Map<String, int>>? votesPerRound,
  })  : wordsPerRound = wordsPerRound ?? [],
        votesPerRound = votesPerRound ?? [];

  void addWord(String word) => wordsPerRound.add(word);

  void addVotes(Map<String, int> votes) =>
      votesPerRound.add(Map.from(votes));
}

// ---------------------------
// Game Cycle Model
// ---------------------------
class GameCycle {
  final int roundIndex; // cycle number
  final bool isTieBreaker; // true if this cycle is a tie-breaker
  final Map<String, String> words; // playerName -> word said
  final Map<String, int> votes; // playerName -> votes received
  final List<String> eliminatedPlayers; // names of eliminated players this cycle
  final List<String> remainingPlayers; // names of remaining players after cycle

  GameCycle({
    required this.roundIndex,
    this.isTieBreaker = false,
    required this.words,
    required this.votes,
    required this.eliminatedPlayers,
    required this.remainingPlayers,
  });
}


// ---------------------------
// Role Assignment
// ---------------------------
List<Player> assignRoles({
  required int players,
  required int civilians,
  required int undercovers,
  required int mrWhites,
}) {
  final list = <Player>[];
  int index = 1;

  for (int i = 0; i < civilians; i++) {
    list.add(Player(
      id: "p$index",
      name: "Player $index",
      role: PlayerRole.civilian,
      language: "en",
    ));
    index++;
  }

  for (int i = 0; i < undercovers; i++) {
    list.add(Player(
      id: "p$index",
      name: "Player $index",
      role: PlayerRole.undercover,
      language: "en",
    ));
    index++;
  }

  for (int i = 0; i < mrWhites; i++) {
    list.add(Player(
      id: "p$index",
      name: "Player $index",
      role: PlayerRole.mrWhite,
      language: "en",
    ));
    index++;
  }

  list.shuffle();
  return list;
}

// ---------------------------
// Voting Result
// ---------------------------
class VoteResult {
  final Map<String, int> counts;
  final Map<String, double> percentages;
  final List<String> mostVoted; // multiple if tie
  final double highestPercent;

  VoteResult({
    required this.counts,
    required this.percentages,
    required this.mostVoted,
    required this.highestPercent,
  });
}

VoteResult countVotes(Map<String, String> votes) {
  final map = <String, int>{};
  for (var entry in votes.entries) {
    map[entry.value] = (map[entry.value] ?? 0) + 1;
  }

  final total = votes.length;
  final percentages = {for (var e in map.entries) e.key: (e.value / total) * 100};

  int maxVote = map.values.isEmpty ? 0 : map.values.reduce((a, b) => a > b ? a : b);
  final mostVoted = map.entries
      .where((e) => e.value == maxVote)
      .map((e) => e.key)
      .toList();

  final double highestPercent = percentages.values.isEmpty
      ? 0
      : percentages.values.reduce((a, b) => a > b ? a : b);

  return VoteResult(
    counts: map,
    percentages: percentages,
    mostVoted: mostVoted,
    highestPercent: highestPercent,
  );
}

List<Player> assignRolesShuffleOnly({
  required List<String> names,
  required int civilians,
  required int undercovers,
  required int mrWhites,
  required String language,
}) {
  final totalPlayers = names.length;
  final roles = <PlayerRole>[];
  roles.addAll(List.filled(civilians, PlayerRole.civilian));
  roles.addAll(List.filled(undercovers, PlayerRole.undercover));
  roles.addAll(List.filled(mrWhites, PlayerRole.mrWhite));

  if (roles.length != totalPlayers) {
    throw Exception("Total roles count does not match number of players!");
  }

  roles.shuffle(Random());

  final list = <Player>[];
  for (int i = 0; i < totalPlayers; i++) {
    list.add(Player(
      id: "p${i + 1}",
      name: names[i],
      role: roles[i],
      language: language,
    ));
  }

  return list;
}
