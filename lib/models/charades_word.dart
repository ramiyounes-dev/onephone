// Copyright (c) 2026 Rami YOUNES - MIT License
class CharadesWord {
  final String id;
  final String difficulty; // 'easy', 'medium', 'hard'
  final List<String> categories;
  final String en;
  final String fr;
  final String ar;

  CharadesWord({
    required this.id,
    required this.difficulty,
    required this.categories,
    required this.en,
    required this.fr,
    required this.ar,
  });
}
