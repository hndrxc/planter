import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planter/screens/plant_form_screen.dart';
import 'package:planter/widgets/empty_state.dart';

import '../support/pump_app.dart';

void main() {
  testWidgets('shows the empty state instead of the add button',
      (tester) async {
    await pumpApp(tester, initial: []);

    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('No plants yet'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('its button opens the add form', (tester) async {
    await pumpApp(tester, initial: []);

    await tester.tap(find.text('Add a plant'));
    await tester.pumpAndSettle();

    expect(find.byType(PlantFormScreen), findsOneWidget);
  });

  testWidgets('adding the first plant replaces the empty state',
      (tester) async {
    await pumpApp(tester, initial: []);
    await tester.tap(find.text('Add a plant'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('plant-name')), 'First');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.byType(EmptyState), findsNothing);
    expect(listTileTitles(tester), ['First']);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('deleting the last plant brings the empty state back',
      (tester) async {
    await pumpApp(tester, initial: [monty]);

    await tester.drag(find.text('Monty'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });
}
