import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/date_format.dart';
import '../models/plant.dart';
import '../state/plant_store.dart';
import '../theme/app_theme.dart';
import '../widgets/interval_stepper.dart';
import '../widgets/plant_artwork.dart';

/// Adds a new plant, or edits [initial] when one is given.
class PlantFormScreen extends StatefulWidget {
  const PlantFormScreen({super.key, this.initial});

  final Plant? initial;

  bool get isEditing => initial != null;

  @override
  State<PlantFormScreen> createState() => _PlantFormScreenState();
}

class _PlantFormScreenState extends State<PlantFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _species;
  late final TextEditingController _notes;
  late int _interval;
  late int _potColorIndex;
  late DateTime _lastWatered;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _name = TextEditingController(text: initial?.name ?? '');
    _species = TextEditingController(text: initial?.species ?? '');
    _notes = TextEditingController(text: initial?.notes ?? '');
    _interval = initial?.waterEveryDays ?? Plant.defaultWaterEveryDays;
    _potColorIndex = initial?.potColorIndex ?? Plant.defaultPotColorIndex;
    _lastWatered = initial?.lastWatered ?? context.read<PlantStore>().now;
  }

  @override
  void dispose() {
    _name.dispose();
    _species.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickLastWatered() async {
    final now = context.read<PlantStore>().now;
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastWatered.isAfter(now) ? now : _lastWatered,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      helpText: 'When was it last watered?',
    );
    if (picked == null) return;

    // Keep the time of day, but never claim a watering in the future.
    var chosen = DateTime(
      picked.year,
      picked.month,
      picked.day,
      _lastWatered.hour,
      _lastWatered.minute,
    );
    if (chosen.isAfter(now)) chosen = now;
    setState(() => _lastWatered = chosen);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final store = context.read<PlantStore>();
    final navigator = Navigator.of(context);
    final name = _name.text.trim();
    final species = _species.text.trim();
    final notes = _notes.text.trim();
    final initial = widget.initial;

    if (initial == null) {
      await store.add(
        Plant(
          id: Plant.newId(),
          name: name,
          species: species,
          notes: notes,
          potColorIndex: _potColorIndex,
          waterEveryDays: _interval,
          lastWatered: _lastWatered,
          history: [_lastWatered],
        ),
      );
    } else {
      await store.update(
        initial.copyWith(
          name: name,
          species: species,
          notes: notes,
          potColorIndex: _potColorIndex,
          waterEveryDays: _interval,
          lastWatered: _lastWatered,
        ),
      );
    }
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit plant' : 'Add plant'),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(AppSpacing.md),
        child: FilledButton(onPressed: _save, child: const Text('Save')),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            TextFormField(
              key: const Key('plant-name'),
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. Monty',
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Give the plant a name'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              key: const Key('plant-species'),
              controller: _species,
              decoration: const InputDecoration(
                labelText: 'Species (optional)',
                hintText: 'e.g. Monstera deliciosa',
              ),
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: AppSpacing.lg),
            IntervalStepper(
              value: _interval,
              onChanged: (days) => setState(() => _interval = days),
            ),
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: const Text('Last watered'),
              subtitle: Text(formatDate(_lastWatered)),
              trailing: const Icon(Icons.edit_calendar_outlined),
              onTap: _pickLastWatered,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              key: const Key('plant-notes'),
              controller: _notes,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Light, location, care details…',
                alignLabelWithHint: true,
              ),
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Pot color', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (var index = 0; index < plantPotColors.length; index++)
                  ChoiceChip(
                    key: ValueKey('pot-color-$index'),
                    label: Text(plantPotColorNames[index]),
                    avatar: CircleAvatar(
                      backgroundColor: plantPotColors[index],
                    ),
                    selected: _potColorIndex == index,
                    onSelected: (_) => setState(() => _potColorIndex = index),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
