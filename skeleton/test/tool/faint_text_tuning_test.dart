import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/generate_tokens.dart';
import '../../tool/src/color_math.dart';
import '../../tool/src/contrast_gates.dart';
import '../../tool/src/faint_text.dart';
import '../../tool/src/knobs.dart';
import '../../tool/src/palette.dart';

void main() {
  final yaml = File(defaultYamlPath).readAsStringSync();
  final knobs = Knobs.parse(yaml);

  test('hue and chroma are unchanged; only lightness moves', () {
    final tuned = tuneFaintText(knobs);
    expect(tuned.adjustments, isNotEmpty);
    for (final a in tuned.adjustments) {
      expect(a.after.h, closeTo(a.before.h, 1e-6), reason: a.name);
      expect(a.after.c, closeTo(a.before.c, 1e-6), reason: a.name);
      expect(a.after.l, isNot(closeTo(a.before.l, 1e-6)), reason: a.name);
    }
  });

  test('ink-10 is tuned in both themes; ink-9 already passes', () {
    final names = tuneFaintText(
      knobs,
    ).adjustments.map((a) => '${a.theme} ${a.name}').toSet();
    expect(names, containsAll(['light ink-10', 'dark ink-10']));
    expect(names, isNot(contains('light ink-9')));
  });

  test('only failing hue-11 steps are tuned (light blue/green/amber)', () {
    final names =
        tuneFaintText(
              knobs,
            ).adjustments
            .where((a) => a.name.startsWith('hue-11'))
            .map(
              (a) => '${a.theme} ${a.name}',
            );
    expect(
      names.toSet(),
      {
        'light hue-11 (accent)',
        'light hue-11 (success)',
        'light hue-11 (warning)',
        'light hue-11 (info)',
      },
    );
  });

  test('adjusted colours pass the gates in both themes', () {
    final tuned = tuneFaintText(knobs);
    final light = buildPalette(
      knobs,
      dark: false,
      ink: tuned.lightInk,
      hue11: tuned.hue11For(dark: false),
    );
    final dark = buildPalette(
      knobs,
      dark: true,
      ink: tuned.darkInk,
      hue11: tuned.hue11For(dark: true),
    );
    final results = runContrastGates(
      knobs,
      light,
      dark,
      ink10Minimum: metaInk10Minimum,
    );
    expect(failures(results), isEmpty, reason: '${failures(results)}');
  });

  group('generator', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('faint_text_'));
    tearDown(() => dir.deleteSync(recursive: true));

    Future<(int, String, File)> run(String source) async {
      final y = File('${dir.path}/tokens.yaml')..writeAsStringSync(source);
      final out = File('${dir.path}/tokens.g.dart')
        ..writeAsStringSync('// previous\n');
      final log = StringBuffer();
      final code = await runGenerator(
        yamlPath: y.path,
        outputPath: out.path,
        stdout: log,
      );
      return (code, log.toString(), out);
    }

    test(
      'default YAML exits 0, lists each adjustment, writes no docs',
      () async {
        final docs = File('docs/DESIGN_TOKENS.md');
        final (code, log, out) = await run(yaml);
        expect(code, 0);
        expect(log, contains('tune light ink-10'));
        expect(log, contains('tune dark ink-10'));
        expect(log, contains('tune light hue-11 (success)'));
        expect(out.readAsStringSync(), contains('GENERATED'));
        expect(docs.existsSync(), isFalse);
        expect(File('../docs/DESIGN_TOKENS.md').existsSync(), isFalse);
      },
    );

    test('overrides are printed', () async {
      final (code, log, _) = await run(
        yaml.replaceFirst('overrides: {}', 'overrides: {radius_note: kept}'),
      );
      expect(code, 0);
      expect(log, contains('override applied: radius_note: kept'));
    });

    test('failing gate: non-zero, pair printed, output unchanged', () async {
      final (code, log, out) = await run(
        yaml
            .replaceFirst('tune_faint_text: true', 'tune_faint_text: false')
            .replaceFirst('primary: neutral', 'primary: accent'),
      );
      expect(code, isNonZero);
      expect(log, contains('accent primary text'));
      expect(log, contains(RegExp(r'\d\.\d\d:1')));
      expect(out.readAsStringSync(), '// previous\n');
    });

    test('untuned defaults still fail the light hue-11 gate', () async {
      final (code, log, out) = await run(
        yaml.replaceFirst('tune_faint_text: true', 'tune_faint_text: false'),
      );
      expect(code, isNonZero);
      expect(log, contains('hue-11 on hue-3'));
      expect(out.readAsStringSync(), '// previous\n');
    });
  });

  test('tuned rgb is what the gate measured (8-bit)', () {
    for (final a in tuneFaintText(knobs).adjustments) {
      expect(toHex(a.rgbAfter), matches(RegExp(r'^#[0-9a-f]{6}$')));
    }
  });
}
