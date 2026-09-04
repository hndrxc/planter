import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_app.dart';

void main() {
  testWidgets('lists plants most urgent first with species and due text',
      (tester) async {
    await pumpApp(tester, initial: [monty, lily]);

    expect(listTileTitles(tester), ['Lily', 'Monty']);
    expect(find.text('Peace lily'), findsOneWidget);
    expect(find.text('2 days overdue'), findsOneWidget);
    expect(find.text('Monstera'), findsOneWidget);
    expect(find.text('Due in 5 days'), findsOneWidget);
  });

  testWidgets('a fresh install shows the seeded demo plants', (tester) async {
    final repository = await pumpApp(tester);

    expect(find.byType(ListTile), findsNWidgets(4));
    expect(find.text('Due today'), findsOneWidget);
    expect(repository.stored, hasLength(4));
  });

  testWidgets('says so when there are no plants', (tester) async {
    await pumpApp(tester, initial: []);

    expect(find.byType(ListTile), findsNothing);
    expect(find.text('No plants yet'), findsOneWidget);
  });

  testWidgets('a plant without a species shows only the due text',
      (tester) async {
    await pumpApp(
      tester,
      initial: [testPlant('x', 'Nameless', every: 2, lastAgo: 1)],
    );

    expect(find.text('Nameless'), findsOneWidget);
    expect(find.text('Due tomorrow'), findsOneWidget);
  });
}
