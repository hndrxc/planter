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
import 'stats_screen.dart';

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
          IconButton(
            tooltip: 'Plant insights',
            icon: const Icon(Icons.insights_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const StatsScreen()),
            ),
          ),
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
    final needsWater = plants
        .where((plant) => plant.daysUntilDue(now) <= 0)
        .toList();
    final allGood = plants
        .where((plant) => plant.daysUntilDue(now) > 0)
        .toList();
    final entries = <Widget>[
      if (needsWater.isNotEmpty) ...[
        const _SectionHeader(
          title: 'Needs water',
          icon: Icons.water_drop_outlined,
        ),
        for (final plant in needsWater)
          PlantRow(
            plant: plant,
            now: now,
            onTap: () => _openDetail(context, plant),
          ),
      ],
      if (allGood.isNotEmpty) ...[
        const _SectionHeader(title: 'All good', icon: Icons.eco_outlined),
        for (final plant in allGood)
          PlantRow(
            plant: plant,
            now: now,
            onTap: () => _openDetail(context, plant),
          ),
      ],
    ];
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) => entries[index],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      header: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
        child: Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(title, style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
