// Copyright (c) 2026 Rami YOUNES - MIT License

import 'dart:ui';
import 'package:flutter/material.dart';
import '../storage/player_storage.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/styled_button.dart';

class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  List<String> players = [];
  String? errorText;
  String query = '';
  List<String> filteredPlayers = [];

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    players = await PlayerStorage.loadPlayers();
    filteredPlayers = List.of(players);
    setState(() {});
  }

  void _onSearchChanged(String s) {
    setState(() {
      query = s;
      filteredPlayers = players
          .where((p) => p.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _openPlayerDialog({String? currentName}) async {
    final controller = TextEditingController(text: currentName ?? '');
    final focusNode = FocusNode();

    errorText = null;

    await showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: StatefulBuilder(
            builder: (context, popupSetState) {
              Future.delayed(const Duration(milliseconds: 100), () {
                focusNode.requestFocus();
              });

              return Dialog(
                backgroundColor: Colors.white.withValues(alpha: 0.20),
                insetPadding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Player Name',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: controller,
                        focusNode: focusNode,
                        autofocus: true,
                        maxLength: 20,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter name...',
                          counterText: '',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.15),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                          errorText: errorText,
                          errorStyle: const TextStyle(
                            color: Colors.yellow,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onSubmitted: (_) => _validateAndSubmit(
                          controller.text,
                          popupSetState,
                          currentName,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () => _validateAndSubmit(
                                controller.text,
                                popupSetState,
                                currentName,
                              ),
                              child: const Text(
                                'Save',
                                style: TextStyle(color: Colors.yellow),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _validateAndSubmit(
    String rawName,
    void Function(void Function()) popupSetState,
    String? originalName,
  ) {
    final name = rawName.trim();

    if (name.isEmpty) {
      popupSetState(() => errorText = 'Name cannot be empty.');
      return;
    }
    if (name.length > 20) {
      popupSetState(() => errorText = 'Name must be 20 characters max.');
      return;
    }
    final lower = name.toLowerCase();
    final exists = players.any((p) {
      if (originalName != null && p == originalName) return false;
      return p.toLowerCase() == lower;
    });
    if (exists) {
      popupSetState(() => errorText = 'This name already exists.');
      return;
    }

    popupSetState(() => errorText = null);
    if (originalName != null) {
      final index = players.indexOf(originalName);
      players[index] = name;
    } else {
      players.add(name);
    }

    PlayerStorage.savePlayers(players);
    Navigator.pop(context);
    _onSearchChanged(query);
    setState(() {});
  }

  void _deletePlayer(String name) {
    players.remove(name);
    PlayerStorage.savePlayers(players);
    _onSearchChanged(query);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GradientScaffold(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    'Player Setup',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'ChildstoneDemo',
                      fontSize: screenWidth * 0.075,
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),

            SizedBox(height: screenHeight * 0.02),

            TextField(
              onChanged: _onSearchChanged,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'ChildstoneDemo',
              ),
              decoration: InputDecoration(
                hintText: 'Search players...',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.02),

            Expanded(
              child: filteredPlayers.isEmpty
                  ? const Center(
                      child: Text(
                        'No players yet. Add some!',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredPlayers.length,
                      itemBuilder: (context, index) {
                        final name = filteredPlayers[index];
                        return GestureDetector(
                          onTap: () => _openPlayerDialog(currentName: name),
                          child: Container(
                            margin: EdgeInsets.only(
                              bottom: screenHeight * 0.015,
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.02,
                              horizontal: screenWidth * 0.04,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.06),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.045,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () => _deletePlayer(name),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            Column(
              children: [
                SizedBox(height: screenHeight * 0.015),
                StyledButton(
                  text: 'Add Player',
                  onPressed: () => _openPlayerDialog(),
                ),
              ],
            ),

            SizedBox(height: screenHeight * 0.02),
          ],
        ),
      ),
    );
  }
}
