import 'package:flutter_test/flutter_test.dart';
import 'package:planter/models/plant.dart';
import 'package:planter/models/plant_statistics.dart';

void main() {
  final now = DateTime(2026, 9, 3, 12);

  test('reliability counts early and due-day waterings as on time', () {
    final plant = Plant(
      id: 'fern',
      name: 'Fern',
      waterEveryDays: 4,
      lastWatered: DateTime(2026, 8, 14),
      history: [
        DateTime(2026, 8, 1),
        DateTime(2026, 8, 4),
        DateTime(2026, 8, 10),
        DateTime(2026, 8, 14),
      ],
    );

    final result = reliabilityForPlant(plant);

    expect(result.onTimeWaterings, 2);
    expect(result.trackedWaterings, 3);
    expect(result.percentage, closeTo(66.67, .01));
    expect(result.currentStreak, 1);
  });

  test('reliability is unavailable with fewer than two waterings', () {
    final plant = Plant(
      id: 'new',
      name: 'New',
      lastWatered: now,
      history: [now],
    );
    final result = reliabilityForPlant(plant);
    expect(result.percentage, isNull);
    expect(result.currentStreak, 0);
  });

  test('aggregate stats derive all dashboard values', () {
    final fern = Plant(
      id: 'fern',
      name: 'Fern',
      waterEveryDays: 3,
      lastWatered: DateTime(2026, 8, 30),
      history: [DateTime(2026, 8, 27), DateTime(2026, 8, 30)],
    );
    final cactus = Plant(
      id: 'cactus',
      name: 'Cactus',
      waterEveryDays: 10,
      lastWatered: DateTime(2026, 9, 3),
      history: [DateTime(2026, 9, 1), DateTime(2026, 9, 3)],
    );

    final stats = calculatePlantStatistics([cactus, fern], now);

    expect(stats.totalPlants, 2);
    expect(stats.overduePlants, 1);
    expect(stats.wateringsThisMonth, 2);
    expect(stats.thirstiestPlant, fern);
    expect(stats.reliabilityByPlantId.keys, containsAll(['fern', 'cactus']));
  });

  test('heatmap returns all 56 days and counts shared watering days', () {
    final plants = [
      Plant(
        id: 'a',
        name: 'A',
        lastWatered: now,
        history: [DateTime(2026, 9, 2), DateTime(2026, 9, 3)],
      ),
      Plant(
        id: 'b',
        name: 'B',
        lastWatered: now,
        history: [
          DateTime(2026, 7, 1),
          DateTime(2026, 9, 2, 22),
          DateTime(2026, 9, 4),
        ],
      ),
    ];

    final days = wateringHeatmap(plants, now);

    expect(days, hasLength(56));
    expect(days.first.date, DateTime(2026, 7, 10));
    expect(days.last.date, DateTime(2026, 9, 3));
    expect(
      days.singleWhere((day) => day.date == DateTime(2026, 9, 2)).count,
      2,
    );
    expect(days.last.count, 1);
    expect(days.fold<int>(0, (sum, day) => sum + day.count), 3);
  });
}
