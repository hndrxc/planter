import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/plant_sort.dart';
import '../state/plant_store.dart';
import '../widgets/plant_row.dart';
import 'plant_form_screen.dart';

/// The list of plants, most urgent first, with a button to add one.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openAddForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PlantFormScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<PlantStore>();
    return Scaffold(
      appBar: AppBar(title: const Text('Planter')),
      body: _body(store),
      floatingActionButton: store.isLoaded
          ? FloatingActionButton(
              onPressed: () => _openAddForm(context),
              tooltip: 'Add plant',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _body(PlantStore store) {
    if (!store.isLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    if (store.plants.isEmpty) {
      return const Center(child: Text('No plants yet'));
    }
    final now = store.now;
    final plants = sortByUrgency(store.plants, now);
    return ListView.builder(
      itemCount: plants.length,
      itemBuilder: (context, index) =>
          PlantRow(plant: plants[index], now: now),
    );
  }
}
