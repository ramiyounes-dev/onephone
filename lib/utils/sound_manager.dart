// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  // Singleton so every game shares the same AudioPlayer instance
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;

  SoundManager._internal();

  final AudioPlayer _player = AudioPlayer();

  final Set<String> _preloaded = {};

  Future<void> preload(String fileName) async {
    if (_preloaded.contains(fileName)) return;
    try {
      await _player.setSource(AssetSource(fileName));
      _preloaded.add(fileName);
    } catch (_) {
      // Non-critical - game continues without preloaded audio
    }
  }

  Future<void> play(String fileName, {double volume = 1.0}) async {
    try {
      await _player.setVolume(volume);
      await _player.play(AssetSource(fileName));
    } catch (_) {
      // Non-critical - game continues without sound
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }
}
