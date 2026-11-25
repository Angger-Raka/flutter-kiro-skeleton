import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeleton/core/theme/tactile/motion.dart';

void main() {
  test('durations', () {
    expect(
      [
        AppMotion.d80,
        AppMotion.d120,
        AppMotion.d150,
        AppMotion.d200,
        AppMotion.d240,
        AppMotion.d300,
        AppMotion.d320,
      ].map((d) => d.inMilliseconds),
      [80, 120, 150, 200, 240, 300, 320],
    );
  });

  test('curves', () {
    expect(AppMotion.easeOut, const Cubic(0.23, 1, 0.32, 1));
    expect(AppMotion.easeMove, const Cubic(0.22, 1, 0.36, 1));
    expect(AppMotion.easeDrawer, const Cubic(0.32, 0.72, 0, 1));
    expect(AppMotion.easeInOut, const Cubic(0.77, 0, 0.175, 1));
  });

  void expectSpring(SpringDescription s, double bounce, double d) {
    expect(s.mass, 1);
    expect(s.stiffness, closeTo(math.pow(2 * math.pi / d, 2), 1e-9));
    expect(s.damping, closeTo(4 * math.pi * (1 - bounce) / d, 1e-9));
  }

  test('springs', () {
    expectSpring(AppSprings.toggle, 0.12, 0.4);
    expectSpring(AppSprings.knob, 0.2, 0.45);
    expectSpring(AppSprings.reveal, 0.2, 0.35);
  });

  testWidgets('reduceMotion follows MediaQuery.disableAnimations', (
    tester,
  ) async {
    late bool value;
    Widget app({required bool disable}) => MediaQuery(
      data: MediaQueryData(disableAnimations: disable),
      child: Builder(
        builder: (c) {
          value = c.reduceMotion;
          return const SizedBox();
        },
      ),
    );
    await tester.pumpWidget(app(disable: true));
    expect(value, isTrue);
    await tester.pumpWidget(app(disable: false));
    expect(value, isFalse);
  });
}
