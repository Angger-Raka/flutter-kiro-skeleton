import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeleton/core/theme/tactile/pressable.dart';
import 'package:skeleton/core/theme/tokens.g.dart';

const _leaf = Key('leaf');

/// Input mode follows [defaultTargetPlatform], so tests override it. The
/// override must be cleared before the test body returns (binding invariant).
void platformTest(
  String name,
  TargetPlatform platform,
  Future<void> Function(WidgetTester tester) body,
) {
  testWidgets(name, (tester) async {
    debugDefaultTargetPlatformOverride = platform;
    try {
      await body(tester);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}

Widget host(Widget child) => MaterialApp(
  home: Align(alignment: Alignment.topLeft, child: child),
);

Pressable pressable({VoidCallback? onPressed, String? label}) => Pressable(
  onPressed: onPressed,
  pressedScale: 0.97,
  semanticLabel: label,
  child: const SizedBox(
    key: _leaf,
    width: 80,
    height: 40,
    child: ColoredBox(color: Color(0x00000000)),
  ),
);

double scaleOf(WidgetTester tester) =>
    tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;

Color? fillOf(WidgetTester tester) {
  final box = tester.widget<AnimatedContainer>(find.byType(AnimatedContainer));
  return (box.decoration! as BoxDecoration).color;
}

void main() {
  const hover = Color(0x00000000);
  // panel scope, light: hover = local ground (1) + 1 = working ink 2.
  final expectedHover = AppPalette.light.inkStep(2);

  testWidgets('press scales to pressedScale and release returns to 1', (
    tester,
  ) async {
    await tester.pumpWidget(host(pressable(onPressed: () {})));
    expect(scaleOf(tester), 1);
    final g = await tester.startGesture(tester.getCenter(find.byKey(_leaf)));
    await tester.pump();
    expect(scaleOf(tester), 0.97);
    await g.up();
    await tester.pump();
    expect(scaleOf(tester), 1);
  });

  platformTest('mouse hover shows the hover fill', TargetPlatform.macOS, (
    tester,
  ) async {
    await tester.pumpWidget(host(pressable(onPressed: () {})));
    expect(fillOf(tester), hover);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byKey(_leaf)));
    await tester.pump();
    expect(fillOf(tester), expectedHover);
    await mouse.moveTo(const Offset(700, 500));
    await tester.pump();
    expect(fillOf(tester), hover);
  });

  platformTest(
    'touch shows the fill only while pressed',
    TargetPlatform.android,
    (
      tester,
    ) async {
      await tester.pumpWidget(host(pressable(onPressed: () {})));
      expect(fillOf(tester), hover);
      final g = await tester.startGesture(tester.getCenter(find.byKey(_leaf)));
      await tester.pump();
      expect(fillOf(tester), expectedHover);
      await g.up();
      await tester.pump();
      expect(fillOf(tester), hover);
    },
  );

  testWidgets('semantics: label, button, enabled flag', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(host(pressable(onPressed: () {}, label: 'Save')));
    expect(
      tester.getSemantics(find.bySemanticsLabel('Save')),
      isSemantics(
        label: 'Save',
        isButton: true,
        isEnabled: true,
        hasEnabledState: true,
        hasTapAction: true,
      ),
    );
    await tester.pumpWidget(host(pressable(label: 'Save')));
    expect(
      tester.getSemantics(find.bySemanticsLabel('Save')),
      isSemantics(
        label: 'Save',
        isButton: true,
        isEnabled: false,
        hasEnabledState: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('disabled ignores taps and press', (tester) async {
    await tester.pumpWidget(host(pressable()));
    final g = await tester.startGesture(tester.getCenter(find.byKey(_leaf)));
    await tester.pump();
    expect(scaleOf(tester), 1);
    await g.up();

    var taps = 0;
    await tester.pumpWidget(host(pressable(onPressed: () => taps++)));
    await tester.tap(find.byKey(_leaf));
    expect(taps, 1);
  });

  group('focus ring, hit area, reduced motion', () {
    Finder ring() => find.byWidgetPredicate(
      (w) =>
          w is DecoratedBox &&
          w.decoration is BoxDecoration &&
          (w.decoration as BoxDecoration).border != null,
    );

    platformTest(
      'ring shows on keyboard focus, not on pointer press',
      TargetPlatform.macOS,
      (tester) async {
        var taps = 0;
        await tester.pumpWidget(host(pressable(onPressed: () => taps++)));
        await tester.tap(find.byKey(_leaf));
        await tester.pump();
        expect(ring(), findsNothing);
        expect(taps, 1);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(ring(), findsOneWidget);
        final border =
            (tester.widget<DecoratedBox>(ring()).decoration as BoxDecoration)
                    .border!
                as Border;
        expect(border.top.width, AppStroke.focusRing);
        // Ring sits 2 px outside the control.
        final ringRect = tester.getRect(ring());
        final box = tester.getRect(find.byKey(_leaf));
        expect(ringRect.left, box.left - 4);
        expect(ringRect.top, box.top - 4);

        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(taps, 2);
      },
    );

    platformTest(
      'touch: 4 px outside a 40 px visual still hits, visual unchanged',
      TargetPlatform.android,
      (tester) async {
        var taps = 0;
        await tester.pumpWidget(host(pressable(onPressed: () => taps++)));
        expect(tester.getSize(find.byKey(_leaf)), const Size(80, 40));
        expect(tester.getSize(find.byType(Pressable)), const Size(80, 48));
        final top = tester.getTopLeft(find.byKey(_leaf));
        await tester.tapAt(top + const Offset(40, -3));
        expect(taps, 1);
        await tester.tapAt(top + const Offset(40, -5));
        expect(taps, 1);
      },
    );

    platformTest(
      'pointer: no padding to 48',
      TargetPlatform.macOS,
      (tester) async {
        await tester.pumpWidget(host(pressable(onPressed: () {})));
        expect(tester.getSize(find.byType(Pressable)), const Size(80, 40));
      },
    );

    testWidgets('reduced motion reaches the end scale in one frame', (
      tester,
    ) async {
      Future<double> run({required bool reduce}) async {
        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(disableAnimations: reduce),
            child: host(pressable(onPressed: () {})),
          ),
        );
        final g = await tester.startGesture(
          tester.getCenter(find.byKey(_leaf)),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 16));
        final value = tester
            .widget<ScaleTransition>(find.byType(ScaleTransition).first)
            .scale
            .value;
        await g.up();
        await tester.pumpAndSettle();
        return value;
      }

      expect(await run(reduce: true), 0.97);
      expect(await run(reduce: false), greaterThan(0.97));
    });
  });
}
