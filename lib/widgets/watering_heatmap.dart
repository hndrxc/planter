import 'package:flutter/material.dart';

import '../models/date_format.dart';
import '../models/plant_statistics.dart';
import '../theme/app_theme.dart';

class WateringHeatmap extends StatelessWidget {
  const WateringHeatmap({super.key, required this.days});

  final List<WateringDay> days;

  @override
  Widget build(BuildContext context) {
    assert(days.length == 56, 'The heatmap represents exactly eight weeks.');
    final scheme = Theme.of(context).colorScheme;
    final maxCount = days.fold<int>(
      0,
      (max, day) => day.count > max ? day.count : max,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 8 / 7,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var week = 0; week < 8; week++)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var weekday = 0; weekday < 7; weekday++)
                        Expanded(
                          child: _HeatmapCell(
                            day: days[week * 7 + weekday],
                            maxCount: maxCount,
                            activeColor: scheme.primary,
                            emptyColor: scheme.surfaceContainerHighest,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Text('8 weeks ago', style: Theme.of(context).textTheme.labelSmall),
            const Spacer(),
            Text('Today', style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ],
    );
  }
}

class _HeatmapCell extends StatelessWidget {
  const _HeatmapCell({
    required this.day,
    required this.maxCount,
    required this.activeColor,
    required this.emptyColor,
  });

  final WateringDay day;
  final int maxCount;
  final Color activeColor;
  final Color emptyColor;

  @override
  Widget build(BuildContext context) {
    final strength = maxCount == 0 ? 0.0 : day.count / maxCount;
    final color = day.count == 0
        ? emptyColor
        : Color.lerp(
            activeColor.withValues(alpha: .28),
            activeColor,
            strength,
          )!;
    final wateringLabel = day.count == 1
        ? '1 watering'
        : '${day.count} waterings';

    return Semantics(
      label: '${formatDate(day.date)}, $wateringLabel',
      child: Tooltip(
        message: '${formatDate(day.date)} · $wateringLabel',
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }
}
