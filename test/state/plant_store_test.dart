import 'package:flutter_test/flutter_test.dart';
import 'package:planter/data/demo_plants.dart';
import 'package:planter/models/plant.dart';
import 'package:planter/state/plant_store.dart';

import '../support/in_memory_plant_repository.dart';

void main() {
  final now = DateTime(2026, 9, 3, 12);

  Plant makePlant(String id, {int every = 7, int lastAgo = 1}) => Plant(
        id: id,
        name: 'Plant $id',
        waterEveryDays: every,
        lastWatered: DateTime(2026, 9, 3 - lastAgo, 9),
        history: [DateTime(2026, 9, 3 - lastAgo, 9)],
      );

  final a = makePlant('a');
  final b = makePlant('b', every: 3, lastAgo: 5);
  final c = makePlant('c', every: 10);

  PlantStore makeStore(InMemoryPlantRepository repository) =>
      PlantStore(repository, clock: () => now);

  test('load reads the saved plants and reports loaded', () async {
    final repository = InMemoryPlantRepository(initial: [a, b]);
    final store = makeStore(repository);
    expect(store.isLoaded, isFalse);
    expect(store.plants, isEmpty);

    await store.load();

    expect(store.isLoaded, isTrue);
    expect(store.plants, [a, b]);
    expect(repository.saves, isEmpty, reason: 'loading is not a change');
  });

  test('load seeds demo data on a fresh install and saves it', () async {
    final repository = InMemoryPlantRepository();
    final store = makeStore(repository);

    await store.load();

    expect(store.plants, demoPlants(now: now));
    expect(repository.stored, store.plants);
  });

  test('load does not reseed an empty saved list', () async {
    final repository = InMemoryPlantRepository(initial: []);
    final store = makeStore(repository);

    await store.load();

    expect(store.isLoaded, isTrue);
    expect(store.plants, isEmpty);
  });

  test('byId finds a plant or returns null', () async {
    final store = makeStore(InMemoryPlantRepository(initial: [a, b]));
    await store.load();

    expect(store.byId('b'), b);
    expect(store.byId('zzz'), isNull);
  });

  test('add appends and writes through', () async {
    final repository = InMemoryPlantRepository(initial: [a, b]);
    final store = makeStore(repository);
    await store.load();

    await store.add(c);

    expect(store.plants, [a, b, c]);
    expect(repository.stored, [a, b, c]);
  });

  test('update replaces the plant with the same id', () async {
    final repository = InMemoryPlantRepository(initial: [a, b]);
    final store = makeStore(repository);
    await store.load();
    final renamed = a.copyWith(name: 'Renamed');

    await store.update(renamed);

    expect(store.plants, [renamed, b]);
    expect(repository.stored, [renamed, b]);
  });

  test('update of an unknown id adds the plant', () async {
    final repository = InMemoryPlantRepository(initial: [a]);
    final store = makeStore(repository);
    await store.load();

    await store.update(c);

    expect(store.plants, [a, c]);
    expect(repository.stored, [a, c]);
  });

  test('remove deletes by id and writes through', () async {
    final repository = InMemoryPlantRepository(initial: [a, b, c]);
    final store = makeStore(repository);
    await store.load();

    await store.remove('b');

    expect(store.plants, [a, c]);
    expect(repository.stored, [a, c]);
  });

  test('water records now, keeps history, and returns the update', () async {
    final repository = InMemoryPlantRepository(initial: [a, b]);
    final store = makeStore(repository);
    await store.load();

    final updated = await store.water('b');

    expect(updated, isNotNull);
    expect(updated!.lastWatered, now);
    expect(updated.history, [...b.history, now]);
    expect(store.byId('b'), updated);
    expect(store.byId('b')!.daysUntilDue(now), 3);
    expect(repository.stored, [a, updated]);
  });

  test('water accepts an explicit time', () async {
    final store = makeStore(InMemoryPlantRepository(initial: [a]));
    await store.load();
    final yesterday = DateTime(2026, 9, 2, 18);

    final updated = await store.water('a', at: yesterday);

    expect(updated!.lastWatered, yesterday);
  });

  test('water of an unknown id returns null and saves nothing', () async {
    final repository = InMemoryPlantRepository(initial: [a]);
    final store = makeStore(repository);
    await store.load();

    expect(await store.water('zzz'), isNull);
    expect(repository.saves, isEmpty);
  });

  test('notifies listeners on load and on every change', () async {
    final store = makeStore(InMemoryPlantRepository(initial: [a]));
    var notifications = 0;
    store.addListener(() => notifications++);

    await store.load();
    await store.add(b);
    await store.update(b.copyWith(name: 'B'));
    await store.water('a');
    await store.remove('a');

    expect(notifications, 5);
  });

  test('plants cannot be modified from outside the store', () async {
    final store = makeStore(InMemoryPlantRepository(initial: [a]));
    await store.load();

    expect(() => store.plants.add(b), throwsUnsupportedError);
    expect(() => store.plants.clear(), throwsUnsupportedError);
  });
}
