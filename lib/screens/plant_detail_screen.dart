import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/date_format.dart';
import '../models/due_status.dart';
import '../models/plant.dart';
import '../state/plant_store.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/plant_placeholder.dart';
import '../widgets/water_action.dart';
import 'plant_form_screen.dart';

/// Everything about one plant: its schedule, the full watering history, and
/// the edit and delete actions.
class PlantDetailScreen extends StatefulWidget {
  const PlantDetailScreen({super.key, required this.plantId});

  final String plantId;

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  /// The last version of the plant this screen rendered, so it stays intact
  /// while animating away after a delete.
  Plant? _lastSeen;

  Future<void> _delete(Plant plant) async {
    final store = context.read<PlantStore>();
    final navigator = Navigator.of(context);
    if (!await confirmDelete(context, plant)) return;
    navigator.pop();
    await store.remove(plant.id);
  }

  void _edit(Plant plant) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlantFormScreen(initial: plant),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<PlantStore>();
    final plant = store.byId(widget.plantId) ?? _lastSeen;
    if (plant == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('This plant is no longer here.')),
      );
    }
    _lastSeen = plant;

    final theme = Theme.of(context);
    final days = plant.daysUntilDue(store.now);
    final status = DueStatus.fromDays(days);
    final history = plant.history.reversed.toList();
    final interval = plant.waterEveryDays == 1
        ? 'every day'
        : 'every ${plant.waterEveryDays} days';

    return Scaffold(
      appBar: AppBar(
        title: Text(plant.name),
        actions: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _edit(plant),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _delete(plant),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(child: PlantPlaceholder(status: status, size: 120)),
          const SizedBox(height: 16),
          if (plant.species.isNotEmpty)
            Text(
              plant.species,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 8),
          Text(
            dueLabel(days),
            style: theme.textTheme.titleLarge?.copyWith(
              color: dueColor(status, theme.colorScheme),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Water $interval. Last watered '
            '${formatDateTime(plant.lastWatered)}.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => waterPlant(context, plant),
            icon: const Icon(Icons.water_drop),
            label: const Text('Water now'),
          ),
          const SizedBox(height: 32),
          Text('Watering history', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          if (history.isEmpty)
            Text(
              'No waterings recorded yet.',
              style: theme.textTheme.bodyMedium,
            )
          else
            for (final date in history)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.water_drop_outlined),
                title: Text(formatDate(date)),
                subtitle: Text(formatTime(date)),
              ),
        ],
      ),
    );
  }
}
