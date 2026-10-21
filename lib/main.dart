import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const ImposterApp());

class GamePalette {
  const GamePalette({required this.name, required this.background, required this.card, required this.card2, required this.accent, required this.primary, required this.muted});
  final String name;
  final Color background, card, card2, accent, primary, muted;

  static GamePalette lerp(GamePalette a, GamePalette b, double t) => GamePalette(
    name: b.name,
    background: Color.lerp(a.background, b.background, t)!,
    card: Color.lerp(a.card, b.card, t)!,
    card2: Color.lerp(a.card2, b.card2, t)!,
    accent: Color.lerp(a.accent, b.accent, t)!,
    primary: Color.lerp(a.primary, b.primary, t)!,
    muted: Color.lerp(a.muted, b.muted, t)!,
  );
}

class GamePaletteTween extends Tween<GamePalette> {
  GamePaletteTween({super.begin, required super.end});

  @override
  GamePalette lerp(double t) => GamePalette.lerp(begin ?? end!, end!, t);
}

const List<GamePalette> gamePalettes = [
  GamePalette(name: 'Violet Pop', background: Color(0xFF090413), card: Color(0xFF211039), card2: Color(0xFF331452), accent: Color(0xFFAD40FF), primary: Color(0xFFFF1F61), muted: Color(0xFFB89ED9)),
  GamePalette(name: 'Ocean', background: Color(0xFF041116), card: Color(0xFF102C36), card2: Color(0xFF174453), accent: Color(0xFF35D4E8), primary: Color(0xFF00A6C7), muted: Color(0xFFA7DCE5)),
  GamePalette(name: 'Emerald', background: Color(0xFF06130D), card: Color(0xFF132C20), card2: Color(0xFF1D4430), accent: Color(0xFF57E39A), primary: Color(0xFF19B96C), muted: Color(0xFFB0E5C7)),
  GamePalette(name: 'Sunset', background: Color(0xFF1B0B08), card: Color(0xFF38201A), card2: Color(0xFF542D22), accent: Color(0xFFFFB15C), primary: Color(0xFFFF5C49), muted: Color(0xFFFFD2B7)),
  GamePalette(name: 'Rose', background: Color(0xFF190710), card: Color(0xFF351324), card2: Color(0xFF501A34), accent: Color(0xFFFF75B5), primary: Color(0xFFE92F78), muted: Color(0xFFF1B8D4)),
  GamePalette(name: 'Monochrome', background: Color(0xFF08090B), card: Color(0xFF1D2025), card2: Color(0xFF30343B), accent: Color(0xFFCED4DE), primary: Color(0xFF777F8C), muted: Color(0xFFD0D4DC)),
];

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

class ImposterApp extends StatefulWidget {
  const ImposterApp({super.key});
  @override
  State<ImposterApp> createState() => _ImposterAppState();
}

class _ImposterAppState extends State<ImposterApp> {
  int _paletteIndex = 0;
  void _selectPalette(int index) {
    if (index >= 0 && index < gamePalettes.length && index != _paletteIndex) {
      setState(() => _paletteIndex = index);
    }
  }
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<GamePalette>(
    tween: GamePaletteTween(end: gamePalettes[_paletteIndex]),
    duration: const Duration(milliseconds: 380),
    curve: Curves.easeInOutCubic,
    builder: (context, palette, _) {
      final theme = ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: palette.background,
        colorScheme: ColorScheme.dark(primary: palette.primary, secondary: palette.accent, surface: palette.card),
        fontFamily: 'Roboto',
        useMaterial3: true,
      );
      return PaletteScope(
        palette: palette,
        selectedIndex: _paletteIndex,
        onSelect: _selectPalette,
        child: MaterialApp(
          title: 'IMPOSTER',
          debugShowCheckedModeBanner: false,
          theme: theme,
          themeAnimationDuration: Duration.zero,
          home: const LaunchSplash(),
        ),
      );
    },
  );
}

class PaletteScope extends InheritedWidget {
  const PaletteScope({super.key, required this.palette, required this.selectedIndex, required this.onSelect, required super.child});
  final GamePalette palette;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  static PaletteScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PaletteScope>();
    assert(scope != null, 'PaletteScope not found');
    return scope!;
  }
  @override
  bool updateShouldNotify(PaletteScope oldWidget) => palette != oldWidget.palette || selectedIndex != oldWidget.selectedIndex;
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
        backgroundColor: PaletteScope.of(context).palette.background,
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

enum Phase { menu, reveal, passToNext, discuss, voting, summary, results, history, historyDetail }

class GameHome extends StatefulWidget {
  const GameHome({super.key});

  @override
  State<GameHome> createState() => _GameHomeState();
}

class _GameHomeState extends State<GameHome> with TickerProviderStateMixin {
  final Random _random = Random();
  final List<TextEditingController> _controllers = [];
  final List<String> _players = ['', '', ''];
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
      duration: Duration(milliseconds: 460),
    );
    _curtainSlide = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, -1.05),
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
      _controllers.add(TextEditingController(text: _players[_controllers.length]));
    }
    while (_controllers.length > _players.length) {
      _controllers.removeLast().dispose();
    }
    for (var i = 0; i < _players.length; i++) {
      if (_controllers[i].text != _players[i]) {
        _controllers[i].value = TextEditingValue(
          text: _players[i],
          selection: TextSelection.collapsed(offset: _players[i].length),
        );
      }
    }
  }

  void _updatePlayerName(int index, String value) {
    if (index >= 0 && index < _players.length) {
      _players[index] = value;
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
        now.difference(_lastBackAttempt!) <= Duration(seconds: 2);
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
          content: Text(
            onMenu
                ? 'Press back again to quit IMPOSTER'
                : 'Press back again to return to the main menu',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
          ),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(18, 0, 18, 54),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          backgroundColor: Colors.white,
        ),
      );
    Future<void>.delayed(Duration(seconds: 2), () {
      if (mounted &&
          _lastBackAttempt == now &&
          DateTime.now().difference(now) >= Duration(seconds: 2)) {
        _lastBackAttempt = null;
      }
    });
  }

  void _scheduleRevealAutoHide() {
    final token = ++_revealAutoHideToken;
    Future<void>.delayed(Duration(seconds: 5), () {
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
      _players.add('');
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
      // Any tap on the revealed PaletteScope.of(context).palette.card restarts the five-second privacy timer.
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
        _voterIndex++;
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
            constraints: BoxConstraints(maxWidth: 620),
            child: Padding(
              padding: EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 280),
                switchInCurve: Curves.easeOutCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: Offset(0, .035), end: Offset.zero).animate(animation),
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
          color: PaletteScope.of(context).palette.card.withValues(alpha: .94),
          border: Border.all(color: PaletteScope.of(context).palette.accent.withValues(alpha: .9)),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .32), blurRadius: 25, offset: Offset(0, 10))],
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
              backgroundColor: main ? PaletteScope.of(context).palette.primary : PaletteScope.of(context).palette.card2,
              foregroundColor: Colors.white,
              disabledBackgroundColor: PaletteScope.of(context).palette.card2.withValues(alpha: .5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: BorderSide(color: main ? Color(0xFFFF6390) : PaletteScope.of(context).palette.accent),
              ),
              minimumSize: Size.fromHeight(compact ? 44 : 52),
              textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: .7),
            ),
            child: Text(label, textAlign: TextAlign.center),
          ),
        ),
      );

  Widget _heading(String title, {String? subtitle}) => Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: PaletteScope.of(context).palette.accent.withValues(alpha: .10),
              border: Border.all(color: PaletteScope.of(context).palette.accent),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: PaletteScope.of(context).palette.accent.withValues(alpha: .12), blurRadius: 22)],
            ),
            child: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 2)),
          ),
          if (subtitle != null) Padding(
            padding: EdgeInsets.only(top: 8, bottom: 14),
            child: Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: PaletteScope.of(context).palette.muted, fontWeight: FontWeight.w700, letterSpacing: 1)),
          ),
        ],
      );

  Widget _nav() => Center(
        child: Container(
          margin: EdgeInsets.only(bottom: 14),
          padding: EdgeInsets.all(3),
          decoration: BoxDecoration(color: PaletteScope.of(context).palette.background.withValues(alpha: .86), border: Border.all(color: PaletteScope.of(context).palette.muted.withValues(alpha: .6)), borderRadius: BorderRadius.circular(28)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            TextButton(onPressed: () => _go(Phase.menu), child: Text('GAME')),
            TextButton(onPressed: () => _go(Phase.history), child: Text('HISTORY')),
          ]),
        ),
      );

  Widget _themeButton() {
    final scope = PaletteScope.of(context);
    return Padding(
      padding: EdgeInsets.only(top: 2, bottom: 4),
      child: OutlinedButton.icon(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          backgroundColor: scope.palette.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          builder: (sheetContext) => SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CHOOSE YOUR COLOUR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: scope.palette.muted)),
                  SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(gamePalettes.length, (i) {
                      final item = gamePalettes[i];
                      final selected = i == scope.selectedIndex;
                      return Semantics(
                        button: true,
                        selected: selected,
                        label: item.name,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () {
                            scope.onSelect(i);
                            Navigator.of(sheetContext).pop();
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 250),
                            curve: Curves.easeInOutCubic,
                            width: 142,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: item.card2,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: selected ? item.accent : item.card2, width: selected ? 2.5 : 1),
                            ),
                            child: Row(
                              children: [
                                Container(width: 34, height: 34, decoration: BoxDecoration(color: item.primary, shape: BoxShape.circle, border: Border.all(color: item.accent, width: 3))),
                                SizedBox(width: 10),
                                Expanded(child: Text(item.name, style: TextStyle(fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis)),
                                if (selected) Icon(Icons.check_circle, color: item.accent, size: 18),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
        icon: Icon(Icons.palette_outlined, color: scope.palette.accent),
        label: Text('COLOURS · ${scope.palette.name}', style: TextStyle(color: scope.palette.muted, fontWeight: FontWeight.w800)),
        style: OutlinedButton.styleFrom(side: BorderSide(color: scope.palette.accent), shape: StadiumBorder(), padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
      ),
    );
  }

  Widget _menu() => Column(
        key: ValueKey('menu'),
        children: [
          _nav(),
          _heading('IMPOSTER', subtitle: 'ONE WORD. ONE FAKE. FIND THEM.'),
          _themeButton(),
          SizedBox(height: 4),
          Expanded(
            child: SingleChildScrollView(
              child: _panel(Column(
                children: List.generate(_players.length, (i) => Padding(
                  padding: EdgeInsets.only(bottom: 9),
                  child: Row(children: [
                    Icon(Icons.person, color: PaletteScope.of(context).palette.muted, size: 28),
                    SizedBox(width: 8),
                    Expanded(child: TextField(
                      key: ValueKey('player-$i'),
                      controller: _controllers[i],
                      onChanged: (v) => _updatePlayerName(i, v),
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'Enter player ${i + 1} name',
                        filled: true,
                        fillColor: PaletteScope.of(context).palette.card2,
                        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(28), borderSide: BorderSide.none),
                      ),
                    )),
                    if (_players.length > 3) IconButton(onPressed: () => _removePlayer(i), icon: Icon(Icons.remove_circle, color: danger)),
                  ]),
                )),
              )),
            ),
          ),
          _button('+ ADD PLAYER', _players.length < 10 ? _addPlayer : null),
          _button('PLAY', _startRound, main: true),
          Padding(padding: EdgeInsets.only(top: 10), child: Text('Pass the phone. Find the fake.', style: TextStyle(color: PaletteScope.of(context).palette.muted))),
        ],
      );

  Widget _reveal() {
    final player = _players[_revealIndex];
    final isImposter = _revealIndex == _imposterIndex;
    return Column(
      key: ValueKey('reveal'),
      children: [
        SizedBox(height: 6),
        Text(player.toUpperCase(), textAlign: TextAlign.center, style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900)),
        Text("It's your turn.", style: TextStyle(color: PaletteScope.of(context).palette.muted, fontSize: 17)),
        SizedBox(height: 18),
        Expanded(
          child: Stack(children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: PaletteScope.of(context).palette.card, border: Border.all(color: PaletteScope.of(context).palette.accent), borderRadius: BorderRadius.circular(28)),
              padding: EdgeInsets.all(24),
              child: Center(
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 280),
                  child: !_revealed
                      ? Text('PRIVATE ROLE REVEAL', key: ValueKey('hidden'), style: TextStyle(color: PaletteScope.of(context).palette.muted, fontWeight: FontWeight.w800, letterSpacing: 1))
                      : Column(
                          key: ValueKey('shown'),
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: isImposter
                              ? [
                                  Text('YOUR ROLE', style: TextStyle(color: PaletteScope.of(context).palette.muted)),
                                  SizedBox(height: 8),
                                  Text('YOU ARE THE IMPOSTER', textAlign: TextAlign.center, style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900, color: PaletteScope.of(context).palette.primary)),
                                  SizedBox(height: 20),
                                  Text('YOUR CATEGORY', style: TextStyle(color: PaletteScope.of(context).palette.muted)),
                                  Text(_word!.category, textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                                  Text(_word!.categoryHi, style: TextStyle(color: PaletteScope.of(context).palette.muted, fontSize: 18)),
                                ]
                              : [
                                  Text('WORD', style: TextStyle(color: PaletteScope.of(context).palette.muted)),
                                  Text(_word!.word, textAlign: TextAlign.center, style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
                                  Text(_word!.wordHi, textAlign: TextAlign.center, style: TextStyle(color: PaletteScope.of(context).palette.muted, fontSize: 20)),
                                  SizedBox(height: 14),
                                  Text('CATEGORY', style: TextStyle(color: PaletteScope.of(context).palette.muted)),
                                  Text(_word!.category, textAlign: TextAlign.center, style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
                                  Text(_word!.categoryHi, style: TextStyle(color: PaletteScope.of(context).palette.muted, fontSize: 18)),
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
                  decoration: BoxDecoration(color: PaletteScope.of(context).palette.card, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: PaletteScope.of(context).palette.accent.withValues(alpha: .2), blurRadius: 30, spreadRadius: 2)]),
                  child: Center(
                    child: Text('TAP HERE TO\nREVEAL YOUR ROLE', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: .7)),
                  ),
                ),
              ),
            ),
          ]),
        ),
        SizedBox(height: 10),
        _button(_revealIndex == _players.length - 1 ? 'FINISH REVEAL' : 'CONTINUE', _revealed ? _nextReveal : null, main: true),
        Padding(padding: EdgeInsets.only(top: 10), child: Text('Keep the screen private, then pass the phone.', textAlign: TextAlign.center, style: TextStyle(color: PaletteScope.of(context).palette.muted))),
      ],
    );
  }

  Widget _passToNext() {
    final nextPlayer = _players[_revealIndex + 1];
    return Column(
      mainAxisSize: MainAxisSize.min,
      key: ValueKey('passToNext'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.swap_horiz_rounded, color: PaletteScope.of(context).palette.accent, size: 64),
        SizedBox(height: 20),
        Text(
          'PASS THE PHONE',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        SizedBox(height: 12),
        Text(
          'Pass to ${nextPlayer.toUpperCase()}',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: PaletteScope.of(context).palette.primary),
        ),
        SizedBox(height: 10),
        Text(
          'Make sure the next player is ready before continuing.',
          textAlign: TextAlign.center,
          style: TextStyle(color: PaletteScope.of(context).palette.muted, fontSize: 16, height: 1.4),
        ),
        SizedBox(height: 24),
        _panel(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.visibility_off_outlined, color: PaletteScope.of(context).palette.accent),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                'Your role is hidden. Keep it secret.',
                textAlign: TextAlign.center,
                style: TextStyle(color: PaletteScope.of(context).palette.muted, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        )),
        SizedBox(height: 14),
        _button('PASS TO ${nextPlayer.toUpperCase()}', _passToNextPlayer, main: true),
      ],
    );
  }

  Widget _discuss() => Column(
        mainAxisSize: MainAxisSize.min,
        key: ValueKey('discuss'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, color: PaletteScope.of(context).palette.accent, size: 58),
          SizedBox(height: 12),
          Text('DISCUSS IRL', style: TextStyle(fontSize: 31, fontWeight: FontWeight.w900)),
          SizedBox(height: 10),
          Text('The secret words have been revealed. Put the phone down and discuss your clues. Talk it out, make accusations, defend yourself, and decide who the Imposter is.', textAlign: TextAlign.center, style: TextStyle(color: PaletteScope.of(context).palette.muted, fontSize: 17, height: 1.45)),
          _button('READY TO VOTE?', _beginVoting, main: true),
        ],
      );

  Widget _voting() {
    final voter = _players[_voterIndex];
    return Column(
      key: ValueKey('voting'),
      children: [
        Text(
          '${voter.toUpperCase()} — VOTE',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 5),
        Text(
          'Who do you think is the Imposter?',
          textAlign: TextAlign.center,
          style: TextStyle(color: PaletteScope.of(context).palette.muted),
        ),
        SizedBox(height: 10),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 400;
              final compact = constraints.maxHeight < 360;
              return GridView.builder(
                padding: EdgeInsets.only(bottom: 6),
                itemCount: _players.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: narrow ? 1 : 2,
                  mainAxisExtent: compact ? 52 : 64,
                  crossAxisSpacing: 9,
                  mainAxisSpacing: 9,
                ),
                itemBuilder: (context, i) => OutlinedButton(
                  onPressed: () => setState(() => _selectedVote = i),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    backgroundColor: _selectedVote == i
                        ? PaletteScope.of(context).palette.primary
                        : PaletteScope.of(context).palette.card,
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: _selectedVote == i
                          ? Color(0xFFFF6390)
                          : PaletteScope.of(context).palette.accent,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  child: Text(
                    _players[i].toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              );
            },
          ),
        ),
        _button(
          _voterIndex == _players.length - 1
              ? 'LOCK VOTE & SHOW SUMMARY'
              : 'CONFIRM & PASS PHONE',
          _confirmVote,
          main: true,
          compact: true,
        ),
        Padding(
          padding: EdgeInsets.only(top: 5),
          child: Text(
            'Your vote stays private between turns.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: PaletteScope.of(context).palette.muted,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _summary() {
    final totals = _voteTotals();
    final leaders = _leaders(totals);
    final maxVotes = totals.reduce(max);
    return Column(
      key: ValueKey('summary'),
      children: [
        Text('VOTE SUMMARY', style: TextStyle(fontSize: 29, fontWeight: FontWeight.w900)),
        SizedBox(height: 14),
        Expanded(child: SingleChildScrollView(child: _panel(Column(children: List.generate(_players.length, (i) => Padding(
          padding: EdgeInsets.symmetric(vertical: 9),
          child: Row(children: [
            SizedBox(width: 100, child: Text(_players[i], overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w700))),
            Expanded(child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: maxVotes == 0 ? 0 : totals[i] / maxVotes, minHeight: 12, backgroundColor: PaletteScope.of(context).palette.card2, color: leaders.contains(i) ? PaletteScope.of(context).palette.primary : PaletteScope.of(context).palette.accent),
            )),
            SizedBox(width: 10),
            SizedBox(width: 20, child: Text('${totals[i]}')),
          ]),
        )))))),
        Text(leaders.length > 1 ? 'Tie detected — nobody has a sole top vote.' : 'Top vote: ${_players[leaders.first]}', textAlign: TextAlign.center, style: TextStyle(color: PaletteScope.of(context).palette.muted)),
        _button('REVEAL RESULTS', _finishRound, main: true),
      ],
    );
  }

  Widget _results() {
    final record = _selectedHistory!;
    return SingleChildScrollView(
      child: Column(
        key: ValueKey('results'),
        mainAxisSize: MainAxisSize.min,
        children: [
        Text(record.caught ? 'IMPOSTER CAUGHT' : 'IMPOSTER NOT CAUGHT', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
        SizedBox(height: 14),
        _panel(Column(children: [
          Text('WORD', style: TextStyle(color: PaletteScope.of(context).palette.muted, fontWeight: FontWeight.w700)),
          Text(record.word.word, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
          Text(record.word.wordHi, style: TextStyle(color: PaletteScope.of(context).palette.muted, fontSize: 18)),
          SizedBox(height: 10),
          Text('CATEGORY', style: TextStyle(color: PaletteScope.of(context).palette.muted, fontWeight: FontWeight.w700)),
          Text(record.word.category, style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
          Text(record.word.categoryHi, style: TextStyle(color: PaletteScope.of(context).palette.muted, fontSize: 18)),
        ])),
        SizedBox(height: 10),
        _panel(Column(children: [
          Text('IMPOSTER', style: TextStyle(color: PaletteScope.of(context).palette.muted, fontWeight: FontWeight.w700)),
          Text(record.imposter, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          SizedBox(height: 8),
          Divider(color: PaletteScope.of(context).palette.accent),
          Text('SCOREBOARD', style: TextStyle(color: PaletteScope.of(context).palette.muted, fontWeight: FontWeight.w800)),
          ...List.generate(record.players.length, (i) => Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              Expanded(child: Text(record.players[i])),
              Text('${record.points[i] > 0 ? '+' : ''}${record.points[i]}', style: TextStyle(fontWeight: FontWeight.w900, color: record.points[i] > 0 ? good : record.points[i] < 0 ? danger : Colors.white)),
              SizedBox(width: 22),
              SizedBox(width: 35, child: Text('${record.scores[i]}', textAlign: TextAlign.end, style: TextStyle(fontWeight: FontWeight.w900))),
            ]),
          )),
        ])),
          _button('PLAY AGAIN', _playAgain, main: true),
          _button('MAIN MENU', () => _go(Phase.menu)),
        ],
      ),
    );
  }

  Widget _historyPage() => Column(
        key: ValueKey('history'),
        children: [
          Row(children: [
            Expanded(child: Text('HISTORY', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900))),
            TextButton(onPressed: _history.isEmpty ? null : _clearHistory, child: Text('CLEAR', style: TextStyle(color: danger))),
          ]),
          Expanded(child: _history.isEmpty
              ? Center(child: _panel(Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('NO MATCHES YET', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                  SizedBox(height: 5),
                  Text('Finish a round and it will appear here.', textAlign: TextAlign.center, style: TextStyle(color: PaletteScope.of(context).palette.muted)),
                ])))
              : ListView.separated(
                  itemCount: _history.length,
                  separatorBuilder: (_, __) => SizedBox(height: 9),
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
                          Text(r.word.word, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                          Text(r.word.category, style: TextStyle(color: PaletteScope.of(context).palette.muted, fontSize: 12)),
                        ])),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text(r.caught ? 'CAUGHT' : 'ESCAPED', style: TextStyle(fontWeight: FontWeight.w800)),
                          Text(_formatDate(r.date), style: TextStyle(color: PaletteScope.of(context).palette.muted, fontSize: 12)),
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
      mainAxisSize: MainAxisSize.min,
      key: ValueKey('historyDetail'),
      children: [
        Text('ROUND HISTORY', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
        SizedBox(height: 14),
        _panel(Column(children: [
          Text(r.word.word, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
          Text(r.word.wordHi, style: TextStyle(color: PaletteScope.of(context).palette.muted)),
          Text(r.word.category, style: TextStyle(fontWeight: FontWeight.w800)),
          Text(r.word.categoryHi, style: TextStyle(color: PaletteScope.of(context).palette.muted)),
          Divider(color: PaletteScope.of(context).palette.accent),
          Text('Imposter: ${r.imposter}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          Text(r.caught ? 'Caught' : 'Not caught', style: TextStyle(color: PaletteScope.of(context).palette.muted)),
          SizedBox(height: 10),
          ...List.generate(r.players.length, (i) => Row(children: [
            Expanded(child: Text(r.players[i])),
            Text('${r.voteTotals[i]} votes · ${r.points[i] > 0 ? '+' : ''}${r.points[i]} pts · total ${r.scores[i]}'),
          ])),
        ])),
        SizedBox(height: 14),
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
        body = SingleChildScrollView(child: _passToNext());
      case Phase.discuss:
        body = SingleChildScrollView(child: _discuss());
      case Phase.voting:
        body = _voting();
      case Phase.summary:
        body = _summary();
      case Phase.results:
        body = _results();
      case Phase.history:
        body = _historyPage();
      case Phase.historyDetail:
        body = SingleChildScrollView(child: _historyDetail());
    }
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.85, -0.95),
            radius: 1.3,
            colors: [PaletteScope.of(context).palette.card2, PaletteScope.of(context).palette.background],
          ),
        ),
        child: _page(body),
      ),
      ),
    );
  }
}
