import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_app.dart';

void main() {
  Future<void> swipeAway(WidgetTester tester, String name) async {
    await tester.drag(find.text(name), const Offset(-600, 0));
    await tester.pumpAndSettle();
  }

  testWidgets('swiping asks for confirmation first', (tester) async {
    final repository = await pumpApp(tester, initial: [monty, lily]);

    await swipeAway(tester, 'Lily');

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Delete Lily?'), findsOneWidget);
    expect(repository.saves, isEmpty);
  });

  testWidgets('cancel keeps the plant', (tester) async {
    final repository = await pumpApp(tester, initial: [monty, lily]);
    await swipeAway(tester, 'Lily');

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(listTileTitles(tester), ['Lily', 'Monty']);
    expect(repository.saves, isEmpty);
  });

  testWidgets('confirming removes the plant and persists it', (tester) async {
    final repository = await pumpApp(tester, initial: [monty, lily]);
    await swipeAway(tester, 'Lily');

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Lily'), findsNothing);
    expect(listTileTitles(tester), ['Monty']);
    expect(repository.stored, [monty]);
  });
}
