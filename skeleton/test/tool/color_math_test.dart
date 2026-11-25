import 'package:flutter_test/flutter_test.dart';

import '../../tool/radix/radix_scales.dart';
import '../../tool/src/color_math.dart';

void main() {
  const black = Rgb(0, 0, 0);
  const white = Rgb(255, 255, 255);

  test('hex parse and format round trip', () {
    expect(parseHex('#FDFDFC'), const Rgb(253, 253, 252));
    expect(toHex(const Rgb(1, 2, 255)), '#0102ff');
    expect(parseHex('#20100010'), const Rgb(0x20, 0x10, 0x00));
    expect(() => parseHex('red'), throwsFormatException);
  });

  test('WCAG contrast', () {
    expect(contrastRatio(black, white), closeTo(21, 1e-9));
    expect(contrastRatio(white, black), closeTo(21, 1e-9));
    expect(contrastRatio(white, white), closeTo(1, 1e-9));
    expect(relativeLuminance(white), closeTo(1, 1e-9));
  });

  test('hex -> OKLCH -> hex stays within one unit per channel', () {
    for (final scale in radixScales.values) {
      for (final hex in [...scale.light, ...scale.dark]) {
        final c = parseHex(hex);
        final back = okLchToRgb(rgbToOkLch(c));
        expect((back.r - c.r).abs(), lessThanOrEqualTo(1), reason: hex);
        expect((back.g - c.g).abs(), lessThanOrEqualTo(1), reason: hex);
        expect((back.b - c.b).abs(), lessThanOrEqualTo(1), reason: hex);
      }
    }
  });

  test('OKLab reference points', () {
    expect(rgbToOkLab(white).l, closeTo(1, 1e-3));
    expect(rgbToOkLab(black).l, closeTo(0, 1e-9));
  });

  test('mix at 0 and 1 returns the endpoints; midpoint is between', () {
    const a = Rgb(253, 253, 252);
    const b = Rgb(33, 32, 28);
    expect(mixOkLab(a, b, 0), a);
    expect(mixOkLab(a, b, 1), b);
    final mid = rgbToOkLab(mixOkLab(a, b, 0.5)).l;
    expect(mid, lessThan(rgbToOkLab(a).l));
    expect(mid, greaterThan(rgbToOkLab(b).l));
  });
}
