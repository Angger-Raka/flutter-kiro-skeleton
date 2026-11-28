import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/generate_tokens.dart';
import '../../tool/src/ladders.dart';

void main() {
  test('radius ladder table', () {
    const table = <(double, Map<String, double>)>[
      (6, {'xs': 3, 'sm': 4, 'control': 6, 'container': 8, 'feature': 12}),
      (4, {'xs': 2, 'sm': 2, 'control': 4, 'container': 6, 'feature': 9}),
      (8, {'xs': 4, 'sm': 6, 'control': 8, 'container': 10, 'feature': 15}),
    ];
    for (final (c, expected) in table) {
      final ladder = radiusLadder(c);
      expected.forEach((k, v) => expect(ladder[k], v, reason: 'c=$c $k'));
      expect(ladder['sheet'], 14);
    }
  });

  test('AppLayout matches requirement 20.4 exactly', () {
    expect(layoutTokens.values.toList(), [
      768, 1200, 800, 1200, 440, 256, 72, 52, 56, 8, //
    ]);
    final src = renderLadders(6);
    final layout = src.substring(src.indexOf('abstract final class AppLayout'));
    expect(layout, contains('breakpointTablet = 768;'));
    expect(layout, contains('breakpointDesktop = 1200;'));
    expect(layout, contains('colReading = 800;'));
    expect(layout, contains('colData = 1200;'));
    expect(layout, contains('colForm = 440;'));
    expect(layout, contains('railExpanded = 256;'));
    expect(layout, contains('railCollapsed = 72;'));
    expect(layout, contains('topStrip = 52;'));
    expect(layout, contains('mobileTopBar = 56;'));
    expect(layout, contains('panelFloat = 8;'));
  });

  test('AppOverlay holds the overlay sizes of design D13', () {
    expect(overlayTokens, {
      'dialogDefault': 620,
      'dialogConfirm': 460,
      'dialogInfo': 440,
      'toastHeight': 48,
      'sheetHandleWidth': 36,
      'sheetHandleHeight': 5,
      'sheetHandleHitWidth': 88,
      'sheetHandleHitHeight': 44,
      'emptyPadding': 44,
      'dialogRise': 16,
      'dialogBlur': 4,
      'backdropBlur': 2,
    });
    final src = renderLadders(6);
    expect(
      src.indexOf('class AppOverlay'),
      greaterThan(src.indexOf('class AppLayout')),
    );
    final overlay = src.substring(
      src.indexOf('abstract final class AppOverlay'),
    );
    for (final e in overlayTokens.entries) {
      expect(
        overlay,
        contains('static const double ${e.key} = ${e.value.toInt()};'),
      );
    }
  });

  test('sizes, spacing, strokes are rendered', () {
    final src = renderLadders(6);
    expect(src, contains('control: 36,'));
    expect(src, contains('control: 44,'));
    expect(src, contains('toggleTrack: 42,'));
    expect(src, contains('static const double s64 = 64;'));
    expect(src, contains('hairline = 0.5;'));
    expect(src, contains('static const double feature = 12;'));
  });

  test('generated file contains the ladders and is valid Dart', () async {
    Directory('build').createSync(recursive: true);
    final dir = Directory('build').createTempSync('tokens_ladders_');
    addTearDown(() => dir.deleteSync(recursive: true));
    final out = '${dir.path}/tokens_out.dart';
    expect(
      await runGenerator(
        yamlPath: defaultYamlPath,
        outputPath: out,
        stdout: StringBuffer(),
      ),
      0,
    );
    final src = File(out).readAsStringSync();
    expect(src, contains('abstract final class AppSpace'));
    expect(src, contains('abstract final class AppLayout'));
    final r = Process.runSync('dart', ['analyze', out]);
    expect(r.stdout, isNot(contains('error •')), reason: '${r.stdout}');
  });
}
