// Copyright (c) 2026 Rami YOUNES - MIT License
import 'package:flutter/material.dart';
import '../models/game.dart';

class GamePlayPlaceholderScreen extends StatelessWidget {
  final Game game;
  final List<String> players;

  const GamePlayPlaceholderScreen({required this.game, required this.players, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${game.title}')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('Starting ${game.title}', style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 12),
              Text('Players: ${players.join(', ')}'),
              const SizedBox(height: 20),
              Text('Replace this screen with the actual game implementation.'),
            ],
          ),
        ),
      ),
    );
  }
}
