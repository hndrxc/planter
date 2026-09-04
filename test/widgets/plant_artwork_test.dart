import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planter/screens/debug_plant_screen.dart';
import 'package:planter/widgets/plant_artwork.dart';

void main() {
  test('De Casteljau sampling follows a quadratic curve', () {
    const start = Offset(0, 0);
    const control = Offset(10, 10);
    const end = Offset(20, 0);

    expect(quadraticBezierPoint(start, control, end, 0), start);
    expect(quadraticBezierPoint(start, control, end, .5), const Offset(10, 5));
    expect(quadraticBezierPoint(start, control, end, 1), end);
  });

  testWidgets('artwork animates to a new health value', (tester) async {
    Widget artwork(double health) => MaterialApp(
      home: Center(child: PlantArtwork(health: health, size: 120)),
    );

    await tester.pumpWidget(artwork(1));
    expect(_painter(tester).health, 1);

    await tester.pumpWidget(artwork(0));
    await tester.pump(const Duration(milliseconds: 300));
    expect(_painter(tester).health, isNot(anyOf(0, 1)));

    await tester.pump(const Duration(milliseconds: 300));
    expect(_painter(tester).health, 0);
  });

  testWidgets('debug slider covers the complete health range', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: DebugPlantScreen(initialHealth: .5)),
    );

    expect(find.text('Health 50%'), findsOneWidget);
    final slider = find.byKey(const ValueKey('health-slider'));
    await tester.drag(slider, const Offset(1000, 0));
    await tester.pump();
    expect(find.text('Health 100%'), findsOneWidget);
  });

  test('painter repaints only when health changes', () {
    final healthy = PlantPainter(health: 1);
    expect(healthy.shouldRepaint(PlantPainter(health: 1)), isFalse);
    expect(healthy.shouldRepaint(PlantPainter(health: .5)), isTrue);
  });
}

PlantPainter _painter(WidgetTester tester) {
  final customPaint = tester.widget<CustomPaint>(
    find.byKey(const ValueKey('plant-custom-paint')),
  );
  return customPaint.painter! as PlantPainter;
}
