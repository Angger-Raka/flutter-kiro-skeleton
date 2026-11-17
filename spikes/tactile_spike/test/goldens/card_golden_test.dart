import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tactile_spike/tactile.dart';

import '../load_fonts.dart';

// Update with: flutter test --update-goldens test/goldens
void main() {
  setUpAll(loadInter);

  for (final dpr in [1.0, 2.0, 3.0]) {
    for (final b in Brightness.values) {
      testWidgets('card ${b.name} @${dpr.toInt()}x', (tester) async {
        tester.view.physicalSize = Size(390 * dpr, 400 * dpr);
        tester.view.devicePixelRatio = dpr;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MaterialApp(
          debugShowCheckedModeBanner: false,
          // pointer mode (36 px layout), like Chrome and macOS
          theme: buildTheme(b).copyWith(platform: TargetPlatform.macOS),
          home: const Scaffold(body: CardDemo()),
        ));
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile('card_${b.name}_${dpr.toInt()}x.png'),
        );
      });
    }
  }
}
