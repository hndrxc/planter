import '../models/plant.dart';

/// Returns [plants] ordered most urgent first: the most overdue plant comes
/// first, then those due soonest. Ties are broken by name, then id, so the
/// order is stable and predictable.
///
/// Pure: it does not modify [plants] and depends only on its arguments.
List<Plant> sortByUrgency(Iterable<Plant> plants, DateTime now) {
  final sorted = plants.toList();
  sorted.sort((a, b) {
    final byDue = a.daysUntilDue(now).compareTo(b.daysUntilDue(now));
    if (byDue != 0) return byDue;
    final byName = a.name.toLowerCase().compareTo(b.name.toLowerCase());
    if (byName != 0) return byName;
    return a.id.compareTo(b.id);
  });
  return sorted;
}
