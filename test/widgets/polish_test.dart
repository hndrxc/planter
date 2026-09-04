import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:planter/screens/plant_form_screen.dart';
import 'package:planter/theme/app_theme.dart';
import 'package:planter/widgets/plant_artwork.dart';

import '../support/pump_app.dart';

void main() {
  testWidgets('notes and pot color can be edited and persist', (tester) async {
    final repository = await pumpApp(tester, initial: [monty]);
    await tester.tap(find.text('Monty'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Edit'));
    await tester.pumpAndSettle();

    expect(find.byType(PlantFormScreen), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('plant-notes')),
      'Rotate weekly.',
    );
    final pot = find.byKey(const ValueKey('pot-color-2'));
    await tester.drag(
      find.descendant(
        of: find.byType(PlantFormScreen),
        matching: find.byType(ListView),
      ),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();
    await tester.tap(pot);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final saved = repository.stored!.single;
    expect(saved.notes, 'Rotate weekly.');
    expect(saved.potColorIndex, 2);
    expect(find.text('Rotate weekly.'), findsOneWidget);
    expect(
      tester.widget<PlantArtwork>(find.byType(PlantArtwork)).potColorIndex,
      2,
    );
  });

  testWidgets('plant artwork has a descriptive semantic label', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester, initial: [lily]);

    expect(
      find.bySemanticsLabel(RegExp(r'Lily, .*\d+% health')),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('primary icon actions meet the 48dp tap-target minimum', (
    tester,
  ) async {
    await pumpApp(tester, initial: [monty]);

    for (final tooltip in ['Plant insights', 'Add plant', 'Water Monty']) {
      final size = tester.getSize(find.byTooltip(tooltip));
      expect(size.width, greaterThanOrEqualTo(48), reason: tooltip);
      expect(size.height, greaterThanOrEqualTo(48), reason: tooltip);
    }
  });

  testWidgets('form controls meet the 48dp tap-target minimum', (tester) async {
    await pumpApp(tester, initial: [monty]);
    await tester.tap(find.byTooltip('Add plant'));
    await tester.pumpAndSettle();

    for (final element in find.byType(IconButton).evaluate()) {
      final size = tester.getSize(find.byElementPredicate((e) => e == element));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    }
    final saveSize = tester.getSize(find.widgetWithText(FilledButton, 'Save'));
    expect(saveSize.width, greaterThanOrEqualTo(48));
    expect(saveSize.height, greaterThanOrEqualTo(48));

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.byType(ChoiceChip), findsNWidgets(5));
    for (final element in find.byType(ChoiceChip).evaluate()) {
      final size = tester.getSize(find.byElementPredicate((e) => e == element));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    }
  });

  testWidgets('dark theme uses a dark color scheme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: planterTheme(Brightness.light),
        darkTheme: planterTheme(Brightness.dark),
        themeMode: ThemeMode.dark,
        home: const Scaffold(),
      ),
    );

    final context = tester.element(find.byType(Scaffold));
    expect(Theme.of(context).brightness, Brightness.dark);
  });
}
