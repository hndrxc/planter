import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:planter/models/plant.dart';

void main() {
  final lastWatered = DateTime(2026, 8, 20, 9, 30);
  final plant = Plant(
    id: 'p1',
    name: 'Monty',
    species: 'Monstera deliciosa',
    waterEveryDays: 7,
    lastWatered: lastWatered,
    history: [
      DateTime(2026, 8, 6, 9),
      DateTime(2026, 8, 13, 9, 15),
      lastWatered,
    ],
  );
  const iso = '2026-08-20T09:00:00.000';

  group('JSON round trip', () {
    test('every field survives toJson then fromJson', () {
      final copy = Plant.fromJson(plant.toJson());

      expect(copy.id, 'p1');
      expect(copy.name, 'Monty');
      expect(copy.species, 'Monstera deliciosa');
      expect(copy.waterEveryDays, 7);
      expect(copy.lastWatered, lastWatered);
      expect(copy.history, plant.history);
      expect(copy, plant);
    });

    test('survives being encoded to a string and back', () {
      final raw = jsonEncode(plant.toJson());
      final copy = Plant.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      expect(copy, plant);
    });

    test('dates are written as ISO-8601 strings', () {
      final json = plant.toJson();
      final encoded = json['lastWatered'];
      expect(encoded, isA<String>());
      expect(
        DateTime.parse(encoded as String).isAtSameMomentAs(lastWatered),
        isTrue,
      );
      expect(json['history'], everyElement(isA<String>()));
    });

    test('a plant with no history round-trips to an empty history', () {
      final bare = Plant(id: 'p2', name: 'Bare', lastWatered: lastWatered);
      final copy = Plant.fromJson(bare.toJson());
      expect(copy.history, isEmpty);
      expect(copy, bare);
    });
  });

  group('fromJson tolerance', () {
    test('missing optional fields fall back to defaults', () {
      final copy = Plant.fromJson({
        'id': 'x',
        'name': 'Bare',
        'lastWatered': iso,
      });
      expect(copy.species, '');
      expect(copy.waterEveryDays, Plant.defaultWaterEveryDays);
      expect(copy.history, isEmpty);
    });

    test('a malformed interval falls back to the default', () {
      for (final bad in ['lots', 0, -3, null, true, <int>[]]) {
        final copy = Plant.fromJson({
          'id': 'x',
          'name': 'N',
          'waterEveryDays': bad,
        });
        expect(
          copy.waterEveryDays,
          Plant.defaultWaterEveryDays,
          reason: 'for $bad',
        );
      }
    });

    test('a numeric string or a double is accepted as an interval', () {
      expect(Plant.fromJson({'waterEveryDays': '5'}).waterEveryDays, 5);
      expect(Plant.fromJson({'waterEveryDays': 2.6}).waterEveryDays, 3);
    });

    test('malformed history entries are dropped and the rest sorted', () {
      final copy = Plant.fromJson({
        'id': 'x',
        'name': 'N',
        'lastWatered': iso,
        'history': [
          '2026-08-13T09:00:00.000',
          'garbage',
          42,
          null,
          '2026-08-06T09:00:00.000',
        ],
      });
      expect(copy.history, [DateTime(2026, 8, 6, 9), DateTime(2026, 8, 13, 9)]);
    });

    test('a history that is not a list becomes empty', () {
      final copy = Plant.fromJson({'id': 'x', 'name': 'N', 'history': 'nope'});
      expect(copy.history, isEmpty);
    });

    test('a malformed lastWatered falls back to the latest history entry', () {
      final copy = Plant.fromJson({
        'id': 'x',
        'name': 'N',
        'lastWatered': 'not a date',
        'history': ['2026-08-13T09:00:00.000', '2026-08-06T09:00:00.000'],
      });
      expect(copy.lastWatered, DateTime(2026, 8, 13, 9));
    });

    test('a missing lastWatered with no history falls back to now', () {
      final before = DateTime.now();
      final copy = Plant.fromJson({'id': 'x', 'name': 'N'});
      final after = DateTime.now();
      expect(copy.lastWatered.isBefore(before), isFalse);
      expect(copy.lastWatered.isAfter(after), isFalse);
    });

    test('a missing id gets a fresh unique one', () {
      final a = Plant.fromJson({'name': 'A', 'lastWatered': iso});
      final b = Plant.fromJson({'name': 'B', 'lastWatered': iso});
      expect(a.id, isNotEmpty);
      expect(b.id, isNotEmpty);
      expect(a.id, isNot(b.id));
    });

    test('a missing or blank name gets a placeholder', () {
      expect(Plant.fromJson({'id': 'x'}).name, Plant.placeholderName);
      expect(
        Plant.fromJson({'id': 'x', 'name': '   '}).name,
        Plant.placeholderName,
      );
      expect(
        Plant.fromJson({'id': 'x', 'name': 42}).name,
        Plant.placeholderName,
      );
    });

    test('an empty object still produces a usable plant', () {
      final copy = Plant.fromJson({});
      expect(copy.id, isNotEmpty);
      expect(copy.name, isNotEmpty);
      expect(copy.waterEveryDays, greaterThanOrEqualTo(1));
      expect(copy.history, isEmpty);
    });

    test('tryFromJson returns null for anything that is not an object', () {
      expect(Plant.tryFromJson(null), isNull);
      expect(Plant.tryFromJson('plant'), isNull);
      expect(Plant.tryFromJson(['list']), isNull);
      expect(Plant.tryFromJson(42), isNull);
    });

    test('tryFromJson accepts a map with non-string keys', () {
      final copy = Plant.tryFromJson(<Object, Object?>{
        'id': 'k',
        'name': 'Keyed',
        1: 'ignored',
      });
      expect(copy?.name, 'Keyed');
    });
  });

  group('copyWith', () {
    test('changes only the given fields', () {
      final copy = plant.copyWith(name: 'Monty II', waterEveryDays: 10);
      expect(copy.name, 'Monty II');
      expect(copy.waterEveryDays, 10);
      expect(copy.id, plant.id);
      expect(copy.species, plant.species);
      expect(copy.lastWatered, plant.lastWatered);
      expect(copy.history, plant.history);
    });

    test('with no arguments is equal to the original', () {
      expect(plant.copyWith(), plant);
    });
  });

  group('schedule', () {
    test('daysUntilDue counts calendar days', () {
      expect(plant.daysUntilDue(DateTime(2026, 8, 25, 23, 59)), 2);
      expect(plant.daysUntilDue(DateTime(2026, 8, 27, 0, 1)), 0);
      expect(plant.daysUntilDue(DateTime(2026, 8, 30, 12)), -3);
    });

    test('ignores the time of day', () {
      final lateNight = Plant(
        id: 'n',
        name: 'Night',
        waterEveryDays: 1,
        lastWatered: DateTime(2026, 8, 20, 21),
      );
      expect(lateNight.daysUntilDue(DateTime(2026, 8, 21, 8)), 0);
    });

    test('daysOverdue and isOverdue', () {
      expect(plant.daysOverdue(DateTime(2026, 8, 25)), 0);
      expect(plant.isOverdue(DateTime(2026, 8, 27)), isFalse);
      expect(plant.daysOverdue(DateTime(2026, 8, 30)), 3);
      expect(plant.isOverdue(DateTime(2026, 8, 28)), isTrue);
    });

    test('nextDue is lastWatered plus the interval', () {
      expect(plant.nextDue, DateTime(2026, 8, 27, 9, 30));
    });

    test('watered() sets lastWatered and appends to history in order', () {
      final at = DateTime(2026, 8, 28, 8);
      final copy = plant.watered(at);
      expect(copy.lastWatered, at);
      expect(copy.history.last, at);
      expect(copy.history.length, plant.history.length + 1);
      expect(plant.history.length, 3, reason: 'the original is untouched');
    });
  });

  group('equality', () {
    test('plants with the same fields are equal', () {
      final twin = Plant(
        id: 'p1',
        name: 'Monty',
        species: 'Monstera deliciosa',
        waterEveryDays: 7,
        lastWatered: DateTime(2026, 8, 20, 9, 30),
        history: [
          DateTime(2026, 8, 6, 9),
          DateTime(2026, 8, 13, 9, 15),
          DateTime(2026, 8, 20, 9, 30),
        ],
      );
      expect(twin, plant);
      expect(twin.hashCode, plant.hashCode);
    });

    test('a different history makes plants unequal', () {
      expect(plant.copyWith(history: []), isNot(plant));
    });
  });

  test('history cannot be modified from outside', () {
    expect(() => plant.history.add(DateTime.now()), throwsUnsupportedError);
  });
}
