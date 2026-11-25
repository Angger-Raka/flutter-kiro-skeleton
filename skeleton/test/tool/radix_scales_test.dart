import 'package:flutter_test/flutter_test.dart';

import '../../tool/radix/radix_scales.dart';

void main() {
  final hex6 = RegExp(r'^#[0-9a-f]{6}$');
  final hex8 = RegExp(r'^#[0-9a-f]{8}$');

  test('the six expected scales are present', () {
    expect(
      radixScales.keys.toSet(),
      {'sand', 'slate', 'blue', 'green', 'red', 'amber'},
    );
  });

  for (final entry in radixScales.entries) {
    test('${entry.key} has 12 light and 12 dark steps plus a3/a4', () {
      final s = entry.value;
      expect(s.name, entry.key);
      expect(s.light, hasLength(12));
      expect(s.dark, hasLength(12));
      expect(s.light.every(hex6.hasMatch), isTrue);
      expect(s.dark.every(hex6.hasMatch), isTrue);
      for (final alpha in [s.lightAlpha, s.darkAlpha]) {
        expect(alpha.keys.toSet(), {'a3', 'a4'});
        expect(alpha.values.every(hex8.hasMatch), isTrue);
      }
    });
  }
}
