import 'package:flutter_test/flutter_test.dart';
import 'package:planter/screens/stats_screen.dart';
import 'package:planter/widgets/watering_heatmap.dart';

import '../support/pump_app.dart';

void main() {
  testWidgets('insights screen shows derived totals and reliability', (
    tester,
  ) async {
    await pumpApp(tester, initial: [monty, lily]);

    await tester.tap(find.byTooltip('Plant insights'));
    await tester.pumpAndSettle();

    expect(find.byType(StatsScreen), findsOneWidget);
    expect(find.text('Total plants'), findsOneWidget);
    expect(find.text('Overdue'), findsOneWidget);
    expect(find.text('Thirstiest'), findsOneWidget);
    expect(find.text('Lily'), findsNWidgets(2));
    expect(find.byType(WateringHeatmap), findsOneWidget);
  });

  testWidgets('heatmap exposes each day to assistive technology', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester, initial: [monty]);
    await tester.tap(find.byTooltip('Plant insights'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Sep 3, 2026, 0 waterings'), findsOneWidget);
    handle.dispose();
  });
}
