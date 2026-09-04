import 'package:flutter/material.dart';

import '../widgets/plant_artwork.dart';

/// Development playground for checking every point in the wilt animation.
class DebugPlantScreen extends StatefulWidget {
  const DebugPlantScreen({super.key, this.initialHealth = 1});

  static const routeName = '/debug/plant';

  final double initialHealth;

  @override
  State<DebugPlantScreen> createState() => _DebugPlantScreenState();
}

class _DebugPlantScreenState extends State<DebugPlantScreen> {
  late double _health = widget.initialHealth.clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final percentage = (_health * 100).round();
    return Scaffold(
      appBar: AppBar(title: const Text('Plant painter lab')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PlantArtwork(
                  health: _health,
                  size: 280,
                  semanticLabel: 'Debug plant at $percentage% health',
                ),
                const SizedBox(height: 24),
                Text(
                  'Health $percentage%',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Slider(
                  key: const ValueKey('health-slider'),
                  value: _health,
                  divisions: 100,
                  label: '$percentage%',
                  onChanged: (value) => setState(() => _health = value),
                ),
                const Text('Wilted'),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text('Healthy'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
