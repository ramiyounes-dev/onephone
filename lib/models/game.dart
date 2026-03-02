// Copyright (c) 2026 Rami YOUNES - MIT License
class Game {
  final String id;
  final String title;
  final int minPlayers;
  final String description;
  final String imageAsset; // e.g. 'assets/images/games/pingpong.png'

  const Game({
    required this.id,
    required this.title,
    required this.minPlayers,
    required this.description,
    required this.imageAsset,
  });
}
