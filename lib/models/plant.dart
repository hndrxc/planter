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
    this.notes = '',
    this.potColorIndex = defaultPotColorIndex,
    this.waterEveryDays = defaultWaterEveryDays,
    required this.lastWatered,
    List<DateTime> history = const [],
  }) : assert(waterEveryDays >= 1, 'waterEveryDays must be at least 1'),
       history = List.unmodifiable(history);

  /// Interval used when none is given.
  static const defaultWaterEveryDays = 7;
  static const defaultPotColorIndex = 0;
  static const potColorCount = 5;

  final String id;
  final String name;
  final String species;
  final String notes;

  /// Index into the app's small, stable pot-color palette.
  final int potColorIndex;

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
    String? notes,
    int? potColorIndex,
    int? waterEveryDays,
    DateTime? lastWatered,
    List<DateTime>? history,
  }) {
    return Plant(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      notes: notes ?? this.notes,
      potColorIndex: potColorIndex ?? this.potColorIndex,
      waterEveryDays: waterEveryDays ?? this.waterEveryDays,
      lastWatered: lastWatered ?? this.lastWatered,
      history: history ?? this.history,
    );
  }

  /// Serializes to a JSON-compatible map. Dates become ISO-8601 UTC strings.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'species': species,
    'notes': notes,
    'potColorIndex': potColorIndex,
    'waterEveryDays': waterEveryDays,
    'lastWatered': _encodeDate(lastWatered),
    'history': history.map(_encodeDate).toList(),
  };

  /// Builds a plant from [json] without throwing.
  ///
  /// Missing or malformed fields fall back to sensible defaults: a fresh id,
  /// a placeholder name, an empty species, the default interval, and an empty
  /// history. History entries that are not valid dates are dropped. If
  /// `lastWatered` is unusable it falls back to the most recent history entry,
  /// and failing that to now.
  factory Plant.fromJson(Map<String, dynamic> json) {
    final history = _readDateList(json['history']);
    return Plant(
      id: _readString(json['id']) ?? newId(),
      name: _readString(json['name']) ?? placeholderName,
      species: _readString(json['species'], allowEmpty: true) ?? '',
      notes: _readString(json['notes'], allowEmpty: true) ?? '',
      potColorIndex: _readPotColorIndex(json['potColorIndex']),
      waterEveryDays: _readInterval(json['waterEveryDays']),
      lastWatered:
          _decodeDate(json['lastWatered']) ??
          (history.isNotEmpty ? history.last : DateTime.now()),
      history: history,
    );
  }

  /// Like [Plant.fromJson], but also tolerates [json] not being an object at
  /// all, in which case it returns null.
  static Plant? tryFromJson(Object? json) {
    if (json is! Map) return null;
    try {
      return Plant.fromJson(
        json.map((key, value) => MapEntry(key.toString(), value)),
      );
    } catch (_) {
      return null;
    }
  }

  /// Name used when saved data has no usable name.
  static const placeholderName = 'Unnamed plant';

  static String _encodeDate(DateTime date) => date.toUtc().toIso8601String();

  static DateTime? _decodeDate(Object? value) =>
      value is String ? DateTime.tryParse(value)?.toLocal() : null;

  static List<DateTime> _readDateList(Object? value) {
    if (value is! List) return const [];
    return value.map(_decodeDate).whereType<DateTime>().toList()..sort();
  }

  static String? _readString(Object? value, {bool allowEmpty = false}) {
    if (value is! String) return null;
    if (value.trim().isEmpty && !allowEmpty) return null;
    return value;
  }

  static int _readInterval(Object? value) {
    final parsed = switch (value) {
      int v => v,
      num v => v.round(),
      String v => int.tryParse(v.trim()),
      _ => null,
    };
    return parsed == null || parsed < 1 ? defaultWaterEveryDays : parsed;
  }

  static int _readPotColorIndex(Object? value) {
    final parsed = switch (value) {
      int v => v,
      num v => v.round(),
      String v => int.tryParse(v.trim()),
      _ => null,
    };
    return parsed != null && parsed >= 0 && parsed < potColorCount
        ? parsed
        : defaultPotColorIndex;
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
          other.notes == notes &&
          other.potColorIndex == potColorIndex &&
          other.waterEveryDays == waterEveryDays &&
          other.lastWatered == lastWatered &&
          listEquals(other.history, history);

  @override
  int get hashCode => Object.hash(
    id,
    name,
    species,
    notes,
    potColorIndex,
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
