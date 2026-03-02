// Copyright (c) 2026 Rami YOUNES - MIT License

import '../models/game.dart';

final List<Game> gamesSampleData = [
  const Game(
    id: '20questions',
    title: '20 Questions',
    minPlayers: 2,
    description:
        'One player secretly chooses a word or description. The rest ask yes/no questions - up to 20 - to figure out what it is before time runs out.',
    imageAsset: 'assets/images/games/20-questions.png',
  ),
  const Game(
    id: 'charades',
    title: 'Charades',
    minPlayers: 4,
    description:
        'Two teams compete to guess as many words as possible. The active player acts out words - no talking. Choose from easy, medium, or hard words worth 1, 2, or 3 points.',
    imageAsset: 'assets/images/games/charades.png',
  ),
  const Game(
    id: 'hotpotato',
    title: 'Hot Potato',
    minPlayers: 2,
    description:
        'A hidden timer counts down while players swipe the phone to pass it around. Whoever holds it when it goes off is eliminated. Last one standing wins.',
    imageAsset: 'assets/images/games/hot-potato.png',
  ),
  const Game(
    id: 'simon',
    title: 'Simon',
    minPlayers: 1,
    description:
        'Watch the sequence of colored buttons light up, then tap them in the exact same order. Each correct round adds one more step - how far can you go?',
    imageAsset: 'assets/images/games/simon.png',
  ),
  const Game(
    id: 'spinthebottle',
    title: 'Spin the Bottle',
    minPlayers: 3,
    description:
        'The bottle spins to pick pairs at random. Accept the pairing and go, spin again for a different match, or vote to eliminate the target. Play as many rounds as you set.',
    imageAsset: 'assets/images/games/spin-the-bottle.png',
  ),
  const Game(
    id: 'truthbombs',
    title: 'Truth Bombs',
    minPlayers: 3,
    description:
        'A question appears - "Most likely to...", "Who is the most...", and more. Distribute votes across players using + and −. All votes must be placed before moving on.',
    imageAsset: 'assets/images/games/truth-bombs.png',
  ),
  const Game(
    id: 'undercover',
    title: 'Undercover',
    minPlayers: 4,
    description:
        'Civilians share a secret word. The undercover has a similar but different word. Mr. White gets nothing. Talk vaguely, vote out the imposters - but watch out for Mr. White\'s final guess.',
    imageAsset: 'assets/images/games/undercover.png',
  ),
  const Game(
    id: 'wordblitz',
    title: 'Word Blitz',
    minPlayers: 4,
    description:
        'Three rounds, three styles: describe the word freely, then one word only, then mime and sounds. Teams race to guess as many words as possible before the timer runs out.',
    imageAsset: 'assets/images/games/word-blitz.png',
  ),
  // DATABASE sucks -- leaving it out for now, but will add back in once I have a better solution for storing game data
  // const Game(
  //   id: 'wouldyourather',
  //   title: 'Would You Rather',
  //   minPlayers: 2,
  //   description:
  //       'Two options appear - one red, one blue. Every player picks their side. Once everyone has chosen, reveal who picked what and move to the next dilemma.',
  //   imageAsset: 'assets/images/games/would-you-rather.png',
  // ),
];
