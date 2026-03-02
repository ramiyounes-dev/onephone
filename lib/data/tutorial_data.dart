// Copyright (c) 2026 Rami YOUNES - MIT License

class TutorialSection {
  final String title;
  final List<String> points;

  const TutorialSection({required this.title, required this.points});
}

class GameTutorial {
  final String gameId;
  final List<TutorialSection> sections;

  const GameTutorial({required this.gameId, required this.sections});
}

final Map<String, GameTutorial> tutorialData = {
  '20questions': const GameTutorial(
    gameId: '20questions',
    sections: [
      TutorialSection(
        title: 'Settings',
        points: [
          'Add at least 2 players before starting.',
          'Select one player to be the chooser - they will enter a secret word or description.',
          'Everyone else will try to guess it by asking questions.',
        ],
      ),
      TutorialSection(
        title: 'Gameplay',
        points: [
          'The chooser secretly types a word or description into a popup - no peeking!',
          'The rest of the group take turns asking yes/no questions.',
          'Tap YES or NO to answer each question. Answers are logged on screen.',
          'Tap any logged question to edit its answer if you made a mistake.',
          'Tap the trophy icon (top right) at any time if the group guesses correctly.',
          'After 20 questions the round ends automatically and the answer is revealed.',
        ],
      ),
      TutorialSection(
        title: 'Report',
        points: [
          'Shows the secret word and the outcome - whether the group found it or the chooser won.',
          'All questions are listed with their YES / NO answers.',
          'Tap Take Screenshot to save or share the results.',
        ],
      ),
    ],
  ),
  'charades': const GameTutorial(
    gameId: 'charades',
    sections: [
      TutorialSection(
        title: 'Settings',
        points: [
          'Players are split into Team A and Team B automatically - tap a team name to rename it.',
          'Tap any player to move them between teams.',
          'Select the word categories you want in play.',
          'Toggle "Manual Word Selection" to let the opposing team secretly enter a word instead of picking from the database.',
          'Set the turn timer (30 s – 3 min) and the number of rounds.',
          'Tap the translate icon to switch the word language.',
        ],
      ),
      TutorialSection(
        title: 'Gameplay',
        points: [
          'When the database is used, choose one of three words before your turn starts: Easy (+1 pt), Medium (+2 pts), or Hard (+3 pts).',
          'When Manual Word Selection is on, the opposing team types a secret word for you.',
          'Act out the word without speaking - no mouthing, spelling, or pointing at objects in the room.',
          'Teammates shout their guesses freely.',
          'Tap "Found" (needs confirmation) when your team guesses correctly.',
          'Tap "Peek" to secretly view the word - the timer pauses while the dialog is open.',
          'Tap "Give Up" (needs confirmation) to end the turn without scoring.',
          'A popup shows the word after every turn before the next team\'s turn begins.',
          'Teams alternate each turn within a round.',
        ],
      ),
      TutorialSection(
        title: 'Report',
        points: [
          'Scores are shown per team and per round, including point values.',
          'Correctly guessed and skipped words are listed separately.',
          'The team with the highest total score wins.',
          'Tap Take Screenshot to save or share the results.',
        ],
      ),
    ],
  ),
  'hotpotato': const GameTutorial(
    gameId: 'hotpotato',
    sections: [
      TutorialSection(
        title: 'Settings',
        points: [
          'Add at least 2 players.',
          'Set the timer duration (30 – 300 s, default 180 s).',
          'Suggested word categories are shown for inspiration - players shout a word in that category while passing the turn.',
        ],
      ),
      TutorialSection(
        title: 'Gameplay',
        points: [
          'The timer counts down silently in the background - no one knows when it will go off.',
          'Swipe the phone left or right to pass it to the next player.',
          'A ticking beep starts when 5 seconds remain.',
          'Whoever has their name on the phone when the timer hits zero is eliminated.',
          'A popup announces who is out, then you can adjust the timer for the next round.',
          'Eliminations continue until only one player remains - they are the winner.',
        ],
      ),
      TutorialSection(
        title: 'Report',
        points: [
          'Shows which player was eliminated in each round.',
          'The last surviving player is declared the winner.',
        ],
      ),
    ],
  ),
  'simon': const GameTutorial(
    gameId: 'simon',
    sections: [
      TutorialSection(
        title: 'Settings',
        points: [
          'Add 1 or more players.',
          'Set the number of rounds (1 – 10, default 5).',
          'Each player plays every round independently - sequences reset between players and between rounds.',
        ],
      ),
      TutorialSection(
        title: 'Gameplay',
        points: [
          'Four colored buttons light up one by one in a sequence.',
          'Watch carefully, then tap the buttons in the exact same order.',
          'Each correct repeat adds one more button to the sequence.',
          'A wrong tap ends your turn - your score is the number of steps you successfully completed.',
          'Players take turns in order; a popup announces whose turn it is.',
          'Sequences reset to zero at the start of every new round.',
        ],
      ),
      TutorialSection(
        title: 'Report',
        points: [
          'Shows the level reached by each player for every round.',
          'The player with the highest total score across all rounds wins.',
        ],
      ),
    ],
  ),
  'spinthebottle': const GameTutorial(
    gameId: 'spinthebottle',
    sections: [
      TutorialSection(
        title: 'Settings',
        points: [
          'Add at least 3 players.',
          'Set the maximum number of rounds (1 – 20, default 10).',
        ],
      ),
      TutorialSection(
        title: 'Gameplay',
        points: [
          'The bottle spins automatically to select a random asker.',
          'The target is the player opposite the asker.',
          'Tap "Spin Again?" to re-spin for a different asker, or "Go" to accept the current pairing.',
          'After tapping Go, choose what happens: tap "Vote to Eliminate" to hold a group vote on removing the target, or "Next Round" to skip and move on.',
          'Eliminated players are removed from future rounds.',
          'The game ends when the round limit is reached or only one player remains.',
        ],
      ),
      TutorialSection(
        title: 'Report',
        points: [
          'Lists every round\'s asker and target pairing.',
          'Shows vote results and who (if anyone) was eliminated each round.',
          'Surviving players are listed at the end.',
        ],
      ),
    ],
  ),
  'truthbombs': const GameTutorial(
    gameId: 'truthbombs',
    sections: [
      TutorialSection(
        title: 'Settings',
        points: [
          'Add at least 3 players.',
          'Set the number of questions (1 – 20, default 5).',
          'Questions are drawn randomly from the full pool - no category selection needed.',
          'Tap the translate icon during the game to switch question language.',
        ],
      ),
      TutorialSection(
        title: 'Gameplay',
        points: [
          'A question appears - e.g. "Most likely to forget someone\'s birthday".',
          'Use the + and − buttons to distribute votes across all players.',
          'The total votes assigned must equal the number of players before you can proceed.',
          'Tap "Next" (or "Finish" on the last question) once all votes are placed.',
        ],
      ),
      TutorialSection(
        title: 'Report',
        points: [
          'Shows vote totals per player for every question.',
          'The most-voted player on each question is highlighted.',
          'Tap Take Screenshot to save or share the results.',
        ],
      ),
    ],
  ),
  'undercover': const GameTutorial(
    gameId: 'undercover',
    sections: [
      TutorialSection(
        title: 'Settings',
        points: [
          'Add at least 4 players.',
          'Role counts are set automatically based on player count - toggle "Custom" to adjust civilians, undercovers, and Mr. Whites manually.',
          'Toggle "Type in words" (on by default) to record the word each player says each cycle. Turn it off for a faster, trust-based game.',
        ],
      ),
      TutorialSection(
        title: 'Gameplay',
        points: [
          'Each player privately taps "Reveal" on their turn to see their role and word.',
          'Civilians all share the same word. The undercover has a closely related but different word. Mr. White gets no word.',
          'If "Type in words" is on, each player types their spoken word before the cycle begins - this is recorded for the report.',
          'In turns, each player says one word loosely related to theirs - vague enough to hide their role.',
          'After everyone speaks, players vote to eliminate the most suspicious person.',
          'Civilians win by eliminating all undercovers and Mr. White.',
          'Mr. White can still win by correctly guessing the civilian word after being voted out.',
          'The undercover wins by surviving until civilians are outnumbered.',
        ],
      ),
      TutorialSection(
        title: 'Report',
        points: [
          'Reveals each player\'s role and the secret words that were in play.',
          'If "Type in words" was on, each cycle shows the word each player said alongside their vote count.',
          'If "Type in words" was off, cycles show player names and vote counts only.',
          'Announces the winning side.',
        ],
      ),
    ],
  ),
  'wordblitz': const GameTutorial(
    gameId: 'wordblitz',
    sections: [
      TutorialSection(
        title: 'Settings',
        points: [
          'Players are split into Team A and Team B - tap a player to swap them between teams, tap the team name to rename it.',
          'Set the timer per turn (30 – 90 s, default 45 s).',
          'Tap the translate icon to switch the word pack language.',
          'The game always plays 3 rounds, one per clue style.',
        ],
      ),
      TutorialSection(
        title: 'Gameplay',
        points: [
          'Round 1 - Describe: use as many words as you like to describe the word.',
          'Round 2 - One Word: give exactly one word as a clue.',
          'Round 3 - Mime: no words at all - gestures and sounds only.',
          'The same 35-word pack is reused each round, with guessed words removed.',
          'Tap "Got it!" when the team guesses correctly - the word is removed from the pack.',
          'Tap "Skip" to cycle to the next word - skipped words come back around.',
          'Score as many words as possible before the timer runs out.',
          'Teams alternate turns; after both teams play a turn the round advances.',
        ],
      ),
      TutorialSection(
        title: 'Report',
        points: [
          'Team scores are broken down by round and clue style.',
          'Correctly guessed and skipped words are listed separately.',
          'The team with the highest total score wins.',
        ],
      ),
    ],
  ),
  // DATABASE sucks -- leaving it out for now, but will add back in once I have a better solution for storing game data
  // 'wouldyourather': const GameTutorial(
  //   gameId: 'wouldyourather',
  //   sections: [
  //     TutorialSection(
  //       title: 'Settings',
  //       points: [
  //         'Add at least 2 players.',
  //         'Toggle question categories to control which dilemmas appear.',
  //         'Set the number of questions (1 – 10, default 5).',
  //         'Tap the translate icon to switch question language during the game.',
  //       ],
  //     ),
  //     TutorialSection(
  //       title: 'Gameplay',
  //       points: [
  //         'Two options appear on screen - one in red (A) and one in blue (B).',
  //         'Each player taps A or B to lock in their choice.',
  //         'Once every player has answered, the "Validate" button becomes active.',
  //         'Tap Validate to reveal all choices and move to the next question.',
  //       ],
  //     ),
  //     TutorialSection(
  //       title: 'Report',
  //       points: [
  //         'Shows each player\'s choice (A or B) for every question.',
  //         'See where the group agreed and where opinions split.',
  //       ],
  //     ),
  //   ],
  // ),
};
