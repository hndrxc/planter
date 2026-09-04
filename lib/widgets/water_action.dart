import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/plant.dart';
import '../state/plant_store.dart';

/// Records a watering for [plant] right now and shows a snackbar with undo.
Future<void> waterPlant(BuildContext context, Plant plant) async {
  final store = context.read<PlantStore>();
  final messenger = ScaffoldMessenger.of(context);
  final before = store.byId(plant.id) ?? plant;

  final after = await store.water(plant.id);
  if (after == null) return;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text('Watered ${plant.name}'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => store.update(before),
        ),
      ),
    );
}
