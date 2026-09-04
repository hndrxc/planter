import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/plant_statistics.dart';
import '../state/plant_store.dart';
import '../theme/app_theme.dart';
import '../widgets/watering_heatmap.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<PlantStore>();
    final stats = calculatePlantStatistics(store.plants, store.now);
    final plants = [...store.plants]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Scaffold(
      appBar: AppBar(title: const Text('Plant insights')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatsGrid(
                children: [
                  _StatCard(
                    label: 'Total plants',
                    value: '${stats.totalPlants}',
                    icon: Icons.local_florist_outlined,
                  ),
                  _StatCard(
                    label: 'Overdue',
                    value: '${stats.overduePlants}',
                    icon: Icons.notification_important_outlined,
                  ),
                  _StatCard(
                    label: 'This month',
                    value: '${stats.wateringsThisMonth}',
                    icon: Icons.water_drop_outlined,
                  ),
                  _StatCard(
                    label: 'Thirstiest',
                    value: stats.thirstiestPlant?.name ?? '—',
                    icon: Icons.bolt_outlined,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Watering activity',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Every square is a day; darker squares mean more waterings.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              WateringHeatmap(days: stats.heatmap),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Plant reliability',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (plants.isEmpty)
                const Text('Add plants to begin tracking reliability.')
              else
                for (final plant in plants)
                  Builder(
                    builder: (context) {
                      final reliability = stats.reliabilityByPlantId[plant.id]!;
                      final percentage = reliability.percentage;
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.verified_outlined),
                          title: Text(plant.name),
                          subtitle: Text(
                            percentage == null
                                ? 'Not enough watering history'
                                : '${reliability.onTimeWaterings} of '
                                      '${reliability.trackedWaterings} on time · '
                                      '${reliability.currentStreak} streak',
                          ),
                          trailing: Text(
                            percentage == null ? '—' : '${percentage.round()}%',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      );
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - AppSpacing.sm) / 2;
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final child in children)
              SizedBox(width: width, height: 112, child: child),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall,
                  ),
                  Text(label, style: theme.textTheme.labelMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
