import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planter/theme/app_theme.dart';
import 'package:planter/widgets/plant_artwork.dart';

import 'support/pump_app.dart';

void main() {
  setUpAll(_loadRobotoForGoldens);

  testWidgets('README health stages screenshot', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 320));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const stages = <(double, String)>[
      (1, 'Healthy'),
      (.67, 'Getting thirsty'),
      (.33, 'Wilting'),
      (0, 'Fully wilted'),
    ];
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: planterTheme(Brightness.light),
        home: Scaffold(
          body: RepaintBoundary(
            key: const ValueKey('health-stages-shot'),
            child: ColoredBox(
              color: const Color(0xfff7f5ef),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'One plant, four stages',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Row(
                        children: [
                          for (final stage in stages)
                            Expanded(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: PlantArtwork(
                                      health: stage.$1,
                                      size: 180,
                                      animationDuration: Duration.zero,
                                    ),
                                  ),
                                  Text(
                                    stage.$2,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('health-stages-shot')),
      matchesGoldenFile('../docs/screenshots/health-stages.png'),
    );
  });

  testWidgets('README home screenshot', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpApp(tester);

    expect(
      find.byType(Scaffold).first,
      matchesGoldenFile('../docs/screenshots/home.png'),
    );
  });
}

Future<void> _loadRobotoForGoldens() async {
  var directory = File(Platform.resolvedExecutable).parent;
  Directory? fontsDirectory;
  for (var level = 0; level < 8; level++) {
    final candidate = Directory(
      '${directory.path}/bin/cache/artifacts/material_fonts',
    );
    if (File('${candidate.path}/Roboto-Regular.ttf').existsSync()) {
      fontsDirectory = candidate;
      break;
    }
    directory = directory.parent;
  }
  if (fontsDirectory == null) {
    throw StateError('Could not locate Flutter\'s bundled fonts.');
  }
  await Future.wait([
    _loadFont('Roboto', File('${fontsDirectory.path}/Roboto-Regular.ttf')),
    _loadFont(
      'MaterialIcons',
      File('${fontsDirectory.path}/MaterialIcons-Regular.otf'),
    ),
  ]);
}

Future<void> _loadFont(String family, File file) async {
  final bytes = await file.readAsBytes();
  await (FontLoader(
    family,
  )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
}
