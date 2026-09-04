import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/plant.dart';
import '../state/plant_sort.dart';
import '../state/plant_store.dart';
import '../widgets/empty_state.dart';
import '../widgets/plant_row.dart';
import 'debug_plant_screen.dart';
import 'plant_detail_screen.dart';
import 'plant_form_screen.dart';

/// The list of plants, most urgent first, with a button to add one.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openAddForm(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const PlantFormScreen()));
  }

  void _openDetail(BuildContext context, Plant plant) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlantDetailScreen(plantId: plant.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<PlantStore>();
    final showAddButton = store.isLoaded && store.plants.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planter'),
        actions: [
          if (kDebugMode)
            IconButton(
              tooltip: 'Plant painter lab',
              icon: const Icon(Icons.science_outlined),
              onPressed: () =>
                  Navigator.of(context).pushNamed(DebugPlantScreen.routeName),
            ),
        ],
      ),
      body: _body(context, store),
      floatingActionButton: showAddButton
          ? FloatingActionButton(
              onPressed: () => _openAddForm(context),
              tooltip: 'Add plant',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _body(BuildContext context, PlantStore store) {
    if (!store.isLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    if (store.plants.isEmpty) {
      return EmptyState(onAdd: () => _openAddForm(context));
    }
    final now = store.now;
    final plants = sortByUrgency(store.plants, now);
    return ListView.builder(
      itemCount: plants.length,
      itemBuilder: (context, index) {
        final plant = plants[index];
        return PlantRow(
          plant: plant,
          now: now,
          onTap: () => _openDetail(context, plant),
        );
      },
    );
  }
}
