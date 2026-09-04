import 'package:flutter_test/flutter_test.dart';
import 'package:planter/models/date_format.dart';
import 'package:planter/models/due_status.dart';

void main() {
  test('dueLabel reads naturally at every boundary', () {
    expect(dueLabel(-5), '5 days overdue');
    expect(dueLabel(-1), '1 day overdue');
    expect(dueLabel(0), 'Due today');
    expect(dueLabel(1), 'Due tomorrow');
    expect(dueLabel(2), 'Due in 2 days');
    expect(dueLabel(14), 'Due in 14 days');
  });

  test('DueStatus.fromDays', () {
    expect(DueStatus.fromDays(-3), DueStatus.overdue);
    expect(DueStatus.fromDays(-1), DueStatus.overdue);
    expect(DueStatus.fromDays(0), DueStatus.dueToday);
    expect(DueStatus.fromDays(1), DueStatus.ok);
  });

  test('date formatting', () {
    expect(formatDate(DateTime(2026, 9, 3, 12)), 'Sep 3, 2026');
    expect(formatDate(DateTime(2026, 12, 25)), 'Dec 25, 2026');
    expect(formatTime(DateTime(2026, 9, 3, 0, 5)), '12:05 AM');
    expect(formatTime(DateTime(2026, 9, 3, 9, 30)), '9:30 AM');
    expect(formatTime(DateTime(2026, 9, 3, 12, 0)), '12:00 PM');
    expect(formatTime(DateTime(2026, 9, 3, 17, 45)), '5:45 PM');
    expect(formatDateTime(DateTime(2026, 9, 3, 17, 45)),
        'Sep 3, 2026 at 5:45 PM');
  });
}
