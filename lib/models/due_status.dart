/// Where a plant sits relative to its watering schedule.
enum DueStatus {
  overdue,
  dueToday,
  ok;

  static DueStatus fromDays(int daysUntilDue) {
    if (daysUntilDue < 0) return DueStatus.overdue;
    if (daysUntilDue == 0) return DueStatus.dueToday;
    return DueStatus.ok;
  }
}

/// Human-readable form of [daysUntilDue], such as "Due in 3 days",
/// "Due today", or "2 days overdue".
String dueLabel(int daysUntilDue) {
  if (daysUntilDue < 0) {
    final days = -daysUntilDue;
    return days == 1 ? '1 day overdue' : '$days days overdue';
  }
  if (daysUntilDue == 0) return 'Due today';
  if (daysUntilDue == 1) return 'Due tomorrow';
  return 'Due in $daysUntilDue days';
}
