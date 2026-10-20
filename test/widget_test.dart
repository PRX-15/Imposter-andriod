import 'package:flutter_test/flutter_test.dart';
import 'package:imposter_android/main.dart';

void main() {
  testWidgets('shows the IMPOSTER main menu', (tester) async {
    await tester.pumpWidget(const ImposterApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('IMPOSTER'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
  });

  testWidgets('player setup starts with three players', (tester) async {
    await tester.pumpWidget(const ImposterApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Player 1'), findsOneWidget);
    expect(find.text('Player 2'), findsOneWidget);
    expect(find.text('Player 3'), findsOneWidget);
  });

  testWidgets('role reveal asks to pass to the next player', (tester) async {
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
  });

  testWidgets('voting handoff shows completed votes and advances to next voter', (tester) async {
    await tester.pumpWidget(const ImposterApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('PLAY'));
    await tester.pumpAndSettle();

    // Finish the three-player role reveal.
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('TAP HERE TO\nREVEAL YOUR ROLE'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      await tester.tap(find.text(i == 2 ? 'FINISH REVEAL' : 'CONTINUE'));
      await tester.pumpAndSettle();
      if (i < 2) {
        await tester.tap(find.text('PASS TO PLAYER ${i + 2}'));
        await tester.pumpAndSettle();
      }
    }

    await tester.tap(find.text('READY TO VOTE?'));
    await tester.pumpAndSettle();

    // Player 1 votes for Player 2.
    await tester.tap(find.text('PLAYER 2').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('CONFIRM VOTE'));
    await tester.pumpAndSettle();

    expect(find.text('Pass to PLAYER 2'), findsOneWidget);
    expect(find.text('Player 1'), findsOneWidget);
    expect(find.text('Player 2').last, findsOneWidget);

    // The pass action must advance the voter to Player 2.
    await tester.tap(find.text('PASS TO PLAYER 2'));
    await tester.pumpAndSettle();
    expect(find.text('PLAYER 2 — VOTE'), findsOneWidget);
  });
}
