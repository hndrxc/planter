import 'plant.dart';

/// Converts [plant]'s watering schedule into a continuous health value.
///
/// A plant stays fully healthy through its due date, then declines linearly
/// during a grace window. By default that window is one watering interval, so
/// a plant that is a full cycle late is completely wilted. Supplying
/// [graceDays] is useful when a species-specific tolerance is known.
double healthFromSchedule(Plant plant, DateTime now, {int? graceDays}) {
  final overdue = plant.daysOverdue(now);
  if (overdue == 0) return 1;

  final grace = graceDays ?? plant.waterEveryDays;
  if (grace <= 0 || overdue >= grace) return 0;
  return (1 - overdue / grace).clamp(0.0, 1.0);
}
