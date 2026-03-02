// Copyright (c) 2026 Rami YOUNES - MIT License

import '../services/shared_preferences_service.dart';

class PlayerStorage {
  static Future<List<String>> loadPlayers() async {
    return SharedPreferencesService.loadPlayers();
  }

  static Future<void> savePlayers(List<String> players) async {
    return SharedPreferencesService.savePlayers(players);
  }

  static Future<void> clearPlayers() async {
    return SharedPreferencesService.clearPlayers();
  }
}
