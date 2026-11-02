/// Pure scoring rules for one completed IMPOSTER round.
class RoundScoring {
  const RoundScoring({required this.caught, required this.points});
  final bool caught;
  final List<int> points;
}

/// The imposter is caught only when they are the unique highest-vote player.
/// Every non-imposter receives +/-1 for their own vote. If all non-imposters
/// vote for the imposter, each receives one additional bonus point.
RoundScoring calculateRoundScoring({
  required Map<int, int> votes,
  required int playerCount,
  required int imposterIndex,
}) {
  if (playerCount < 3 || imposterIndex < 0 || imposterIndex >= playerCount) {
    throw ArgumentError('Invalid player count or imposter index.');
  }
  if (votes.length != playerCount ||
      votes.keys.any((voter) => voter < 0 || voter >= playerCount) ||
      votes.values.any((target) => target < 0 || target >= playerCount)) {
    throw ArgumentError('Every player must have exactly one valid vote.');
  }

  final totals = List<int>.filled(playerCount, 0);
  for (final target in votes.values) {
    totals[target]++;
  }
  final highest = totals.reduce((a, b) => a > b ? a : b);
  final leaders = <int>[
    for (var i = 0; i < playerCount; i++)
      if (totals[i] == highest) i,
  ];
  final caught = leaders.length == 1 && leaders.single == imposterIndex;
  final nonImpostersCorrect = votes.entries
      .where((entry) => entry.key != imposterIndex)
      .every((entry) => entry.value == imposterIndex);

  final points = List<int>.filled(playerCount, 0);
  points[imposterIndex] = caught ? -1 : 2;
  for (final entry in votes.entries) {
    if (entry.key == imposterIndex) continue;
    points[entry.key] = entry.value == imposterIndex ? 1 : -1;
    if (nonImpostersCorrect) points[entry.key]++;
  }
  return RoundScoring(caught: caught, points: List.unmodifiable(points));
}
