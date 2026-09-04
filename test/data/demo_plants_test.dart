import 'package:flutter_test/flutter_test.dart';
import 'package:planter/data/demo_plants.dart';

import '../support/in_memory_plant_repository.dart';

void main() {
  final now = DateTime(2026, 9, 3, 12);

  test('demo plants cover different stages of the schedule', () {
    final plants = demoPlants(now: now);
    final days = plants.map((plant) => plant.daysUntilDue(now)).toList();

    expect(plants.length, inInclusiveRange(3, 4));
    expect(plants.map((plant) => plant.id).toSet().length, plants.length);
    expect(days, contains(lessThan(0)), reason: 'someone should be overdue');
    expect(days, contains(0), reason: 'someone should be due today');
    expect(days, contains(greaterThan(0)), reason: 'someone should be fine');
  });

  test('demo history ends at lastWatered and is in order', () {
    for (final plant in demoPlants(now: now)) {
      expect(plant.history, isNotEmpty);
      expect(plant.history.last, plant.lastWatered);
      for (var i = 1; i < plant.history.length; i++) {
        expect(plant.history[i - 1].isBefore(plant.history[i]), isTrue);
      }
    }
  });

  test('loadOrSeed seeds and saves when nothing is stored', () async {
    final repository = InMemoryPlantRepository();

    final loaded = await loadOrSeed(repository, now: now);

    expect(loaded, demoPlants(now: now));
    expect(repository.stored, loaded);
  });

  test('loadOrSeed keeps an empty saved list instead of reseeding', () async {
    final repository = InMemoryPlantRepository(initial: []);

    final loaded = await loadOrSeed(repository, now: now);

    expect(loaded, isEmpty);
    expect(repository.saves, isEmpty);
  });
}
