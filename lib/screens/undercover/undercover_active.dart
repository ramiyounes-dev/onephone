// Copyright (c) 2026 Rami YOUNES - MIT License

import 'package:flutter/material.dart';
import 'package:onephone/models/undercover_models.dart';
import 'package:onephone/screens/undercover/undercover_report.dart';
import 'package:onephone/widgets/frosted_popup.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_gradients.dart';
import '../../widgets/styled_button.dart';
import '../../widgets/notification_popup.dart';

class UndercoverActiveScreen extends StatefulWidget {
  final List<Player> roles;
  final UndercoverWordPair wordPair;
  final String? startPlayerId;
  final bool trackWords;

  const UndercoverActiveScreen({
    required this.roles,
    required this.wordPair,
    this.startPlayerId,
    this.trackWords = true,
    super.key,
  });

  @override
  State<UndercoverActiveScreen> createState() => _UndercoverActiveScreenState();
}

class _UndercoverActiveScreenState extends State<UndercoverActiveScreen> {
  String language = 'en';

  late List<Player> remainingPlayers;
  late List<Player> playerCycle;
  final Map<String, String> wordsSaid = {};
  final Map<String, int> votes = {};

  int currentWordIndex = 0;
  int currentRoundIndex = 1;
  bool inTieBreaker = false;
  List<Player> tieCandidates = [];

  final List<GameCycle> gameCycles = [];

  // Remove Arabic diacritics
  String normalizeArabic(String input) {
    const diacritics = [
      '\u0610',
      '\u0611',
      '\u0612',
      '\u0613',
      '\u0614',
      '\u0615',
      '\u0616',
      '\u0617',
      '\u0618',
      '\u0619',
      '\u061A',
      '\u064B',
      '\u064C',
      '\u064D',
      '\u064E',
      '\u064F',
      '\u0650',
      '\u0651',
      '\u0652',
      '\u0653',
      '\u0654',
      '\u0655',
      '\u0656',
      '\u0657',
      '\u0658',
      '\u0670',
    ];
    for (var d in diacritics) {
      input = input.replaceAll(d, '');
    }
    return input;
  }

  // Compare guess to a word (any language)
  bool matches(String guess, String? word) {
    if (word == null || word.trim().isEmpty) return false;

    return normalizeArabic(guess.trim().toLowerCase()) ==
        normalizeArabic(word.trim().toLowerCase());
  }

  @override
  void initState() {
    super.initState();
    remainingPlayers = widget.roles.where((p) => !p.isEliminated).toList();
    _initPlayerCycle(startPlayerId: widget.startPlayerId);
    WidgetsBinding.instance.addPostFrameCallback((_) => _showWordPopup());
  }

  void _initPlayerCycle({String? startPlayerId}) {
    final normalOrder = List<Player>.from(remainingPlayers);

    if (inTieBreaker) {
      playerCycle = List<Player>.from(tieCandidates);
    } else if (startPlayerId != null) {
      final startIndex = normalOrder.indexWhere((p) => p.id == startPlayerId);
      playerCycle = startIndex >= 0
          ? [
              ...normalOrder.sublist(startIndex),
              ...normalOrder.sublist(0, startIndex),
            ]
          : normalOrder;
    } else {
      final nonWhite = normalOrder
          .where((p) => p.role != PlayerRole.mrWhite)
          .toList();
      nonWhite.shuffle();
      final start = nonWhite.first;
      final startIndex = normalOrder.indexOf(start);
      playerCycle = [
        ...normalOrder.sublist(startIndex),
        ...normalOrder.sublist(0, startIndex),
      ];
    }

    currentWordIndex = 0;
    wordsSaid.clear();
    votes.clear();
  }

  void _showWordPopup() {
    if (currentWordIndex >= playerCycle.length) return;

    final player = playerCycle[currentWordIndex];
    final controller = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => FrostedPopup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text(
              "${inTieBreaker ? "Tie-breaker" : "New Cycle"}\n",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontFamily: 'ChildstoneDemo',
              ),
            ),
            Text(
              player.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.goldDark,
                fontSize: 30,
                fontFamily: 'ChildstoneDemo',
              ),
            ),
            if (widget.trackWords) ...[
              const Text(
                "\nEnter your word",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'ChildstoneDemo',
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: 'ChildstoneDemo',
                  ),
                  decoration: const InputDecoration(
                    hintText: "Word",
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.all(16),
              child: StyledButton(
                text: widget.trackWords ? "Confirm" : "Ready",
                onPressed: () {
                  if (widget.trackWords && controller.text.trim().isEmpty) return;

                  setState(() {
                    if (widget.trackWords) {
                      wordsSaid[player.name] = controller.text.trim();
                      player.addWord(controller.text.trim());
                    }
                    currentWordIndex++;
                  });

                  Navigator.of(context).pop();
                  if (currentWordIndex < playerCycle.length) _showWordPopup();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _allVotesAssigned() {
    int totalVotesAssigned = votes.values.fold(0, (a, b) => a + b);
    int totalVotesAllowed = remainingPlayers.length - tieCandidates.length;
    return totalVotesAssigned == totalVotesAllowed;
  }

  Widget _playerTile(Player player) {
    final count = votes[player.name] ?? 0;
    bool canVote = !inTieBreaker || tieCandidates.contains(player);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _voteButton(
            icon: Icons.remove,
            color: Colors.red,
            onTap: canVote
                ? () {
                    setState(() {
                      if (count > 0) votes[player.name] = count - 1;
                    });
                  }
                : null,
          ),
          Expanded(
            child: Text(
              "${player.name}\n$count",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontFamily: 'ChildstoneDemo',
              ),
            ),
          ),
          _voteButton(
            icon: Icons.add,
            color: Colors.green,
            onTap: canVote
                ? () {
                    setState(() {
                      votes[player.name] = count + 1;
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _voteButton({
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: onTap != null
              ? color.withValues(alpha: 0.85)
              : Colors.grey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Future<void> _confirmVotes() async {
    if (!_allVotesAssigned()) return;

    // Record votes per player
    for (var p in remainingPlayers) {
      final voteMap = {
        for (var r in remainingPlayers) r.name: votes[r.name] ?? 0,
      };
      p.addVotes(voteMap);
    }

    // Determine max votes
    final maxVotes = votes.values.reduce((a, b) => a > b ? a : b);
    final tied = remainingPlayers
        .where((p) => votes[p.name] == maxVotes)
        .toList();

    // Save current cycle
    gameCycles.add(
      GameCycle(
        roundIndex: currentRoundIndex,
        words: Map.from(wordsSaid),
        votes: Map.from(votes),
        eliminatedPlayers: tied.length == 1 ? [tied.first.name] : [],
        remainingPlayers: remainingPlayers
            .where((p) => !tied.contains(p) && tied.length == 1)
            .map((p) => p.name)
            .toList(),
        isTieBreaker: inTieBreaker,
      ),
    );

    if (tied.length > 1) {
      // SPECIAL CASE: all players tied → no tie-break possible
      if (tied.length == remainingPlayers.length) {
        inTieBreaker = false;
        tieCandidates.clear();
        currentRoundIndex++; // or keep same round index if preferred

        _initPlayerCycle();
        _showWordPopup();
        return;
      }

      // Normal tie-breaker
      inTieBreaker = true;
      tieCandidates = List.from(tied);
      _initPlayerCycle();
      _showWordPopup();
      return;
    }

    // Eliminate single player
    final eliminated = tied.first;
    eliminated.isEliminated = true;
    eliminated.eliminatedInRound = currentRoundIndex;
    eliminated.addPoints(-1);
    remainingPlayers = remainingPlayers.where((p) => !p.isEliminated).toList();

    await _showEliminationPopup(eliminated);
    bool mrWhiteWin = false;

    if (eliminated.role == PlayerRole.mrWhite) {
      final guess = await _showMrWhiteGuessPopup(eliminated);
      if (guess != null) {
        final guessNorm = guess.trim().toLowerCase();
        eliminated.setMrWhiteGuess(guessNorm);

        // Check the guess against all languages the civilian word was assigned in
        final en = widget.wordPair.civilian['en'] ?? '';
        final fr = widget.wordPair.civilian['fr'] ?? '';
        final ar = widget.wordPair.civilian['ar'] ?? '';

        if (matches(guessNorm, en) ||
            matches(guessNorm, fr) ||
            matches(guessNorm, ar)) {
          mrWhiteWin = true;
          eliminated.addPoints(6);

          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              backgroundColor: Colors.black.withValues(alpha: 0.85),
              title: const Text(
                "Mr. White Wins!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Continue",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        } else {
          mrWhiteWin = false;

          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              backgroundColor: Colors.black.withValues(alpha: 0.85),
              title: const Text(
                "You guessed wrong!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Continue",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }
      }
    }
    // Award points for remaining players
    for (var p in remainingPlayers) {
      p.addPoints(1); // +1 per round survived
    }

    // Check endgame
    bool civiliansWin = remainingPlayers.every(
      (p) => p.role == PlayerRole.civilian,
    );
    bool undercoversWin =
        remainingPlayers.where((p) => p.role == PlayerRole.civilian).length <=
            1 &&
        remainingPlayers.where((p) => p.role == PlayerRole.undercover).length >=
            1;
    mrWhiteWin =
        mrWhiteWin ||
        (remainingPlayers.where((p) => p.role == PlayerRole.civilian).length <=
                1 &&
            remainingPlayers
                    .where((p) => p.role == PlayerRole.mrWhite)
                    .length >=
                1);

    if (mrWhiteWin || civiliansWin || undercoversWin) {
      if (mrWhiteWin) {
        for (var p in widget.roles) {
          if (p.role == PlayerRole.mrWhite) p.addPoints(6);
        }
      }
      if (civiliansWin) {
        for (var p in widget.roles) {
          if (p.role == PlayerRole.civilian) p.addPoints(2);
        }
      }
      if (undercoversWin) {
        for (var p in widget.roles) {
          if (p.role == PlayerRole.undercover) p.addPoints(10);
        }
      }

      // Navigate to report screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UndercoverReportScreen(
            roles: widget.roles,
            cycles: gameCycles,
            wordPair: widget.wordPair,
            mrWhiteWin: mrWhiteWin,
            civiliansWin: civiliansWin,
            undercoversWin: undercoversWin,
          ),
        ),
      );
      return;
    }

    // Continue game
    currentRoundIndex++;
    inTieBreaker = false;
    tieCandidates.clear();
    _initPlayerCycle();
    _showWordPopup();
  }

  // Mr. White guess popup
  Future<String?> _showMrWhiteGuessPopup(Player white) async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => FrostedPopup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Text(
              "${white.name}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.goldDark, fontSize: 30),
            ),
            Text(
              "guess the civilian word!",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 22),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Enter your guess",
                  hintStyle: TextStyle(color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.all(16),
              child: StyledButton(
                text: "Submit",
                onPressed: () => Navigator.pop(context, controller.text.trim()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEliminationPopup(Player player) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => FrostedPopup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Text(
              "${player.name}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.goldDark,
                fontSize: 30,
                fontFamily: 'ChildstoneDemo',
              ),
            ),
            Text(
              "has been eliminated!",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontFamily: 'ChildstoneDemo',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "${player.role.name}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 22,
                fontFamily: 'ChildstoneDemo',
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.all(16),
              child: StyledButton(
                text: "Continue",
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmExit() async {
    final res = await showDialog<bool>(
      context: context,
      builder: (_) => NotificationPopup(
        title: 'Exit game',
        message: 'Are you sure?',
        buttonText: 'Yes',
        onClose: () => Navigator.pop(context, true),
      ),
    );

    if (res == true) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  Widget _roleCountBadge(PlayerRole role, String asset) {
    final count = remainingPlayers.where((p) => p.role == role).length;
    return Row(
      children: [
        ClipOval(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: 0.6,
            child: Image.asset(asset, width: 22, height: 50, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: 'ChildstoneDemo',
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.mainBackground),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 60,
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        inTieBreaker
                            ? "Tie-Breaker Voting Phase"
                            : "Voting Phase",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      top: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: _confirmExit,
                      ),
                    ),
                  ],
                ),
              ),

              // Remaining count per role
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _roleCountBadge(
                      PlayerRole.civilian,
                      'assets/images/games/undercover_c.png',
                    ),
                    const SizedBox(width: 20),
                    _roleCountBadge(
                      PlayerRole.undercover,
                      'assets/images/games/undercover_u.png',
                    ),
                    const SizedBox(width: 20),
                    _roleCountBadge(
                      PlayerRole.mrWhite,
                      'assets/images/games/undercover_w.png',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                child: Text(
                  "Votes remaining: ${remainingPlayers.length - tieCandidates.length - votes.values.fold(0, (a, b) => a + b)}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: remainingPlayers.map(_playerTile).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: StyledButton(
                  text: "Confirm Votes / Elimination",
                  onPressed: _allVotesAssigned() ? _confirmVotes : null,
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
