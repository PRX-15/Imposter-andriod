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
    expect(find.text('ALICE'), findsOneWidget);
    expect(find.text('PLAYER 2'), findsNothing);
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
    await tester.tap(find.text('TAP HERE TO\nREVEAL YOUR ROLE'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    expect(find.text('Pass to PLAYER 2'), findsOneWidget);
    expect(find.text('PASS TO PLAYER 2'), findsOneWidget);
    await tester.tap(find.text('PASS TO PLAYER 2'));
    await tester.pumpAndSettle();
    expect(find.text('PLAYER 2'), findsOneWidget);
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
    await tester.pumpWidget(const ImposterApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('+ ADD PLAYER'));
    await tester.pumpAndSettle();
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
    await tester.ensureVisible(find.byIcon(Icons.remove_circle).at(1));
    await tester.tap(find.byIcon(Icons.remove_circle).at(1));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('player-0')), findsOneWidget);
    expect(tester.widget<TextField>(find.byKey(const ValueKey('player-0'))).controller!.text, 'Alice');
    expect(tester.widget<TextField>(find.byKey(const ValueKey('player-1'))).controller!.text, 'Charlie');
    expect(tester.widget<TextField>(find.byKey(const ValueKey('player-2'))).controller!.text, 'Dana');
  });

  testWidgets('malformed history records are skipped without hiding valid records', (tester) async {
    SharedPreferences.setMockInitialValues({
      'imposter_history_v1': '[{"broken":true}]',
      'imposter_scores_v1': '{"Alice":7,"invalid":"score"}',
    });
    await tester.pumpWidget(const ImposterApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('HISTORY'));
    await tester.pumpAndSettle();
    expect(find.text('NO MATCHES YET'), findsOneWidget);
  });
}
