import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/plant_repository.dart';
import 'screens/home_screen.dart';
import 'state/plant_store.dart';

void main() {
  runApp(PlanterApp(repository: SharedPrefsPlantRepository()));
}

class PlanterApp extends StatelessWidget {
  const PlanterApp({super.key, required this.repository, this.clock});

  final PlantRepository repository;

  /// Source of "now". Injectable so tests can pin the date.
  final DateTime Function()? clock;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PlantStore>(
      create: (_) => PlantStore(repository, clock: clock)..load(),
      child: MaterialApp(
        title: 'Planter',
        theme: ThemeData(colorSchemeSeed: Colors.green),
        home: const HomeScreen(),
      ),
    );
  }
}
