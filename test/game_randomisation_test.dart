import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:imposter_android/game_randomisation.dart';

void main() {
  group('round player order', () {
    test('shuffles a fresh copy and preserves every player exactly once', () {
      final players = List<String>.generate(10, (index) => 'Player $index');
      final order = createRoundOrder(players, Random(42));

      expect(order, hasLength(players.length));
      expect(order, unorderedEquals(players));
      expect(order, isNot(equals(players)));
      expect(players.first, 'Player 0'); // The lobby order is not mutated.
    });
  });

  group('no-repeat word cycle', () {
    test('uses every word once before starting a new shuffled cycle', () {
      final words = ['Apple', 'Banana', 'Cherry', 'Dragon'];
      final cycle = WordCycle(random: Random(7));

      final firstCycle = List<String>.generate(words.length, (_) => cycle.draw(words));
      expect(firstCycle.toSet(), words.toSet());
      expect(firstCycle, hasLength(words.length));

      final firstWordOfNextCycle = cycle.draw(words);
      expect(firstWordOfNextCycle, isNot(firstCycle.last));
      expect(words, contains(firstWordOfNextCycle));
    });

    test('restored progress does not repeat words after an app restart', () {
      final words = ['Apple', 'Banana', 'Cherry', 'Dragon'];
      final first = WordCycle(random: Random(11));
      final alreadyDrawn = [first.draw(words), first.draw(words)];

      final restored = WordCycle(random: Random(12))
        ..restore(
          remainingWords: first.remainingWords,
          usedWords: first.usedWords,
          lastWord: first.lastWord,
        );

      final restOfCycle = [
        restored.draw(words),
        restored.draw(words),
      ];
      expect([...alreadyDrawn, ...restOfCycle].toSet(), words.toSet());
      expect(restOfCycle.first, isNot(alreadyDrawn.last));
    });

    test('adds newly introduced database words without duplicating used words', () {
      final cycle = WordCycle(random: Random(3));
      final first = cycle.draw(['A', 'B', 'C']);
      final second = cycle.draw(['A', 'B', 'C', 'D']);
      expect(second, isNot(first));
      expect(cycle.remainingWords, contains('D'));
    });
  });
}
