import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imposter_android/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows the IMPOSTER main menu and colour chooser', (tester) async {
    await tester.pumpWidget(const ImposterApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('IMPOSTER'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.textContaining('COLOURS'), findsOneWidget);
  });

  testWidgets('blank names default to Player 1 etc when starting', (tester) async {
    await tester.pumpWidget(const ImposterApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Enter player 1 name'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('player-0')), 'Alice');
    await tester.enterText(find.byKey(const ValueKey('player-1')), '');
    await tester.enterText(find.byKey(const ValueKey('player-2')), 'Charlie');
    await tester.tap(find.text('PLAY'));
    await tester.pumpAndSettle();
    final firstPlayerName = ['ALICE', 'PLAYER 2', 'CHARLIE']
        .firstWhere((name) => find.text(name).evaluate().isNotEmpty);
    expect(firstPlayerName, isNotEmpty);
    expect(find.text('Player 2'), findsNothing);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('selecting a colour changes the selected palette', (tester) async {
    await tester.pumpWidget(const ImposterApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('COLOURS'));
    await tester.pumpAndSettle();
    expect(find.text('Ocean'), findsOneWidget);
    await tester.tap(find.text('Ocean'));
    await tester.pumpAndSettle();
    expect(find.textContaining('COLOURS · Ocean'), findsOneWidget);
  });

  testWidgets('role reveal moves to the next player', (tester) async {
    await tester.pumpWidget(const ImposterApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('PLAY'));
    await tester.pumpAndSettle();
    final firstPlayer = ['PLAYER 1', 'PLAYER 2', 'PLAYER 3']
        .firstWhere((name) => find.text(name).evaluate().isNotEmpty);
    await tester.tap(find.text('TAP HERE TO\nREVEAL YOUR ROLE'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    final passLabel = tester.widgetList<Text>(find.byType(Text))
        .map((widget) => widget.data ?? '')
        .firstWhere((value) => value.startsWith('Pass to '));
    final nextPlayer = passLabel.substring('Pass to '.length).toUpperCase();
    expect(nextPlayer, isNot(firstPlayer));
    expect(find.text('PASS TO $nextPlayer'), findsOneWidget);
    await tester.tap(find.text('PASS TO $nextPlayer'));
    await tester.pumpAndSettle();
    expect(find.text(nextPlayer), findsOneWidget);
    expect(find.text('TAP HERE TO\nREVEAL YOUR ROLE'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('home actions remain fixed while the player list scrolls', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ImposterApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    for (var i = 0; i < 7; i++) {
      await tester.tap(find.text('+ ADD PLAYER'));
      await tester.pumpAndSettle();
    }

    expect(find.text('IMPOSTER'), findsOneWidget);
    expect(find.text('+ ADD PLAYER'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.byKey(const ValueKey('player-list')), findsOneWidget);

    final playerList = find.byKey(const ValueKey('player-list'));
    final playerListView = tester.widget<ListView>(playerList);
    expect(playerListView.controller, isNull);
    expect(playerListView.primary, isNot(false));
    await tester.drag(playerList, const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('+ ADD PLAYER'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('IMPOSTER'), findsOneWidget);
  });

  testWidgets('removing a player keeps the remaining names attached to fields', (tester) async {
    // Use a realistic logical viewport so the row's remove button is hittable in CI.
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ImposterApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('+ ADD PLAYER'));
    await tester.pumpAndSettle();
    // Player row keys are based on stable IDs rather than their current indices.
    final player0 = find.byKey(const ValueKey('player-0'));
    final player1 = find.byKey(const ValueKey('player-1'));
    final player2 = find.byKey(const ValueKey('player-2'));
    final player3 = find.byKey(const ValueKey('player-3'));

    await tester.ensureVisible(player0);
    await tester.enterText(player0, 'Alice');
    await tester.ensureVisible(player1);
    await tester.enterText(player1, 'Bob');
    await tester.ensureVisible(player2);
    await tester.enterText(player2, 'Charlie');
    await tester.ensureVisible(player3);
    await tester.enterText(player3, 'Dana');
    final removeBob = find.byKey(const ValueKey('remove-player-1'));
    await tester.ensureVisible(removeBob);
    await tester.tap(removeBob);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('player-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('player-1')), findsNothing);
    expect(tester.widget<TextField>(find.byKey(const ValueKey('player-0'))).controller!.text, 'Alice');
    expect(tester.widget<TextField>(find.byKey(const ValueKey('player-2'))).controller!.text, 'Charlie');
    expect(tester.widget<TextField>(find.byKey(const ValueKey('player-3'))).controller!.text, 'Dana');
  });

  testWidgets('malformed legacy and match history records are skipped safely', (tester) async {
    SharedPreferences.setMockInitialValues({
      'imposter_history_v1': '[{"broken":true}]',
      'imposter_matches_v2': '[{"broken":true}]',
      'imposter_scores_v1': '{"Alice":7,"invalid":"score"}',
    });
    await tester.pumpWidget(const ImposterApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('history-button')));
    await tester.pumpAndSettle();
    expect(find.text('NO MATCHES YET'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('history is opened from the circular history control', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ImposterApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('history-button')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('history-button')));
    await tester.pumpAndSettle();
    expect(find.text('HISTORY'), findsOneWidget);
  });

  testWidgets('unfinished match recovery offers exactly two actions', (tester) async {
    SharedPreferences.setMockInitialValues({
      'imposter_unfinished_v2': '{"startedAt":"2026-11-02T10:00:00.000","players":["Alice","Bob","Charlie"],"scores":{"Alice":3,"Bob":1,"Charlie":0},"roundNumber":1,"rounds":[]}',
    });
    await tester.pumpWidget(const ImposterApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('UNFINISHED MATCH'), findsOneWidget);
    expect(find.text('RESUME'), findsOneWidget);
    expect(find.text('BACK (MAIN MENU)'), findsOneWidget);
    expect(find.byType(TextButton).evaluate().where((e) {
      final button = e.widget as TextButton;
      return button.onPressed != null;
    }).length, 2);
    await tester.tap(find.text('RESUME'));
    await tester.pumpAndSettle();
    expect(find.text('UNFINISHED MATCH'), findsNothing);
  });

  testWidgets('menu adapts when the keyboard reduces available height', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(const ImposterApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('player-0')), 'Alice');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('PLAY'), findsOneWidget);
  });

  testWidgets('Pop Party selects the bright palette and colourful player fields', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ImposterApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('COLOURS'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pop Party'));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme!.brightness, Brightness.light);
    expect(find.textContaining('COLOURS · Pop Party'), findsOneWidget);

    final firstField = tester.widget<TextField>(find.byKey(const ValueKey('player-0')));
    expect(firstField.style!.color, const Color(0xFF303544));
    expect(firstField.style!.fontSize, 20);
    expect(tester.takeException(), isNull);
  });

  testWidgets('player text field keeps focus while keyboard insets animate', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    await tester.pumpWidget(const ImposterApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    final player = find.byKey(const ValueKey('player-0'));
    final listHeightBeforeKeyboard = tester.getSize(find.byKey(const ValueKey('player-list'))).height;
    await tester.tap(player);
    await tester.showKeyboard(player);
    await tester.pump();

    final field = tester.widget<TextField>(player);
    expect(field.focusNode!.hasFocus, isTrue);

    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(player).focusNode!.hasFocus, isTrue);
    expect(
      tester.getSize(find.byKey(const ValueKey('player-list'))).height,
      closeTo(listHeightBeforeKeyboard, 0.1),
    );

    await tester.enterText(player, 'Alice');
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(player).controller!.text, 'Alice');
    expect(tester.takeException(), isNull);
  });

  testWidgets('match history cards are compact and open full round details', (tester) async {
    SharedPreferences.setMockInitialValues({
      'imposter_matches_v2': jsonEncode([
        {
          'startedAt': '2026-11-01T10:00:00.000',
          'players': ['Alice', 'Bob', 'Charlie'],
          'rounds': [
            {
              'date': '2026-11-01T10:05:00.000',
              'word': {'word': 'Apple', 'word_hi': 'सेब', 'category': 'FRUITS', 'category_hi': 'फल'},
              'imposter': 'Bob',
              'players': ['Alice', 'Bob', 'Charlie'],
              'voteTotals': [2, 0, 1],
              'points': [2, -1, 1],
              'scores': [2, -1, 1],
              'caught': true,
              'votes': {'0': 1, '1': 0, '2': 1}
            }
          ],
          'finalScores': {'Alice': 2, 'Bob': -1, 'Charlie': 1}
        }
      ])
    });
    await tester.pumpWidget(const ImposterApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('history-button')));
    await tester.pumpAndSettle();

    expect(find.text('MATCH 1'), findsOneWidget);
    expect(find.text('1 rounds · 3 players'), findsOneWidget);
    expect(find.text('Alice: 2 pts'), findsNothing);

    await tester.tap(find.text('MATCH 1'));
    await tester.pumpAndSettle();
    expect(find.text('MATCH DETAILS'), findsOneWidget);
    expect(find.text('FINAL SCOREBOARD'), findsOneWidget);
    expect(find.text('Apple · FRUITS'), findsOneWidget);
    expect(find.text('Imposter: Bob · Caught'), findsOneWidget);
    expect(find.text('Alice voted for Bob'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

}
