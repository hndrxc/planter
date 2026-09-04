import 'package:flutter/material.dart';

import '../models/due_status.dart';

/// Stand-in for the painted plant that milestone 3 replaces. Tinted by how
/// urgently the plant needs water so the list still reads at a glance.
class PlantPlaceholder extends StatelessWidget {
  const PlantPlaceholder({super.key, required this.status, this.size = 44});

  final DueStatus status;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = dueColor(status, Theme.of(context).colorScheme);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.local_florist, size: size * 0.6, color: color),
    );
  }
}

/// The accent color for a plant in [status].
Color dueColor(DueStatus status, ColorScheme scheme) => switch (status) {
      DueStatus.overdue => scheme.error,
      DueStatus.dueToday => Colors.orange.shade800,
      DueStatus.ok => scheme.primary,
    };
