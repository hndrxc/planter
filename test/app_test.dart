import 'package:flutter_test/flutter_test.dart';
import 'package:planter/data/plant_repository.dart';
import 'package:planter/main.dart';
import 'package:planter/models/plant.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('a plant saved before launch is listed after launch',
      (tester) async {
    await SharedPrefsPlantRepository().save([
      Plant(
        id: 'k',
        name: 'Kevin',
        species: 'Kentia palm',
        lastWatered: DateTime(2026, 9, 1),
      ),
    ]);

    await tester.pumpWidget(
      PlanterApp(repository: SharedPrefsPlantRepository()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kevin'), findsOneWidget);
    expect(find.text('Monty'), findsNothing,
        reason: 'demo data is only seeded on a fresh install');
  });

  testWidgets('a fresh install is seeded with demo plants', (tester) async {
    await tester.pumpWidget(
      PlanterApp(repository: SharedPrefsPlantRepository()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Monty'), findsOneWidget);
    expect(find.text('Lily'), findsOneWidget);
  });
}
