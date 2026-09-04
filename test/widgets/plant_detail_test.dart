import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planter/screens/plant_detail_screen.dart';
import 'package:planter/screens/plant_form_screen.dart';

import '../support/pump_app.dart';

void main() {
  Future<void> openDetail(WidgetTester tester, String name) async {
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
    expect(find.byType(PlantDetailScreen), findsOneWidget);
  }

  testWidgets('shows the schedule and the full history, newest first',
      (tester) async {
    final historic = testPlant(
      'h',
      'Historic',
      species: 'Ficus',
      lastAgo: 1,
      historyCount: 3,
    );
    await pumpApp(tester, initial: [historic]);

    await openDetail(tester, 'Historic');

    expect(find.text('Historic'), findsOneWidget);
    expect(find.text('Ficus'), findsOneWidget);
    expect(find.text('Due in 6 days'), findsOneWidget);
    expect(find.textContaining('Water every 7 days'), findsOneWidget);
    expect(find.text('Watering history'), findsOneWidget);
    expect(
      listTileTitles(tester),
      ['Sep 2, 2026', 'Aug 26, 2026', 'Aug 19, 2026'],
    );
  });

  testWidgets('water now records a watering', (tester) async {
    final repository = await pumpApp(tester, initial: [lily]);
    await openDetail(tester, 'Lily');
    expect(find.text('2 days overdue'), findsOneWidget);

    await tester.tap(find.text('Water now'));
    await tester.pumpAndSettle();

    expect(find.text('Due in 3 days'), findsOneWidget);
    expect(find.text('Watered Lily'), findsOneWidget);
    expect(listTileTitles(tester).first, 'Sep 3, 2026');
    expect(repository.stored!.single.lastWatered, testNow);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });

  testWidgets('edit opens the form pre-filled and saves changes',
      (tester) async {
    final repository = await pumpApp(tester, initial: [monty]);
    await openDetail(tester, 'Monty');

    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Edit plant'), findsOneWidget);
    expect(find.text('7 days'), findsOneWidget);
    expect(find.text('Sep 1, 2026'), findsOneWidget);
    final nameField = tester.widget<TextFormField>(
      find.byKey(const Key('plant-name')),
    );
    expect(nameField.controller!.text, 'Monty');

    await tester.enterText(find.byKey(const Key('plant-name')), 'Monty II');
    await tester.tap(find.byTooltip('Increase interval'));
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.byType(PlantFormScreen), findsNothing);
    expect(find.byType(PlantDetailScreen), findsOneWidget);
    expect(find.text('Monty II'), findsOneWidget);
    expect(find.textContaining('Water every 8 days'), findsOneWidget);

    final saved = repository.stored!.single;
    expect(saved.id, 'm');
    expect(saved.name, 'Monty II');
    expect(saved.waterEveryDays, 8);
    expect(saved.lastWatered, monty.lastWatered);
    expect(saved.history, monty.history, reason: 'editing keeps history');
  });

  testWidgets('delete asks for confirmation, then returns home',
      (tester) async {
    final repository = await pumpApp(tester, initial: [monty, lily]);
    await openDetail(tester, 'Monty');

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete Monty?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(PlantDetailScreen), findsOneWidget);
    expect(repository.saves, isEmpty);

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.byType(PlantDetailScreen), findsNothing);
    expect(listTileTitles(tester), ['Lily']);
    expect(repository.stored, [lily]);
  });
}
