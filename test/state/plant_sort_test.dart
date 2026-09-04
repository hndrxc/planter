import 'package:flutter_test/flutter_test.dart';
import 'package:planter/models/plant.dart';
import 'package:planter/state/plant_sort.dart';

void main() {
  final now = DateTime(2026, 9, 3, 12);

  Plant plant(String id, String name, {int every = 7, int lastAgo = 1}) =>
      Plant(
        id: id,
        name: name,
        waterEveryDays: every,
        lastWatered: DateTime(2026, 9, 3 - lastAgo, 9),
      );

  test('most overdue first, then soonest due', () {
    final fine = plant('a', 'Fine', every: 7, lastAgo: 1);
    final today = plant('b', 'Today', every: 3, lastAgo: 3);
    final late = plant('c', 'Late', every: 3, lastAgo: 5);
    final veryLate = plant('d', 'Very late', every: 2, lastAgo: 9);

    final sorted = sortByUrgency([fine, today, late, veryLate], now);

    expect(sorted.map((p) => p.id), ['d', 'c', 'b', 'a']);
  });

  test('ties are broken by name, ignoring case, then by id', () {
    final zed = plant('1', 'zed');
    final alpha = plant('2', 'Alpha');
    final beta = plant('3', 'beta');
    final alphaTwin = plant('0', 'alpha');

    final sorted = sortByUrgency([zed, alpha, beta, alphaTwin], now);

    expect(sorted.map((p) => p.id), ['0', '2', '3', '1']);
  });

  test('does not modify the input', () {
    final input = [plant('a', 'A', lastAgo: 1), plant('b', 'B', lastAgo: 9)];
    final before = List.of(input);

    sortByUrgency(input, now);

    expect(input, before);
  });

  test('handles an empty list', () {
    expect(sortByUrgency([], now), isEmpty);
  });
}
