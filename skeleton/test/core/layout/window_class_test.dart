import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart' hide group, setUp, tearDown;
import 'package:kiri_check/kiri_check.dart';
import 'package:skeleton/core/layout/window_class.dart';

void main() {
  property('property 17: width maps to window class', () {
    forAll(float(min: 0, max: 5000), (w) {
      final expected = w < 768
          ? WindowClass.mobile
          : w < 1200
          ? WindowClass.tablet
          : WindowClass.desktop;
      expect(WindowClassX.fromWidth(w), expected);
    });
  });

  test('breakpoint boundaries', () {
    expect(WindowClassX.fromWidth(767.99), WindowClass.mobile);
    expect(WindowClassX.fromWidth(768), WindowClass.tablet);
    expect(WindowClassX.fromWidth(1199.99), WindowClass.tablet);
    expect(WindowClassX.fromWidth(1200), WindowClass.desktop);
  });

  for (final platform in TargetPlatform.values) {
    testWidgets('property 18: input mode for $platform', (tester) async {
      debugDefaultTargetPlatformOverride = platform;
      late BuildContext ctx;
      await tester.pumpWidget(
        Builder(
          builder: (c) {
            ctx = c;
            return const SizedBox();
          },
        ),
      );
      final touch =
          platform == TargetPlatform.iOS || platform == TargetPlatform.android;
      final mode = ctx.inputMode;
      debugDefaultTargetPlatformOverride = null;
      expect(
        mode,
        touch ? InputMode.touch : InputMode.pointer,
      );
    });
  }
}
