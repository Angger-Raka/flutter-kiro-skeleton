import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
}
