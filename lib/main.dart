import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const ImposterApp());

const Color bg = Color(0xFF090413);
const Color card = Color(0xFF211039);
const Color card2 = Color(0xFF331452);
const Color accent = Color(0xFFAD40FF);
const Color primary = Color(0xFFFF1F61);
const Color muted = Color(0xFFB89ED9);
const Color good = Color(0xFF59D968);
const Color danger = Color(0xFFFF5968);

class WordEntry {
  const WordEntry(this.word, this.wordHi, this.category, this.categoryHi);
  final String word;
  final String wordHi;
  final String category;
  final String categoryHi;

  Map<String, dynamic> toJson() => {
        'word': word,
        'word_hi': wordHi,
        'category': category,
        'category_hi': categoryHi,
      };

  factory WordEntry.fromJson(Map<String, dynamic> json) => WordEntry(
        json['word'] as String? ?? '',
        json['word_hi'] as String? ?? '',
        json['category'] as String? ?? '',
        json['category_hi'] as String? ?? '',
      );
}

// Offline seed database. Additional entries can be added without changing game logic.
const List<WordEntry> wordDatabase = [
  WordEntry('Pizza', 'पिज़्ज़ा', 'FOOD', 'भोजन'),
  WordEntry('Burger', 'बर्गर', 'FOOD', 'भोजन'),
  WordEntry('Biryani', 'बिरयानी', 'FOOD', 'भोजन'),
  WordEntry('Dosa', 'डोसा', 'FOOD', 'भोजन'),
  WordEntry('Idli', 'इडली', 'FOOD', 'भोजन'),
  WordEntry('Samosa', 'समोसा', 'SNACKS & STREET FOOD', 'स्ट्रीट फ़ूड'),
  WordEntry('Pav Bhaji', 'पाव भाजी', 'FOOD', 'भोजन'),
  WordEntry('Paneer Tikka', 'पनीर टिक्का', 'FOOD', 'भोजन'),
  WordEntry('Mango', 'आम', 'FRUITS', 'फल'),
  WordEntry('Apple', 'सेब', 'FRUITS', 'फल'),
  WordEntry('Banana', 'केला', 'FRUITS', 'फल'),
  WordEntry('Watermelon', 'तरबूज', 'FRUITS', 'फल'),
  WordEntry('Grapes', 'अंगूर', 'FRUITS', 'फल'),
  WordEntry('Lion', 'शेर', 'ANIMALS', 'जानवर'),
  WordEntry('Tiger', 'बाघ', 'ANIMALS', 'जानवर'),
  WordEntry('Elephant', 'हाथी', 'ANIMALS', 'जानवर'),
  WordEntry('Giraffe', 'जिराफ़', 'ANIMALS', 'जानवर'),
  WordEntry('Penguin', 'पेंगुइन', 'ANIMALS', 'जानवर'),
  WordEntry('Cricket', 'क्रिकेट', 'SPORTS', 'खेल'),
  WordEntry('Football', 'फ़ुटबॉल', 'SPORTS', 'खेल'),
  WordEntry('Chess', 'शतरंज', 'SPORTS', 'खेल'),
  WordEntry('Badminton', 'बैडमिंटन', 'SPORTS', 'खेल'),
  WordEntry('Basketball', 'बास्केटबॉल', 'SPORTS', 'खेल'),
  WordEntry('Tea', 'चाय', 'DRINKS', 'पेय'),
  WordEntry('Coffee', 'कॉफ़ी', 'DRINKS', 'पेय'),
  WordEntry('Lemonade', 'नींबू पानी', 'DRINKS', 'पेय'),
  WordEntry('Milkshake', 'मिल्कशेक', 'DRINKS', 'पेय'),
  WordEntry('School', 'स्कूल', 'PLACES', 'जगहें'),
  WordEntry('Hospital', 'अस्पताल', 'PLACES', 'जगहें'),
  WordEntry('Airport', 'हवाई अड्डा', 'PLACES', 'जगहें'),
  WordEntry('Cinema', 'सिनेमा', 'PLACES', 'जगहें'),
  WordEntry('Beach', 'समुद्र तट', 'PLACES', 'जगहें'),
  WordEntry('Doctor', 'डॉक्टर', 'JOBS', 'पेशे'),
  WordEntry('Teacher', 'शिक्षक', 'JOBS', 'पेशे'),
  WordEntry('Pilot', 'पायलट', 'JOBS', 'पेशे'),
  WordEntry('Chef', 'रसोइया', 'JOBS', 'पेशे'),
  WordEntry('Astronaut', 'अंतरिक्ष यात्री', 'JOBS', 'पेशे'),
  WordEntry('Laptop', 'लैपटॉप', 'TECHNOLOGY', 'तकनीक'),
  WordEntry('Smartphone', 'स्मार्टफ़ोन', 'TECHNOLOGY', 'तकनीक'),
  WordEntry('Headphones', 'हेडफ़ोन', 'TECHNOLOGY', 'तकनीक'),
  WordEntry('Camera', 'कैमरा', 'TECHNOLOGY', 'तकनीक'),
  WordEntry('Keyboard', 'कीबोर्ड', 'TECHNOLOGY', 'तकनीक'),
  WordEntry('Dragon', 'ड्रैगन', 'FANTASY', 'काल्पनिक'),
  WordEntry('Vampire', 'पिशाच', 'FANTASY', 'काल्पनिक'),
  WordEntry('Robot', 'रोबोट', 'FANTASY', 'काल्पनिक'),
  WordEntry('Wizard', 'जादूगर', 'FANTASY', 'काल्पनिक'),
  WordEntry('Superhero', 'सुपरहीरो', 'FANTASY', 'काल्पनिक'),
  WordEntry('Diwali', 'दिवाली', 'FESTIVALS', 'त्योहार'),
  WordEntry('Holi', 'होली', 'FESTIVALS', 'त्योहार'),
  WordEntry('Wedding', 'शादी', 'EVENTS', 'आयोजन'),
  WordEntry('Birthday', 'जन्मदिन', 'EVENTS', 'आयोजन'),
  WordEntry('Train', 'रेलगाड़ी', 'TRANSPORT', 'यातायात'),
  WordEntry('Bicycle', 'साइकिल', 'TRANSPORT', 'यातायात'),
  WordEntry('Airplane', 'हवाई जहाज़', 'TRANSPORT', 'यातायात'),
  WordEntry('Motorcycle', 'मोटरसाइकिल', 'TRANSPORT', 'यातायात'),
  WordEntry('Bus', 'बस', 'TRANSPORT', 'यातायात'),
  WordEntry('Guitar', 'गिटार', 'MUSIC', 'संगीत'),
  WordEntry('Drums', 'ड्रम', 'MUSIC', 'संगीत'),
  WordEntry('Piano', 'पियानो', 'MUSIC', 'संगीत'),
  WordEntry('Flute', 'बांसुरी', 'MUSIC', 'संगीत'),
  WordEntry('Violin', 'वायलिन', 'MUSIC', 'संगीत'),
];

class RoundRecord {
  RoundRecord({
    required this.date,
    required this.word,
    required this.imposter,
    required this.players,
    required this.voteTotals,
    required this.points,
    required this.scores,
    required this.caught,
  });

  final String date;
  final WordEntry word;
  final String imposter;
  final List<String> players;
  final List<int> voteTotals;
  final List<int> points;
  final List<int> scores;
  final bool caught;
  String get category => word.category;

  Map<String, dynamic> toJson() => {
        'date': date,
        'word': word.toJson(),
        'imposter': imposter,
        'players': players,
        'voteTotals': voteTotals,
        'points': points,
        'scores': scores,
        'caught': caught,
      };

  factory RoundRecord.fromJson(Map<String, dynamic> j) => RoundRecord(
        date: j['date'] as String? ?? '',
        word: WordEntry.fromJson(Map<String, dynamic>.from(j['word'] as Map)),
        imposter: j['imposter'] as String? ?? '',
        players: List<String>.from(j['players'] as List? ?? const []),
        voteTotals: List<int>.from(j['voteTotals'] as List? ?? const []),
        points: List<int>.from(j['points'] as List? ?? const []),
        scores: List<int>.from(j['scores'] as List? ?? const []),
        caught: j['caught'] as bool? ?? false,
      );
}

class ImposterApp extends StatelessWidget {
  const ImposterApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'IMPOSTER',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: bg,
          colorScheme: const ColorScheme.dark(
            primary: primary,
            secondary: accent,
            surface: card,
          ),
          fontFamily: 'Roboto',
          useMaterial3: true,
        ),
        home: const LaunchSplash(),
      );
}

class LaunchSplash extends StatefulWidget {
  const LaunchSplash({super.key});

  @override
  State<LaunchSplash> createState() => _LaunchSplashState();
}

class _LaunchSplashState extends State<LaunchSplash> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const GameHome()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: bg,
        body: SizedBox.expand(
          child: Image.asset(
            'assets/icons/presplash.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Center(
              child: Text('IMPOSTER',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
            ),
          ),
        ),
      );
}

enum Phase { menu, reveal, passToNext, discuss, voting, passVote, summary, results, history, historyDetail }

class GameHome extends StatefulWidget {
  const GameHome({super.key});

  @override
  State<GameHome> createState() => _GameHomeState();
}

class _GameHomeState extends State<GameHome> with TickerProviderStateMixin {
  final Random _random = Random();
  final List<TextEditingController> _controllers = [];
  final List<String> _players = ['Player 1', 'Player 2', 'Player 3'];
  final Map<int, int> _votes = {};
  final Map<String, int> _scores = {};
  final List<RoundRecord> _history = [];
  Phase _phase = Phase.menu;
  int _revealIndex = 0;
  int _voterIndex = 0;
  int? _selectedVote;
  int _imposterIndex = 0;
  WordEntry? _word;
  String? _lastWord;
  RoundRecord? _selectedHistory;
  bool _revealed = false;
  bool _busy = false;
  DateTime? _lastBackAttempt;
  int _revealAutoHideToken = 0;
  late final AnimationController _curtainController;
  late final Animation<Offset> _curtainSlide;

  @override
  void initState() {
    super.initState();
    _syncControllers();
    _curtainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
    );
    _curtainSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -1.05),
    ).animate(CurvedAnimation(parent: _curtainController, curve: Curves.easeInOutCubic));
    _loadHistory();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    _curtainController.dispose();
    super.dispose();
  }

  void _syncControllers() {
    while (_controllers.length < _players.length) {
      final c = TextEditingController(text: _players[_controllers.length]);
      _controllers.add(c);
    }
    while (_controllers.length > _players.length) {
      _controllers.removeLast().dispose();
    }
    for (var i = 0; i < _players.length; i++) {
      if (_controllers[i].text != _players[i]) _controllers[i].text = _players[i];
    }
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('imposter_history_v1');
    final scoreRaw = prefs.getString('imposter_scores_v1');
    if (!mounted) return;
    setState(() {
      if (raw != null) {
        try {
          _history
            ..clear()
            ..addAll((jsonDecode(raw) as List).map(
              (e) => RoundRecord.fromJson(Map<String, dynamic>.from(e as Map)),
            ));
        } catch (_) {
          _history.clear();
        }
      }
      if (scoreRaw != null) {
        try {
          _scores
            ..clear()
            ..addAll(Map<String, dynamic>.from(jsonDecode(scoreRaw) as Map)
                .map((k, v) => MapEntry(k, (v as num).toInt())));
        } catch (_) {
          _scores.clear();
        }
      }
    });
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('imposter_history_v1', jsonEncode(_history.map((e) => e.toJson()).toList()));
    await prefs.setString('imposter_scores_v1', jsonEncode(_scores));
  }

  void _go(Phase p) {
    _revealAutoHideToken++;
    _curtainController.stop();
    setState(() {
      _phase = p;
      if (p != Phase.reveal) _revealed = false;
    });
  }

  void _handleBack() {
    final now = DateTime.now();
    final secondPress = _lastBackAttempt != null &&
        now.difference(_lastBackAttempt!) <= const Duration(seconds: 2);
    if (secondPress) {
      _lastBackAttempt = null;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (_phase == Phase.menu) {
        SystemNavigator.pop();
      } else {
        _go(Phase.menu);
      }
      return;
    }

    _lastBackAttempt = now;
    final onMenu = _phase == Phase.menu;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(onMenu
              ? 'Press back again to quit IMPOSTER'
              : 'Press back again to return to the main menu'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          backgroundColor: card2,
        ),
      );
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted &&
          _lastBackAttempt == now &&
          DateTime.now().difference(now) >= const Duration(seconds: 2)) {
        _lastBackAttempt = null;
      }
    });
  }

  void _scheduleRevealAutoHide() {
    final token = ++_revealAutoHideToken;
    Future<void>.delayed(const Duration(seconds: 5), () {
      if (!mounted ||
          token != _revealAutoHideToken ||
          _phase != Phase.reveal ||
          !_revealed) {
        return;
      }
      setState(() => _revealed = false);
      _curtainController.reverse();
    });
  }

  void _addPlayer() {
    if (_players.length >= 10) return;
    setState(() {
      _players.add('Player ${_players.length + 1}');
      _syncControllers();
    });
  }

  void _removePlayer(int i) {
    if (_players.length <= 3) return;
    setState(() {
      _players.removeAt(i);
      _syncControllers();
    });
  }

  void _startRound() {
    if (_busy || _players.length < 3 || _players.length > 10) return;
    setState(() {
      _busy = true;
      for (var i = 0; i < _players.length; i++) {
        _players[i] = _controllers[i].text.trim().isEmpty ? 'Player ${i + 1}' : _controllers[i].text.trim();
      }
      _syncControllers();
      final choices = wordDatabase.where((w) => w.word != _lastWord).toList();
      _word = choices[_random.nextInt(choices.length)];
      _lastWord = _word!.word;
      _imposterIndex = _random.nextInt(_players.length);
      _votes.clear();
      _revealIndex = 0;
      _voterIndex = 0;
      _selectedVote = null;
      _revealed = false;
      for (final p in _players) {
        _scores.putIfAbsent(p, () => 0);
      }
      _phase = Phase.reveal;
    });
    _curtainController.reset();
    setState(() => _busy = false);
  }

  void _revealRole() {
    if (_revealed) {
      // Any tap on the revealed card restarts the five-second privacy timer.
      _scheduleRevealAutoHide();
      return;
    }
    setState(() => _revealed = true);
    _curtainController.forward();
    _scheduleRevealAutoHide();
  }

  void _nextReveal() {
    if (!_revealed) return;
    _revealAutoHideToken++;
    _curtainController.stop();
    setState(() {
      _revealed = false;
      _phase = _revealIndex == _players.length - 1
          ? Phase.discuss
          : Phase.passToNext;
    });
    _curtainController.reset();
  }

  void _passToNextPlayer() {
    if (_phase != Phase.passToNext || _revealIndex >= _players.length - 1) return;
    setState(() {
      _revealIndex++;
      _revealed = false;
      _phase = Phase.reveal;
    });
    _curtainController.reset();
  }

  void _beginVoting() {
    setState(() {
      _voterIndex = 0;
      _selectedVote = null;
      _votes.clear();
      _phase = Phase.voting;
    });
  }

  void _confirmVote() {
    if (_selectedVote == null) return;
    setState(() {
      _votes[_voterIndex] = _selectedVote!;
      _selectedVote = null;
      if (_voterIndex == _players.length - 1) {
        _phase = Phase.summary;
      } else {
        _phase = Phase.passVote;
      }
    });
  }

  List<int> _voteTotals() {
    final totals = List<int>.filled(_players.length, 0);
    for (final target in _votes.values) {
      if (target >= 0 && target < totals.length) totals[target]++;
    }
    return totals;
  }

  List<int> _leaders(List<int> totals) {
    final maxVotes = totals.reduce(max);
    return [for (var i = 0; i < totals.length; i++) if (totals[i] == maxVotes) i];
  }

  Future<void> _finishRound() async {
    final totals = _voteTotals();
    final leaders = _leaders(totals);
    final caught = leaders.length == 1 && leaders.first == _imposterIndex;
    final points = List<int>.filled(_players.length, 0);
    if (!caught) points[_imposterIndex] = 2;
    for (final entry in _votes.entries) {
      if (entry.key == _imposterIndex) continue;
      points[entry.key] = entry.value == _imposterIndex ? 1 : -1;
    }
    for (var i = 0; i < _players.length; i++) {
      _scores[_players[i]] = (_scores[_players[i]] ?? 0) + points[i];
    }
    final record = RoundRecord(
      date: DateTime.now().toIso8601String(),
      word: _word!,
      imposter: _players[_imposterIndex],
      players: List<String>.from(_players),
      voteTotals: totals,
      points: points,
      scores: _players.map((p) => _scores[p] ?? 0).toList(),
      caught: caught,
    );
    setState(() {
      _history.insert(0, record);
      _selectedHistory = record;
      _phase = Phase.results;
    });
    await _persist();
  }

  Future<void> _clearHistory() async {
    setState(() => _history.clear());
    await _persist();
  }

  void _playAgain() => _startRound();

  Widget _page(Widget child) => SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOutCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, .035), end: Offset.zero).animate(animation),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(key: ValueKey(_phase), child: child),
              ),
            ),
          ),
        ),
      );

  Widget _panel(Widget child, {EdgeInsets padding = const EdgeInsets.all(14)}) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: card.withValues(alpha: .94),
          border: Border.all(color: accent.withValues(alpha: .9)),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 25, offset: Offset(0, 10))],
        ),
        child: child,
      );

  Widget _button(String label, VoidCallback? onPressed, {bool main = false, bool compact = false}) => SizedBox(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.only(top: compact ? 8 : 12),
          child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: main ? primary : card2,
              foregroundColor: Colors.white,
              disabledBackgroundColor: card2.withValues(alpha: .5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: BorderSide(color: main ? const Color(0xFFFF6390) : accent),
              ),
              minimumSize: Size.fromHeight(compact ? 44 : 52),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: .7),
            ),
            child: Text(label, textAlign: TextAlign.center),
          ),
        ),
      );

  Widget _heading(String title, {String? subtitle}) => Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .10),
              border: Border.all(color: accent),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: accent.withValues(alpha: .12), blurRadius: 22)],
            ),
            child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 2)),
          ),
          if (subtitle != null) Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 14),
            child: Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: muted, fontWeight: FontWeight.w700, letterSpacing: 1)),
          ),
        ],
      );

  Widget _nav() => Center(
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(color: const Color(0xCC170925), border: Border.all(color: muted.withValues(alpha: .6)), borderRadius: BorderRadius.circular(28)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            TextButton(onPressed: () => _go(Phase.menu), child: const Text('GAME')),
            TextButton(onPressed: () => _go(Phase.history), child: const Text('HISTORY')),
          ]),
        ),
      );

  Widget _menu() => Column(
        key: const ValueKey('menu'),
        children: [
          _nav(),
          _heading('IMPOSTER', subtitle: 'ONE WORD. ONE FAKE. FIND THEM.'),
          const SizedBox(height: 4),
          Expanded(
            child: SingleChildScrollView(
              child: _panel(Column(
                children: List.generate(_players.length, (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Row(children: [
                    const Icon(Icons.person, color: muted, size: 28),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(
                      key: ValueKey('player-$i'),
                      controller: _controllers[i],
                      onChanged: (v) => _players[i] = v,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'Player name',
                        filled: true,
                        fillColor: card2,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
                      ),
                    )),
                    if (_players.length > 3) IconButton(onPressed: () => _removePlayer(i), icon: const Icon(Icons.remove_circle, color: danger)),
                  ]),
                )),
              )),
            ),
          ),
          _button('+ ADD PLAYER', _players.length < 10 ? _addPlayer : null),
          _button('PLAY', _startRound, main: true),
          const Padding(padding: EdgeInsets.only(top: 10), child: Text('Pass the phone. Find the fake.', style: TextStyle(color: muted))),
        ],
      );

  Widget _reveal() {
    final player = _players[_revealIndex];
    final isImposter = _revealIndex == _imposterIndex;
    return Column(
      key: const ValueKey('reveal'),
      children: [
        const SizedBox(height: 6),
        Text(player.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 29, fontWeight: FontWeight.w900)),
        const Text("It's your turn.", style: TextStyle(color: muted, fontSize: 17)),
        const SizedBox(height: 18),
        Expanded(
          child: Stack(children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: card, border: Border.all(color: accent), borderRadius: BorderRadius.circular(28)),
              padding: const EdgeInsets.all(24),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  child: !_revealed
                      ? const Text('PRIVATE ROLE REVEAL', key: ValueKey('hidden'), style: TextStyle(color: muted, fontWeight: FontWeight.w800, letterSpacing: 1))
                      : Column(
                          key: const ValueKey('shown'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: isImposter
                              ? [
                                  const Text('YOUR ROLE', style: TextStyle(color: muted)),
                                  const SizedBox(height: 8),
                                  const Text('YOU ARE THE IMPOSTER', textAlign: TextAlign.center, style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900, color: primary)),
                                  const SizedBox(height: 20),
                                  const Text('YOUR CATEGORY', style: TextStyle(color: muted)),
                                  Text(_word!.category, textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                                  Text(_word!.categoryHi, style: const TextStyle(color: muted, fontSize: 18)),
                                ]
                              : [
                                  const Text('WORD', style: TextStyle(color: muted)),
                                  Text(_word!.word, textAlign: TextAlign.center, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
                                  Text(_word!.wordHi, textAlign: TextAlign.center, style: const TextStyle(color: muted, fontSize: 20)),
                                  const SizedBox(height: 14),
                                  const Text('CATEGORY', style: TextStyle(color: muted)),
                                  Text(_word!.category, textAlign: TextAlign.center, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
                                  Text(_word!.categoryHi, style: const TextStyle(color: muted, fontSize: 18)),
                                ],
                        ),
                ),
              ),
            ),
            SlideTransition(
              position: _curtainSlide,
              child: GestureDetector(
                onTap: _revealRole,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(28), boxShadow: const [BoxShadow(color: Color(0x33AD40FF), blurRadius: 30, spreadRadius: 2)]),
                  child: const Center(
                    child: Text('TAP HERE TO\nREVEAL YOUR ROLE', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: .7)),
                  ),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 10),
        _button(_revealIndex == _players.length - 1 ? 'FINISH REVEAL' : 'CONTINUE', _revealed ? _nextReveal : null, main: true),
        const Padding(padding: EdgeInsets.only(top: 10), child: Text('Keep the screen private, then pass the phone.', textAlign: TextAlign.center, style: TextStyle(color: muted))),
      ],
    );
  }

  Widget _passToNext() {
    final nextPlayer = _players[_revealIndex + 1];
    return Column(
      key: const ValueKey('passToNext'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.swap_horiz_rounded, color: accent, size: 64),
        const SizedBox(height: 20),
        const Text(
          'PASS THE PHONE',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        const SizedBox(height: 12),
        Text(
          'Pass to ${nextPlayer.toUpperCase()}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: primary),
        ),
        const SizedBox(height: 10),
        const Text(
          'Make sure the next player is ready before continuing.',
          textAlign: TextAlign.center,
          style: TextStyle(color: muted, fontSize: 16, height: 1.4),
        ),
        const SizedBox(height: 24),
        _panel(const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.visibility_off_outlined, color: accent),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                'Your role is hidden. Keep it secret.',
                textAlign: TextAlign.center,
                style: TextStyle(color: muted, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        )),
        const SizedBox(height: 14),
        _button('PASS TO ${nextPlayer.toUpperCase()}', _passToNextPlayer, main: true),
      ],
    );
  }

  Widget _discuss() => Column(
        key: const ValueKey('discuss'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.forum_outlined, color: accent, size: 58),
          const SizedBox(height: 12),
          const Text('DISCUSS IRL', style: TextStyle(fontSize: 31, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          const Text('The secret words have been revealed. Put the phone down and discuss your clues. Talk it out, make accusations, defend yourself, and decide who the Imposter is.', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 17, height: 1.45)),
          _button('READY TO VOTE?', _beginVoting, main: true),
        ],
      );

  Widget _voting() {
    final voter = _players[_voterIndex];
    return Column(
      key: const ValueKey('voting'),
      children: [
        Text('${voter.toUpperCase()} — VOTE', textAlign: TextAlign.center, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        const Text('Who do you think is the Imposter?', textAlign: TextAlign.center, style: TextStyle(color: muted)),
        const SizedBox(height: 14),
        Expanded(
          child: GridView.builder(
            itemCount: _players.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.sizeOf(context).width < 400 ? 1 : 2,
              mainAxisExtent: 68,
              crossAxisSpacing: 9,
              mainAxisSpacing: 9,
            ),
            itemBuilder: (context, i) => OutlinedButton(
              onPressed: () => setState(() => _selectedVote = i),
              style: OutlinedButton.styleFrom(
                backgroundColor: _selectedVote == i ? primary : card,
                foregroundColor: Colors.white,
                side: BorderSide(color: _selectedVote == i ? const Color(0xFFFF6390) : accent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              child: Text(_players[i].toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ),
        _button(_voterIndex == _players.length - 1 ? 'LOCK VOTE & SHOW SUMMARY' : 'CONTINUE', _confirmVote, main: true),
        const Padding(padding: EdgeInsets.only(top: 8), child: Text('Your vote stays private between turns.', style: TextStyle(color: muted, fontSize: 13))),
      ],
    );
  }

  Widget _passToNextVoter() {
    final nextVoter = _players[_voterIndex + 1];
    return Column(
      key: const ValueKey('passVote'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.how_to_vote_outlined, color: accent, size: 64),
        const SizedBox(height: 20),
        const Text(
          'PASS THE PHONE',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        const SizedBox(height: 12),
        Text(
          'Pass to ${nextVoter.toUpperCase()}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: primary),
        ),
        const SizedBox(height: 10),
        const Text(
          'Keep your vote private. Let the next player vote without seeing your selection.',
          textAlign: TextAlign.center,
          style: TextStyle(color: muted, fontSize: 16, height: 1.4),
        ),
        const SizedBox(height: 24),
        _panel(const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.visibility_off_outlined, color: accent),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                'Previous vote is hidden.',
                textAlign: TextAlign.center,
                style: TextStyle(color: muted, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        )),
        const SizedBox(height: 14),
        _button('PASS TO ${nextVoter.toUpperCase()}', _passToNextVoter, main: true),
      ],
    );
  }

  Widget _summary() {
    final totals = _voteTotals();
    final leaders = _leaders(totals);
    final maxVotes = totals.reduce(max);
    return Column(
      key: const ValueKey('summary'),
      children: [
        const Text('VOTE SUMMARY', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900)),
        const SizedBox(height: 14),
        Expanded(child: SingleChildScrollView(child: _panel(Column(children: List.generate(_players.length, (i) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(children: [
            SizedBox(width: 100, child: Text(_players[i], overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700))),
            Expanded(child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: maxVotes == 0 ? 0 : totals[i] / maxVotes, minHeight: 12, backgroundColor: card2, color: leaders.contains(i) ? primary : accent),
            )),
            const SizedBox(width: 10),
            SizedBox(width: 20, child: Text('${totals[i]}')),
          ]),
        )))))),
        Text(leaders.length > 1 ? 'Tie detected — nobody has a sole top vote.' : 'Top vote: ${_players[leaders.first]}', textAlign: TextAlign.center, style: const TextStyle(color: muted)),
        _button('REVEAL RESULTS', _finishRound, main: true),
      ],
    );
  }

  Widget _results() {
    final record = _selectedHistory!;
    return Column(
      key: const ValueKey('results'),
      children: [
        Text(record.caught ? 'IMPOSTER CAUGHT' : 'IMPOSTER NOT CAUGHT', textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
        const SizedBox(height: 14),
        _panel(Column(children: [
          const Text('WORD', style: TextStyle(color: muted, fontWeight: FontWeight.w700)),
          Text(record.word.word, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
          Text(record.word.wordHi, style: const TextStyle(color: muted, fontSize: 18)),
          const SizedBox(height: 10),
          const Text('CATEGORY', style: TextStyle(color: muted, fontWeight: FontWeight.w700)),
          Text(record.word.category, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
          Text(record.word.categoryHi, style: const TextStyle(color: muted, fontSize: 18)),
        ])),
        const SizedBox(height: 10),
        _panel(Column(children: [
          const Text('IMPOSTER', style: TextStyle(color: muted, fontWeight: FontWeight.w700)),
          Text(record.imposter, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Divider(color: accent),
          const Text('SCOREBOARD', style: TextStyle(color: muted, fontWeight: FontWeight.w800)),
          ...List.generate(record.players.length, (i) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              Expanded(child: Text(record.players[i])),
              Text('${record.points[i] > 0 ? '+' : ''}${record.points[i]}', style: TextStyle(fontWeight: FontWeight.w900, color: record.points[i] > 0 ? good : record.points[i] < 0 ? danger : Colors.white)),
              const SizedBox(width: 22),
              SizedBox(width: 35, child: Text('${record.scores[i]}', textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w900))),
            ]),
          )),
        ])),
        _button('PLAY AGAIN', _playAgain, main: true),
        _button('MAIN MENU', () => _go(Phase.menu)),
      ],
    );
  }

  Widget _historyPage() => Column(
        key: const ValueKey('history'),
        children: [
          Row(children: [
            const Expanded(child: Text('HISTORY', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900))),
            TextButton(onPressed: _history.isEmpty ? null : _clearHistory, child: const Text('CLEAR', style: TextStyle(color: danger))),
          ]),
          Expanded(child: _history.isEmpty
              ? Center(child: _panel(const Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('NO MATCHES YET', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                  SizedBox(height: 5),
                  Text('Finish a round and it will appear here.', textAlign: TextAlign.center, style: TextStyle(color: muted)),
                ])))
              : ListView.separated(
                  itemCount: _history.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 9),
                  itemBuilder: (context, i) {
                    final r = _history[i];
                    return _panel(InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() {
                        _selectedHistory = r;
                        _phase = Phase.historyDetail;
                      }),
                      child: Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(r.word.word, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                          Text(r.word.category, style: const TextStyle(color: muted, fontSize: 12)),
                        ])),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text(r.caught ? 'CAUGHT' : 'ESCAPED', style: const TextStyle(fontWeight: FontWeight.w800)),
                          Text(_formatDate(r.date), style: const TextStyle(color: muted, fontSize: 12)),
                        ]),
                      ]),
                    ));
                  },
                )),
          _button('BACK TO GAME', () => _go(Phase.menu), main: true),
        ],
      );

  Widget _historyDetail() {
    final r = _selectedHistory!;
    return Column(
      key: const ValueKey('historyDetail'),
      children: [
        const Text('ROUND HISTORY', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
        const SizedBox(height: 14),
        _panel(Column(children: [
          Text(r.word.word, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
          Text(r.word.wordHi, style: const TextStyle(color: muted)),
          Text(r.word.category, style: const TextStyle(fontWeight: FontWeight.w800)),
          Text(r.word.categoryHi, style: const TextStyle(color: muted)),
          const Divider(color: accent),
          Text('Imposter: ${r.imposter}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          Text(r.caught ? 'Caught' : 'Not caught', style: const TextStyle(color: muted)),
          const SizedBox(height: 10),
          ...List.generate(r.players.length, (i) => Row(children: [
            Expanded(child: Text(r.players[i])),
            Text('${r.voteTotals[i]} votes · ${r.points[i] > 0 ? '+' : ''}${r.points[i]} pts · total ${r.scores[i]}'),
          ])),
        ])),
        const Spacer(),
        _button('BACK TO HISTORY', () => _go(Phase.history)),
        _button('BACK TO GAME', () => _go(Phase.menu), main: true),
      ],
    );
  }

  String _formatDate(String raw) {
    final date = DateTime.tryParse(raw)?.toLocal();
    if (date == null) return raw;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final Widget body;
    switch (_phase) {
      case Phase.menu:
        body = _menu();
      case Phase.reveal:
        body = _reveal();
      case Phase.passToNext:
        body = _passToNext();
      case Phase.discuss:
        body = _discuss();
      case Phase.voting:
        body = _voting();
      case Phase.passVote:
        body = _passToNextVoter();
      case Phase.summary:
        body = _summary();
      case Phase.results:
        body = _results();
      case Phase.history:
        body = _historyPage();
      case Phase.historyDetail:
        body = _historyDetail();
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.85, -0.95),
            radius: 1.3,
            colors: [Color(0xFF401067), bg],
          ),
        ),
        child: _page(body),
      ),
      ),
    );
  }
}
