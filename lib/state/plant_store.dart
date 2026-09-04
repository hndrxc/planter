import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../data/demo_plants.dart';
import '../data/plant_repository.dart';
import '../models/plant.dart';

/// Owns the in-memory list of plants and writes every change through to the
/// [PlantRepository]. Screens read it with `context.watch<PlantStore>()`.
class PlantStore extends ChangeNotifier {
  PlantStore(this._repository, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final PlantRepository _repository;
  final DateTime Function() _clock;
  final List<Plant> _plants = [];
  bool _loaded = false;
  bool _disposed = false;

  /// False until [load] has finished.
  bool get isLoaded => _loaded;

  /// The plants in insertion order. Use `sortByUrgency` for display.
  UnmodifiableListView<Plant> get plants => UnmodifiableListView(_plants);

  /// The current time. Injectable so tests can pin the date.
  DateTime get now => _clock();

  Plant? byId(String id) {
    for (final plant in _plants) {
      if (plant.id == id) return plant;
    }
    return null;
  }

  /// Loads the saved plants, seeding demo data if nothing has been saved yet.
  Future<void> load() async {
    final loaded = await loadOrSeed(_repository, now: now);
    _plants
      ..clear()
      ..addAll(loaded);
    _loaded = true;
    _notify();
  }

  Future<void> add(Plant plant) => _commit(() => _plants.add(plant));

  /// Replaces the plant with the same id, or adds it if there is none.
  Future<void> update(Plant plant) => _commit(() {
        final index = _indexOf(plant.id);
        if (index == -1) {
          _plants.add(plant);
        } else {
          _plants[index] = plant;
        }
      });

  Future<void> remove(String id) =>
      _commit(() => _plants.removeWhere((plant) => plant.id == id));

  /// Records a watering for the plant with [id] at [at] (default: now).
  /// Returns the updated plant, or null if there is no such plant.
  Future<Plant?> water(String id, {DateTime? at}) async {
    final index = _indexOf(id);
    if (index == -1) return null;
    final updated = _plants[index].watered(at ?? now);
    await _commit(() => _plants[index] = updated);
    return updated;
  }

  int _indexOf(String id) => _plants.indexWhere((plant) => plant.id == id);

  /// Applies [change], tells listeners, then persists the new list.
  Future<void> _commit(void Function() change) {
    change();
    _notify();
    return _repository.save(List.of(_plants));
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
