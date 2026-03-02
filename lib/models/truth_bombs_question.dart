// Copyright (c) 2026 Rami YOUNES - MIT License

class TruthBombQuestion {
  final String id;
  final String en;
  final String fr;
  final String ar;

  TruthBombQuestion({
    required this.id,
    required this.en,
    required this.fr,
    required this.ar,
  });

  String getText(String lang) {
    switch (lang) {
      case 'fr':
        return fr;
      case 'ar':
        return ar;
      default:
        return en;
    }
  }
}
