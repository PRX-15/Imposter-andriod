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

  testWidgets('removing a player keeps the remaining names attached to fields', (tester) async {
    await tester.pumpWidget(const ImposterApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('+ ADD PLAYER'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('player-0')), 'Alice');
    await tester.enterText(find.byKey(const ValueKey('player-1')), 'Bob');
    await tester.enterText(find.byKey(const ValueKey('player-2')), 'Charlie');
    await tester.enterText(find.byKey(const ValueKey('player-3')), 'Dana');
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
