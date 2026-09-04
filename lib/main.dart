import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/plant_repository.dart';
import 'screens/debug_plant_screen.dart';
import 'screens/home_screen.dart';
import 'state/plant_store.dart';
import 'theme/app_theme.dart';

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
        theme: planterTheme(Brightness.light),
        darkTheme: planterTheme(Brightness.dark),
        themeMode: ThemeMode.system,
        routes: {
          if (kDebugMode)
            DebugPlantScreen.routeName: (_) => const DebugPlantScreen(),
        },
        home: const HomeScreen(),
      ),
    );
  }
}
