import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/due_status.dart';
import '../models/plant.dart';
import '../models/plant_health.dart';
import '../state/plant_store.dart';
import 'confirm_delete_dialog.dart';
import 'plant_artwork.dart';
import 'plant_placeholder.dart' show dueColor;
import 'water_action.dart';

/// One plant in the home list: name, species, and how soon it needs water.
/// The drop on the right waters it in one tap; swiping left deletes it after
/// a confirmation.
class PlantRow extends StatelessWidget {
  const PlantRow({
    super.key,
    required this.plant,
    required this.now,
    this.onTap,
  });

  final Plant plant;
  final DateTime now;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final days = plant.daysUntilDue(now);
    final status = DueStatus.fromDays(days);
    final dueStyle = status == DueStatus.ok
        ? null
        : TextStyle(
            color: dueColor(status, scheme),
            fontWeight: FontWeight.w600,
          );
    return Dismissible(
      key: ValueKey('plant-row-${plant.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: scheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
      ),
      confirmDismiss: (_) => confirmDelete(context, plant),
      onDismissed: (_) => context.read<PlantStore>().remove(plant.id),
      child: ListTile(
        leading: PlantArtwork(
          health: healthFromSchedule(plant, now),
          semanticLabel: '${plant.name} health illustration',
        ),
        title: Text(plant.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (plant.species.isNotEmpty) Text(plant.species),
            Text(dueLabel(days), style: dueStyle),
          ],
        ),
        isThreeLine: plant.species.isNotEmpty,
        trailing: IconButton(
          tooltip: 'Water ${plant.name}',
          icon: const Icon(Icons.water_drop_outlined),
          onPressed: () => waterPlant(context, plant),
        ),
        onTap: onTap,
      ),
    );
  }
}
