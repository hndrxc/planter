import 'package:flutter/material.dart';

import 'data/demo_plants.dart';
import 'data/plant_repository.dart';
import 'models/plant.dart';

void main() {
  runApp(PlanterApp(repository: SharedPrefsPlantRepository()));
}

class PlanterApp extends StatelessWidget {
  const PlanterApp({super.key, required this.repository});

  final PlantRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Planter',
      theme: ThemeData(colorSchemeSeed: Colors.green),
      home: PlantListPreview(repository: repository),
    );
  }
}

/// Milestone 1 stand-in for the real home screen: loads the saved plants
/// (seeding demo data on first launch) and lists them. Replaced by the real
/// screens in milestone 2.
class PlantListPreview extends StatefulWidget {
  const PlantListPreview({super.key, required this.repository});

  final PlantRepository repository;

  @override
  State<PlantListPreview> createState() => _PlantListPreviewState();
}

class _PlantListPreviewState extends State<PlantListPreview> {
  late final Future<List<Plant>> _plants = loadOrSeed(widget.repository);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Planter')),
      body: FutureBuilder<List<Plant>>(
        future: _plants,
        builder: (context, snapshot) {
          final plants = snapshot.data;
          if (plants == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (plants.isEmpty) {
            return const Center(child: Text('No plants saved.'));
          }
          return ListView.builder(
            itemCount: plants.length,
            itemBuilder: (context, index) {
              final plant = plants[index];
              return ListTile(
                leading: const Icon(Icons.local_florist),
                title: Text(plant.name),
                subtitle: Text(
                  '${plant.species} - every ${plant.waterEveryDays} days',
                ),
              );
            },
          );
        },
      ),
    );
  }
}
