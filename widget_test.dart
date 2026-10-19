import 'package:flutter_test/flutter_test.dart';
import 'package:imposter_android/main.dart';

void main() {
  testWidgets('shows the IMPOSTER main menu', (tester) async {
    await tester.pumpWidget(const ImposterApp());
    await tester.pumpAndSettle();
    expect(find.text('IMPOSTER'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
  });

  testWidgets('player setup starts with three players', (tester) async {
    await tester.pumpWidget(const ImposterApp());
    await tester.pumpAndSettle();
    expect(find.text('Player 1'), findsOneWidget);
    expect(find.text('Player 2'), findsOneWidget);
    expect(find.text('Player 3'), findsOneWidget);
  });
}
