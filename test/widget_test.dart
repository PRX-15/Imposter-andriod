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

    await tester.tap(find.text('PASS THE PHONE'));
    await tester.pumpAndSettle();

    expect(find.text('Pass to PLAYER 2'), findsOneWidget);
    expect(find.text('PASS TO PLAYER 2'), findsOneWidget);

    await tester.tap(find.text('PASS TO PLAYER 2'));
    await tester.pumpAndSettle();

    expect(find.text('PLAYER 2'), findsOneWidget);
    expect(find.text('TAP HERE TO\nREVEAL YOUR ROLE'), findsOneWidget);
  });
}
