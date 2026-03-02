// Copyright (c) 2026 Rami YOUNES - MIT License

class WouldYouRatherQuestion {
  final String id;
  final List<String> categories;

  final String enA;
  final String enB;

  final String frA;
  final String frB;

  final String arA;
  final String arB;

  const WouldYouRatherQuestion({
    required this.id,
    required this.categories,
    required this.enA,
    required this.enB,
    required this.frA,
    required this.frB,
    required this.arA,
    required this.arB,
  });

  String partA(String lang) {
    switch (lang) {
      case 'fr':
        return frA;
      case 'ar':
        return arA;
      default:
        return enA;
    }
  }

  String partB(String lang) {
    switch (lang) {
      case 'fr':
        return frB;
      case 'ar':
        return arB;
      default:
        return enB;
    }
  }
}
