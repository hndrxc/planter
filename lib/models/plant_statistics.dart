import 'dart:collection';

import 'plant.dart';

/// How consistently one plant has been watered by its due date.
class WateringReliability {
  const WateringReliability({
    required this.onTimeWaterings,
    required this.trackedWaterings,
    required this.currentStreak,
  });

  final int onTimeWaterings;
  final int trackedWaterings;
  final int currentStreak;

  /// Null until at least two waterings exist to form a schedule interval.
  double? get percentage =>
      trackedWaterings == 0 ? null : onTimeWaterings / trackedWaterings * 100;
}

/// Counts one day's watering activity for the eight-week heatmap.
class WateringDay {
  const WateringDay(this.date, this.count);

  final DateTime date;
  final int count;
}

/// Values derived from plants and watering history rather than entered by the
/// user.
class PlantStatistics {
  const PlantStatistics({
    required this.totalPlants,
    required this.overduePlants,
    required this.wateringsThisMonth,
    required this.thirstiestPlant,
    required this.heatmap,
    required this.reliabilityByPlantId,
  });

  final int totalPlants;
  final int overduePlants;
  final int wateringsThisMonth;
  final Plant? thirstiestPlant;
  final List<WateringDay> heatmap;
  final Map<String, WateringReliability> reliabilityByPlantId;
}

/// Calculates whether each watering after the first occurred by the due day.
WateringReliability reliabilityForPlant(Plant plant) {
  final history = [...plant.history]..sort();
  var onTime = 0;
  var streak = 0;

  for (var index = 1; index < history.length; index++) {
    final previous = _calendarDay(history[index - 1]);
    final watered = _calendarDay(history[index]);
    final due = previous.add(Duration(days: plant.waterEveryDays));
    if (!watered.isAfter(due)) {
      onTime++;
      streak++;
    } else {
      streak = 0;
    }
  }

  return WateringReliability(
    onTimeWaterings: onTime,
    trackedWaterings: history.length > 1 ? history.length - 1 : 0,
    currentStreak: streak,
  );
}

/// Aggregates the values displayed by the stats screen.
PlantStatistics calculatePlantStatistics(Iterable<Plant> plants, DateTime now) {
  final plantList = List<Plant>.of(plants);
  final reliability = <String, WateringReliability>{
    for (final plant in plantList) plant.id: reliabilityForPlant(plant),
  };
  final heatmap = wateringHeatmap(plantList, now);
  final monthWaterings = plantList
      .expand((plant) => plant.history)
      .where((date) => date.year == now.year && date.month == now.month)
      .length;
  final byThirst = [...plantList]
    ..sort((a, b) {
      final interval = a.waterEveryDays.compareTo(b.waterEveryDays);
      if (interval != 0) return interval;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

  return PlantStatistics(
    totalPlants: plantList.length,
    overduePlants: plantList.where((plant) => plant.isOverdue(now)).length,
    wateringsThisMonth: monthWaterings,
    thirstiestPlant: byThirst.firstOrNull,
    heatmap: List.unmodifiable(heatmap),
    reliabilityByPlantId: UnmodifiableMapView(reliability),
  );
}

/// Returns 56 calendar days ending today, including zero-activity days.
List<WateringDay> wateringHeatmap(Iterable<Plant> plants, DateTime now) {
  final today = _calendarDay(now);
  final firstDay = today.subtract(const Duration(days: 55));
  final counts = <DateTime, int>{};

  for (final watering in plants.expand((plant) => plant.history)) {
    final day = _calendarDay(watering);
    if (day.isBefore(firstDay) || day.isAfter(today)) continue;
    counts.update(day, (count) => count + 1, ifAbsent: () => 1);
  }

  return [
    for (var offset = 0; offset < 56; offset++)
      WateringDay(
        firstDay.add(Duration(days: offset)),
        counts[firstDay.add(Duration(days: offset))] ?? 0,
      ),
  ];
}

DateTime _calendarDay(DateTime moment) {
  final local = moment.toLocal();
  return DateTime(local.year, local.month, local.day);
}
