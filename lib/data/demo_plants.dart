import '../models/plant.dart';
import 'plant_repository.dart';

/// Four plants at different points in their schedules, used to seed the app
/// on first launch so the UI has something to show from day one.
///
/// Relative to [now]: Monty is comfortably on schedule, Goldie is due today,
/// Fernando is a couple of days late, and Lily has been neglected for a week.
List<Plant> demoPlants({DateTime? now}) {
  final today = now ?? DateTime.now();

  DateTime daysAgo(int days) =>
      DateTime(today.year, today.month, today.day - days, 9);

  List<DateTime> regular({
    required int every,
    required int lastAgo,
    int count = 4,
  }) =>
      [for (var i = count - 1; i >= 0; i--) daysAgo(lastAgo + i * every)];

  return [
    Plant(
      id: 'demo-monstera',
      name: 'Monty',
      species: 'Monstera deliciosa',
      waterEveryDays: 7,
      lastWatered: daysAgo(2),
      history: regular(every: 7, lastAgo: 2),
    ),
    Plant(
      id: 'demo-pothos',
      name: 'Goldie',
      species: 'Golden pothos',
      waterEveryDays: 5,
      lastWatered: daysAgo(5),
      history: regular(every: 5, lastAgo: 5),
    ),
    Plant(
      id: 'demo-fern',
      name: 'Fernando',
      species: 'Boston fern',
      waterEveryDays: 3,
      lastWatered: daysAgo(5),
      history: regular(every: 3, lastAgo: 5, count: 5),
    ),
    Plant(
      id: 'demo-lily',
      name: 'Lily',
      species: 'Peace lily',
      waterEveryDays: 3,
      lastWatered: daysAgo(10),
      history: regular(every: 3, lastAgo: 10, count: 3),
    ),
  ];
}

/// Loads the saved plants, or seeds and saves [demoPlants] when nothing has
/// been saved yet.
Future<List<Plant>> loadOrSeed(
  PlantRepository repository, {
  DateTime? now,
}) async {
  final saved = await repository.load();
  if (saved != null) return saved;
  final seeded = demoPlants(now: now);
  await repository.save(seeded);
  return seeded;
}
