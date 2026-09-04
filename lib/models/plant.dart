import 'dart:math';

import 'package:flutter/foundation.dart';

/// A houseplant and its watering schedule.
///
/// [lastWatered] is kept as its own field rather than derived from [history]
/// so a plant can be created with a known last watering before any history
/// has been recorded. [history] is every recorded watering, oldest first.
@immutable
class Plant {
  Plant({
    required this.id,
    required this.name,
    this.species = '',
    this.waterEveryDays = defaultWaterEveryDays,
    required this.lastWatered,
    List<DateTime> history = const [],
  })  : assert(waterEveryDays >= 1, 'waterEveryDays must be at least 1'),
        history = List.unmodifiable(history);

  /// Interval used when none is given.
  static const defaultWaterEveryDays = 7;

  final String id;
  final String name;
  final String species;

  /// How often the plant should be watered, in days. Always at least 1.
  final int waterEveryDays;

  /// When the plant was most recently watered.
  final DateTime lastWatered;

  /// Every recorded watering, oldest first. Unmodifiable.
  final List<DateTime> history;

  /// The moment the next watering is due.
  DateTime get nextDue => lastWatered.add(Duration(days: waterEveryDays));

  /// Whole calendar days until the next watering is due, as seen from [now].
  ///
  /// Zero means due today, negative means overdue. Time of day is ignored, so
  /// a plant watered at 9pm and checked at 8am the next morning counts as one
  /// day, not zero.
  int daysUntilDue(DateTime now) {
    final due = _calendarDay(lastWatered).add(Duration(days: waterEveryDays));
    return due.difference(_calendarDay(now)).inDays;
  }

  /// How many whole days past due the plant is, or zero if it is not overdue.
  int daysOverdue(DateTime now) {
    final days = daysUntilDue(now);
    return days < 0 ? -days : 0;
  }

  bool isOverdue(DateTime now) => daysUntilDue(now) < 0;

  /// A copy of this plant recorded as watered at [at].
  Plant watered(DateTime at) =>
      copyWith(lastWatered: at, history: [...history, at]..sort());

  Plant copyWith({
    String? id,
    String? name,
    String? species,
    int? waterEveryDays,
    DateTime? lastWatered,
    List<DateTime>? history,
  }) {
    return Plant(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      waterEveryDays: waterEveryDays ?? this.waterEveryDays,
      lastWatered: lastWatered ?? this.lastWatered,
      history: history ?? this.history,
    );
  }

  /// A new id for a plant created on this device.
  static String newId() {
    final stamp = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final salt = _random.nextInt(1 << 30).toRadixString(36);
    return '$stamp-$salt';
  }

  static final _random = Random();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Plant &&
          other.id == id &&
          other.name == name &&
          other.species == species &&
          other.waterEveryDays == waterEveryDays &&
          other.lastWatered == lastWatered &&
          listEquals(other.history, history);

  @override
  int get hashCode => Object.hash(
        id,
        name,
        species,
        waterEveryDays,
        lastWatered,
        Object.hashAll(history),
      );

  @override
  String toString() =>
      'Plant($id, $name, $species, every ${waterEveryDays}d, last $lastWatered)';
}

/// Midnight UTC on the local calendar day of [moment], so day arithmetic is
/// immune to daylight-saving shifts.
DateTime _calendarDay(DateTime moment) {
  final local = moment.toLocal();
  return DateTime.utc(local.year, local.month, local.day);
}
