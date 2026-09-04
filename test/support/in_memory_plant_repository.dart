import 'package:planter/data/plant_repository.dart';
import 'package:planter/models/plant.dart';

/// A [PlantRepository] that keeps everything in memory and records each save,
/// so tests can assert on what would have been persisted.
class InMemoryPlantRepository implements PlantRepository {
  /// Pass `initial: null` (the default) to behave like a fresh install, or
  /// an empty list to behave like a user who has deleted every plant.
  InMemoryPlantRepository({List<Plant>? initial})
      : _stored = initial == null ? null : List.of(initial);

  List<Plant>? _stored;

  /// Every list ever passed to [save], oldest first.
  final List<List<Plant>> saves = [];

  /// What is currently persisted, or null if nothing ever was.
  List<Plant>? get stored => _stored == null ? null : List.of(_stored!);

  @override
  Future<List<Plant>?> load() async => stored;

  @override
  Future<void> save(List<Plant> plants) async {
    _stored = List.of(plants);
    saves.add(List.of(plants));
  }
}
