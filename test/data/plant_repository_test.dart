import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:planter/data/plant_repository.dart';
import 'package:planter/models/plant.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final plants = [
    Plant(
      id: 'a',
      name: 'Monty',
      species: 'Monstera deliciosa',
      waterEveryDays: 7,
      lastWatered: DateTime(2026, 8, 20, 9),
      history: [DateTime(2026, 8, 13, 9), DateTime(2026, 8, 20, 9)],
    ),
    Plant(
      id: 'b',
      name: 'Lily',
      species: 'Peace lily',
      waterEveryDays: 3,
      lastWatered: DateTime(2026, 8, 25, 18, 45),
    ),
  ];

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SharedPrefsPlantRepository', () {
    test('load returns null when nothing has been saved', () async {
      expect(await SharedPrefsPlantRepository().load(), isNull);
    });

    test('round-trips a list of plants', () async {
      await SharedPrefsPlantRepository().save(plants);

      final loaded = await SharedPrefsPlantRepository().load();

      expect(loaded, plants);
    });

    test('round-trips an empty list as empty, not null', () async {
      await SharedPrefsPlantRepository().save([]);

      final loaded = await SharedPrefsPlantRepository().load();

      expect(loaded, isNotNull);
      expect(loaded, isEmpty);
    });

    test('the latest save wins', () async {
      final repository = SharedPrefsPlantRepository();
      await repository.save(plants);
      await repository.save([plants.last]);

      expect(await repository.load(), [plants.last]);
    });

    test('writes a single JSON string under its key', () async {
      await SharedPrefsPlantRepository().save(plants);

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(SharedPrefsPlantRepository.defaultKey);

      expect(raw, encodePlants(plants));
      expect(jsonDecode(raw!), isA<List<dynamic>>());
    });

    test('corrupt JSON loads as an empty list', () async {
      SharedPreferences.setMockInitialValues({'plants': '{not json'});

      expect(await SharedPrefsPlantRepository().load(), isEmpty);
    });

    test('a value of the wrong type loads as an empty list', () async {
      SharedPreferences.setMockInitialValues({'plants': 42});

      expect(await SharedPrefsPlantRepository().load(), isEmpty);
    });

    test('respects a custom key', () async {
      await SharedPrefsPlantRepository(key: 'other').save(plants);

      expect(await SharedPrefsPlantRepository().load(), isNull);
      expect(await SharedPrefsPlantRepository(key: 'other').load(), plants);
    });
  });

  group('decodePlants', () {
    test('skips entries that are not objects', () {
      final raw = '[1, "x", null, ${jsonEncode(plants.first.toJson())}]';
      expect(decodePlants(raw), [plants.first]);
    });

    test('an object instead of a list yields an empty list', () {
      expect(decodePlants('{"id": "a"}'), isEmpty);
    });

    test('keeps entries with missing fields', () {
      final decoded = decodePlants('[{"id": "k"}]');
      expect(decoded.single.id, 'k');
      expect(decoded.single.name, Plant.placeholderName);
    });

    test('encode and decode are inverses', () {
      expect(decodePlants(encodePlants(plants)), plants);
      expect(decodePlants(encodePlants([])), isEmpty);
    });
  });
}
