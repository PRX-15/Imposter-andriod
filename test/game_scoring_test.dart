import 'package:flutter_test/flutter_test.dart';
import 'package:imposter_android/game_scoring.dart';

void main() {
  group('calculateRoundScoring', () {
    test('imposter escapes and receives +2', () {
      final result = calculateRoundScoring(
        votes: {0: 2, 1: 0, 2: 1}, playerCount: 3, imposterIndex: 2,
      );
      expect(result.caught, isFalse);
      expect(result.points, [1, -1, 2]);
    });

    test('imposter uniquely leads and receives -1', () {
      final result = calculateRoundScoring(
        votes: {0: 2, 1: 2, 2: 0}, playerCount: 3, imposterIndex: 2,
      );
      expect(result.caught, isTrue);
      expect(result.points, [2, 2, -1]);
    });

    test('correct non-imposter vote receives +1', () {
      final result = calculateRoundScoring(
        votes: {0: 2, 1: 0, 2: 1}, playerCount: 3, imposterIndex: 2,
      );
      expect(result.points[0], 1);
    });

    test('incorrect non-imposter vote receives -1', () {
      final result = calculateRoundScoring(
        votes: {0: 1, 1: 0, 2: 1}, playerCount: 3, imposterIndex: 2,
      );
      expect(result.points[1], -1);
    });

    test('all non-imposters receive the additional correct-vote bonus', () {
      final result = calculateRoundScoring(
        votes: {0: 2, 1: 2, 2: 0}, playerCount: 3, imposterIndex: 2,
      );
      expect(result.points, [2, 2, -1]);
    });

    test('imposter never receives the all-correct bonus', () {
      final result = calculateRoundScoring(
        votes: {0: 2, 1: 2, 2: 0}, playerCount: 3, imposterIndex: 2,
      );
      expect(result.points[2], -1);
    });

    test('all-correct votes still score when imposter escapes by tie', () {
      final result = calculateRoundScoring(
        votes: {0: 2, 1: 2, 2: 1, 3: 1},
        playerCount: 4, imposterIndex: 2,
      );
      expect(result.caught, isFalse);
      expect(result.points, [1, 1, 2, -1]);
    });

    test('a tie for highest votes means the imposter escapes', () {
      final result = calculateRoundScoring(
        votes: {0: 2, 1: 2, 2: 1, 3: 1},
        playerCount: 4, imposterIndex: 2,
      );
      expect(result.caught, isFalse);
      expect(result.points[2], 2);
    });

    test('rejects incomplete and invalid votes', () {
      expect(
        () => calculateRoundScoring(
          votes: {0: 2, 1: 0}, playerCount: 3, imposterIndex: 2,
        ),
        throwsArgumentError,
      );
      expect(
        () => calculateRoundScoring(
          votes: {0: 2, 1: 0, 2: 8}, playerCount: 3, imposterIndex: 2,
        ),
        throwsArgumentError,
      );
    });
  });
}
