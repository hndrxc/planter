import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planter/screens/plant_form_screen.dart';

import '../support/pump_app.dart';

void main() {
  Future<void> openAddForm(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Add plant'));
    await tester.pumpAndSettle();
    expect(find.byType(PlantFormScreen), findsOneWidget);
  }

  testWidgets('the add button opens a form with sensible defaults',
      (tester) async {
    await pumpApp(tester, initial: [monty]);

    await openAddForm(tester);

    expect(find.text('Add plant'), findsOneWidget);
    expect(find.text('7 days'), findsOneWidget);
    expect(find.text('Sep 3, 2026'), findsOneWidget);
  });

  testWidgets('rejects an empty name', (tester) async {
    final repository = await pumpApp(tester, initial: [monty]);
    await openAddForm(tester);

    await tester.enterText(find.byKey(const Key('plant-name')), '   ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Give the plant a name'), findsOneWidget);
    expect(find.byType(PlantFormScreen), findsOneWidget);
    expect(repository.saves, isEmpty);
  });

  testWidgets('adds a plant and persists it', (tester) async {
    final repository = await pumpApp(tester, initial: [monty]);
    await openAddForm(tester);

    await tester.enterText(find.byKey(const Key('plant-name')), '  Fernando ');
    await tester.enterText(
      find.byKey(const Key('plant-species')),
      'Boston fern',
    );
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byTooltip('Decrease interval'));
      await tester.pump();
    }
    expect(find.text('4 days'), findsOneWidget);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.byType(PlantFormScreen), findsNothing);
    expect(find.text('Fernando'), findsOneWidget);
    expect(find.text('Boston fern'), findsOneWidget);
    expect(find.text('Due in 4 days'), findsOneWidget);

    final saved = repository.stored!.singleWhere((p) => p.name == 'Fernando');
    expect(saved.species, 'Boston fern');
    expect(saved.waterEveryDays, 4);
    expect(saved.lastWatered, testNow);
    expect(saved.history, [testNow]);
    expect(repository.stored, hasLength(2));
  });

  testWidgets('the interval cannot go below one day', (tester) async {
    await pumpApp(tester, initial: [monty]);
    await openAddForm(tester);

    for (var i = 0; i < 10; i++) {
      await tester.tap(find.byTooltip('Decrease interval'), warnIfMissed: false);
      await tester.pump();
    }

    expect(find.text('1 day'), findsOneWidget);
    final minus = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.remove_circle_outline),
    );
    expect(minus.onPressed, isNull);
  });

  testWidgets('the date picker sets last watered', (tester) async {
    final repository = await pumpApp(tester, initial: [monty]);
    await openAddForm(tester);

    await tester.tap(find.text('Last watered'));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);

    await tester.tap(find.text('1'));
    await tester.pump();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsNothing);
    expect(find.text('Sep 1, 2026'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('plant-name')), 'Dated');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final saved = repository.stored!.singleWhere((p) => p.name == 'Dated');
    expect(saved.lastWatered, DateTime(2026, 9, 1, 12));
    expect(saved.history, [DateTime(2026, 9, 1, 12)]);
  });
}
