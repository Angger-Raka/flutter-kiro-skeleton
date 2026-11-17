import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icon_spike/icon_table.dart';

// shortcut: font paths come from the local pub cache and FLUTTER_ROOT; spike only.
Future<void> _load(String family, String path) async {
  final bytes = File(path).readAsBytesSync();
  final loader = FontLoader(family)
    ..addFont(Future.value(ByteData.sublistView(bytes)));
  await loader.load();
}

void main() {
  testWidgets('icon table golden', (tester) async {
    final pub = '${Platform.environment['HOME']}/.pub-cache/hosted/pub.dev';
    final flutterRoot = Platform.environment['FLUTTER_ROOT']!;
    await _load('Roboto',
        '$flutterRoot/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf');
    await _load('packages/lucide_icons_flutter/Lucide300',
        '$pub/lucide_icons_flutter-4.0.3/assets/build_font/LucideVariable-w300.ttf');
    await _load('packages/material_symbols_icons/MaterialSymbolsRounded',
        '$pub/material_symbols_icons-4.2960.0/lib/fonts/MaterialSymbolsRounded.ttf');

    tester.view.physicalSize = const Size(1000, 900);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto'),
      home: const Scaffold(
          body: Align(alignment: Alignment.topLeft, child: IconTable())),
    ));
    await tester.pumpAndSettle();
    await expectLater(
        find.byType(MaterialApp), matchesGoldenFile('goldens/icons.png'));
  });
}
