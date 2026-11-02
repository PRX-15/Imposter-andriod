import 'dart:math';

/// Returns a fresh player order for one round without mutating the lobby order.
List<T> createRoundOrder<T>(Iterable<T> players, Random random) {
  final order = List<T>.of(players);
  order.shuffle(random);
  return order;
}

/// Persistent shuffled word cycle. Every database word is drawn once per cycle.
class WordCycle {
  WordCycle({Random? random}) : _random = random ?? Random();

  final Random _random;
  final List<String> _remaining = [];
  final Set<String> _usedThisCycle = {};
  String? _lastWord;

  List<String> get remainingWords => List.unmodifiable(_remaining);
  List<String> get usedWords => List.unmodifiable(_usedThisCycle);
  String? get lastWord => _lastWord;

  void restore({
    Iterable<String> remainingWords = const [],
    Iterable<String> usedWords = const [],
    String? lastWord,
  }) {
    _remaining
      ..clear()
      ..addAll(remainingWords.where((word) => word.isNotEmpty).toSet());
    _usedThisCycle
      ..clear()
      ..addAll(usedWords.where((word) => word.isNotEmpty));
    _lastWord = lastWord;
  }

  String draw(Iterable<String> databaseWords) {
    final words = databaseWords.where((word) => word.isNotEmpty).toSet().toList();
    if (words.isEmpty) {
      throw StateError('Cannot draw from an empty word database.');
    }

    final available = words.toSet();
    _remaining.removeWhere((word) => !available.contains(word));
    _usedThisCycle.removeWhere((word) => !available.contains(word));

    // Include words added to the database since the previous app session.
    for (final word in words) {
      if (!_remaining.contains(word) && !_usedThisCycle.contains(word)) {
        _remaining.add(word);
      }
    }

    if (_remaining.isEmpty) {
      _usedThisCycle.clear();
      _remaining
        ..addAll(words)
        ..shuffle(_random);

      // Avoid a duplicate across the boundary between two complete cycles.
      if (_remaining.length > 1 && _remaining.first == _lastWord) {
        final swapIndex = 1 + _random.nextInt(_remaining.length - 1);
        final first = _remaining.first;
        _remaining[0] = _remaining[swapIndex];
        _remaining[swapIndex] = first;
      }
    }

    final selected = _remaining.removeAt(0);
    _usedThisCycle.add(selected);
    _lastWord = selected;
    return selected;
  }
}
