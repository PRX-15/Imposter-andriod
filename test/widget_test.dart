import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imposter_android/main.dart';

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
}
