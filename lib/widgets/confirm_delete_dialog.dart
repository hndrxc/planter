import 'package:flutter/material.dart';

import '../models/plant.dart';

/// Asks whether to delete [plant]. Resolves to true only if the user confirms.
Future<bool> confirmDelete(BuildContext context, Plant plant) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete ${plant.name}?'),
      content: const Text(
        'This removes the plant and its watering history. It cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
