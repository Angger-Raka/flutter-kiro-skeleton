import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/color_math.dart';
import '../../tool/src/contrast_gates.dart';
import '../../tool/src/knobs.dart';
import '../../tool/src/palette.dart';

List<GateResult> gates(Knobs knobs, {double ink10 = iconInk10Minimum}) {
  final light = buildPalette(
    knobs,
    dark: false,
    ink: baseInk(knobs, dark: false),
  );
  final dark = buildPalette(knobs, dark: true, ink: baseInk(knobs, dark: true));
  return runContrastGates(knobs, light, dark, ink10Minimum: ink10);
}

void main() {
  final yaml = File('design/tokens.yaml').readAsStringSync();
  final defaults = Knobs.parse(yaml);

  test('every gate of 04 §4.6 is checked in both themes', () {
    final results = gates(defaults);
    for (final theme in ['light', 'dark']) {
      final names = [
        for (final r in results)
          if (r.theme == theme) r.name,
      ];
      expect(
        names,
        containsAll([
          'ink-12 on ink-1',
          'ink-12 on ink-2',
          'ink-12 on ink-3',
          'ink-11 on ink-3',
          'ink-10 on ink-1',
          'ink-9 on ink-1',
          'hue-11 on hue-3 (accent)',
          'hue-11 on hue-3 (danger)',
          'ink-6 hairline vs surface top',
          'focus ring on surface top',
          'focus ring on ink-3',
        ]),
      );
    }
    final dark = [
      for (final r in results)
        if (r.theme == 'dark') r.name,
    ];
    expect(
      dark,
      containsAll([
        'focus ring on ink-1',
        'focus ring on ink-2',
        'focus ring on ink-4',
      ]),
    );
  });

  test('untuned defaults: only ink-10 (4.5) and light hue-11 fail', () {
    final failed = failures(gates(defaults, ink10: metaInk10Minimum));
    expect(
      failed.map((r) => '${r.theme} ${r.name}').toSet(),
      {
        'light ink-10 on ink-1',
        'dark ink-10 on ink-1',
        'light hue-11 on hue-3 (accent)',
        'light hue-11 on hue-3 (success)',
        'light hue-11 on hue-3 (warning)',
        'light hue-11 on hue-3 (info)',
      },
    );
    // Light ink-10 on white-ish ground is the documented 3.8:1.
    final ink10 = failed.firstWhere(
      (r) => r.theme == 'light' && r.name == 'ink-10 on ink-1',
    );
    expect(ink10.ratio, closeTo(3.80, 0.02));
  });

  test('untuned defaults pass every gate at the icon tier for ink-10', () {
    final failed = failures(gates(defaults));
    expect(failed.map((r) => r.name), everyElement(startsWith('hue-11')));
  });

  test('a failing gate prints the pair and its ratio', () {
    final accent = Knobs.parse(
      yaml.replaceFirst('primary: neutral', 'primary: accent'),
    );
    final failed = failures(gates(accent));
    final r = failed.firstWhere((r) => r.name == 'accent primary text');
    final text = r.toString();
    expect(text, contains('FAIL'));
    expect(text, contains(toHex(r.fg)));
    expect(text, contains(toHex(r.bg)));
    expect(text, contains(r.ratio.toStringAsFixed(2)));
    expect(r.passed, isFalse);
  });

  test('a low-contrast surface_top fails the hairline gate', () {
    final k = Knobs.parse(
      yaml.replaceFirst('surface_top: "#ffffff"', 'surface_top: "#dad9d6"'),
    );
    expect(
      failures(gates(k)).map((r) => r.name),
      contains('ink-6 hairline vs surface top'),
    );
  });
}
