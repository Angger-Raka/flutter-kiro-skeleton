import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../helpers/core_widget_inventory.dart';

const _widget = CoreWidget(
  name: 'AppThing',
  category: 'action',
  libPath: 'lib/core/widgets/app_thing.dart',
  stressTestPath: 'test/core/widgets/app_thing_test.dart',
  goldenTestPath: 'test/core/widgets/app_thing_golden_test.dart',
  goldenLightPath: 'test/core/widgets/goldens/app_thing_light.png',
  goldenDarkPath: 'test/core/widgets/goldens/app_thing_dark.png',
);

List<String> _check(
  Map<String, String> files, {
  required bool strict,
}) => inventoryCoverageErrors(
  exists: files.containsKey,
  read: (p) => files[p]!,
  strict: strict,
  widgets: [_widget],
);

void main() {
  group('inventoryCoverageErrors (fixtures)', () {
    final full = {
      _widget.libPath: '',
      _widget.stressTestPath: "stressTest('x', (c, d) => const Placeholder());",
      _widget.goldenLightPath: '',
      _widget.goldenDarkPath: '',
    };

    test('a widget with nothing yet is skipped unless strict', () {
      expect(_check({}, strict: false), isEmpty);
      expect(_check({}, strict: true), isNotEmpty);
    });

    test('a complete widget passes', () {
      expect(_check(full, strict: true), isEmpty);
    });

    test('a stress test without goldens fails', () {
      final files = {...full, _widget.stressTestPath: 'stressTest('}
        ..remove(_widget.goldenLightPath)
        ..remove(_widget.goldenDarkPath);
      final errors = _check(files, strict: false);
      expect(errors, hasLength(2));
      expect(errors.join(), contains('golden'));
    });

    test('a golden without a stress test fails', () {
      final files = {...full}..remove(_widget.stressTestPath);
      expect(_check(files, strict: false).single, contains('stress test'));
    });

    test('a dark golden alone is partial coverage', () {
      final errors = _check({_widget.goldenDarkPath: ''}, strict: false);
      expect(errors, hasLength(2));
    });

    test('a stress file that never calls stressTest fails', () {
      final files = {...full, _widget.stressTestPath: '// none'};
      expect(_check(files, strict: false).single, contains('stressTest('));
    });
  });

  test('every started core widget has a stress test and both goldens', () {
    final errors = inventoryCoverageErrors(
      exists: (p) => File(p).existsSync(),
      read: (p) => File(p).readAsStringSync(),
      strict: coreInventoryStrict,
    );
    expect(errors, isEmpty, reason: errors.join('\n'));
  });
}
