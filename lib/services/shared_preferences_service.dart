// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const String _keyPlayers = "players_list";

  static Future<void> savePlayers(List<String> players) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyPlayers, players);
  }

  static Future<List<String>> loadPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyPlayers) ?? [];
  }

  static Future<void> clearPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPlayers);
  }
}
