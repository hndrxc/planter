import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/plant.dart';

/// Loads and saves the full list of plants.
abstract class PlantRepository {
  /// The saved plants, or `null` if nothing has ever been saved.
  ///
  /// An empty list means the user has deliberately removed every plant, which
  /// is different from a fresh install.
  Future<List<Plant>?> load();

  /// Replaces whatever was saved before with [plants].
  Future<void> save(List<Plant> plants);
}

/// Stores the whole list as one JSON string under a single key in
/// `shared_preferences`.
class SharedPrefsPlantRepository implements PlantRepository {
  SharedPrefsPlantRepository({this.key = defaultKey});

  static const defaultKey = 'plants';

  final String key;

  @override
  Future<List<Plant>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.get(key);
    if (raw == null) return null;
    if (raw is! String) return const [];
    return decodePlants(raw);
  }

  @override
  Future<void> save(List<Plant> plants) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, encodePlants(plants));
  }
}

/// Encodes [plants] as a JSON array.
String encodePlants(List<Plant> plants) =>
    jsonEncode([for (final plant in plants) plant.toJson()]);

/// Decodes a JSON array of plants. Never throws: unreadable input yields an
/// empty list and entries that are not objects are skipped.
List<Plant> decodePlants(String raw) {
  final Object? decoded;
  try {
    decoded = jsonDecode(raw);
  } on FormatException {
    return const [];
  }
  if (decoded is! List) return const [];
  return decoded.map(Plant.tryFromJson).whereType<Plant>().toList();
}
