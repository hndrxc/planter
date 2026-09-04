import 'package:flutter_test/flutter_test.dart';
import 'package:planter/models/plant.dart';
import 'package:planter/models/plant_health.dart';

void main() {
  final now = DateTime(2026, 9, 3, 12);

  Plant plantLastWatered(int daysAgo, {int every = 5}) => Plant(
    id: 'plant',
    name: 'Plant',
    waterEveryDays: every,
    lastWatered: now.subtract(Duration(days: daysAgo)),
  );

  test('a plant due today is fully healthy', () {
    expect(healthFromSchedule(plantLastWatered(5), now), 1);
  });

  test('health declines continuously after the due date', () {
    expect(healthFromSchedule(plantLastWatered(6), now), closeTo(.8, .0001));
    expect(healthFromSchedule(plantLastWatered(7), now), closeTo(.6, .0001));
  });

  test('a plant one full watering cycle overdue is fully lapsed', () {
    expect(healthFromSchedule(plantLastWatered(10), now), 0);
    expect(healthFromSchedule(plantLastWatered(20), now), 0);
  });

  test('an explicit grace window controls the decline', () {
    final plant = plantLastWatered(7);
    expect(healthFromSchedule(plant, now, graceDays: 4), .5);
    expect(healthFromSchedule(plant, now, graceDays: 0), 0);
  });
}
