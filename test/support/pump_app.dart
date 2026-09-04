import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planter/main.dart';
import 'package:planter/models/plant.dart';

import 'in_memory_plant_repository.dart';

/// The fixed "now" every widget test runs at: Thursday 3 Sep 2026, noon.
final testNow = DateTime(2026, 9, 3, 12);

/// A plant watered [lastAgo] days before [testNow] at 9am, with
/// [historyCount] regular waterings ending at that one.
Plant testPlant(
  String id,
  String name, {
  String species = '',
  int every = 7,
  int lastAgo = 1,
  int historyCount = 2,
}) {
  DateTime daysAgo(int days) => DateTime(2026, 9, 3 - days, 9);
  return Plant(
    id: id,
    name: name,
    species: species,
    waterEveryDays: every,
    lastWatered: daysAgo(lastAgo),
    history: [
      for (var i = historyCount - 1; i >= 0; i--) daysAgo(lastAgo + i * every),
    ],
  );
}

/// Monty is due in 5 days.
final monty = testPlant('m', 'Monty', species: 'Monstera', lastAgo: 2);

/// Lily is 2 days overdue.
final lily = testPlant('l', 'Lily', species: 'Peace lily', every: 3, lastAgo: 5);

/// Pumps the app with an in-memory repository holding [initial] (null means
/// a fresh install) and waits for it to load.
Future<InMemoryPlantRepository> pumpApp(
  WidgetTester tester, {
  List<Plant>? initial,
}) async {
  final repository = InMemoryPlantRepository(initial: initial);
  await tester.pumpWidget(
    PlanterApp(repository: repository, clock: () => testNow),
  );
  await tester.pumpAndSettle();
  return repository;
}

/// Titles of the on-stage ListTiles, top to bottom.
List<String> listTileTitles(WidgetTester tester) => tester
    .widgetList<ListTile>(find.byType(ListTile))
    .map((tile) => (tile.title! as Text).data!)
    .toList();
