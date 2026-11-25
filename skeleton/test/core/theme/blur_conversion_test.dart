import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart' hide group, setUp, tearDown;
import 'package:kiri_check/kiri_check.dart';
import 'package:skeleton/core/theme/tactile/blur_conversion.dart';

void main() {
  property('property 8: matches the formula and is never negative', () {
    forAll(float(min: 0, max: 1000), maxExamples: 200, (css) {
      final expected = math.max(0, (css / 2 - 0.5) / 0.57735);
      final actual = cssBlurToFlutter(css);
      expect(actual, closeTo(expected, 1e-9));
      expect(actual, greaterThanOrEqualTo(0));
    });
  });

  test('property 9: zero blur stays zero', () {
    expect(cssBlurToFlutter(0), 0);
  });

  property('property 10: monotonic', () {
    forAll(
      combine2(float(min: 0, max: 1000), float(min: 0, max: 1000)),
      maxExamples: 200,
      (pair) {
        final lo = math.min(pair.$1, pair.$2);
        final hi = math.max(pair.$1, pair.$2);
        expect(cssBlurToFlutter(lo), lessThanOrEqualTo(cssBlurToFlutter(hi)));
      },
    );
  });

  test('known values', () {
    const table = <(double, double)>[
      (0, 0),
      (1, 0),
      (2, 0.86602),
      (4, 2.59808),
      (8, 6.06218),
    ];
    for (final (css, flutter) in table) {
      expect(cssBlurToFlutter(css), closeTo(flutter, 1e-4), reason: '$css');
    }
  });
}
