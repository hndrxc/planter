import 'package:flutter_test/flutter_test.dart';

import '../support/pump_app.dart';

void main() {
  testWidgets('one tap records a watering and persists it', (tester) async {
    final repository = await pumpApp(tester, initial: [lily]);
    expect(find.text('2 days overdue'), findsOneWidget);

    await tester.tap(find.byTooltip('Water Lily'));
    await tester.pumpAndSettle();

    expect(find.text('Due in 3 days'), findsOneWidget);
    expect(find.text('Watered Lily'), findsOneWidget);
    final saved = repository.stored!.single;
    expect(saved.lastWatered, testNow);
    expect(saved.history, [...lily.history, testNow]);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('undo restores the previous state', (tester) async {
    final repository = await pumpApp(tester, initial: [lily]);
    await tester.tap(find.byTooltip('Water Lily'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('2 days overdue'), findsOneWidget);
    expect(find.text('Watered Lily'), findsNothing);
    expect(repository.stored, [lily]);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('watering re-sorts the list', (tester) async {
    final spike = testPlant('s', 'Spike', every: 14, lastAgo: 16);
    await pumpApp(tester, initial: [monty, spike]);
    expect(listTileTitles(tester), ['Spike', 'Monty']);

    await tester.tap(find.byTooltip('Water Spike'));
    await tester.pumpAndSettle();

    expect(listTileTitles(tester), ['Monty', 'Spike']);
    expect(find.text('Due in 14 days'), findsOneWidget);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });
}
