import 'package:flutter/material.dart';

import '../models/due_status.dart';
import '../models/plant.dart';
import 'plant_placeholder.dart';
import 'water_action.dart';

/// One plant in the home list: name, species, and how soon it needs water.
/// The drop on the right waters it in one tap.
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
    final days = plant.daysUntilDue(now);
    final status = DueStatus.fromDays(days);
    final dueStyle = status == DueStatus.ok
        ? null
        : TextStyle(
            color: dueColor(status, Theme.of(context).colorScheme),
            fontWeight: FontWeight.w600,
          );
    return ListTile(
      leading: PlantPlaceholder(status: status),
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
    );
  }
}
