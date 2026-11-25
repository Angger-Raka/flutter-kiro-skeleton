import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeleton/core/layout/window_class.dart';
import 'package:skeleton/core/theme/app_theme.dart';
import 'package:skeleton/core/theme/tactile/surface.dart';
import 'package:skeleton/core/theme/tactile/typography.dart';
import 'package:skeleton/core/theme/theme_x.dart';
import 'package:skeleton/core/theme/tokens.g.dart';

Future<void> pump(
  WidgetTester tester,
  Widget Function(BuildContext) read, {
  ThemeData? theme,
  bool reduce = false,
}) => tester.pumpWidget(
  MaterialApp(
    theme: theme,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
      child: child!,
    ),
    home: Builder(builder: read),
  ),
);

void main() {
  testWidgets('under a TactileSurface', (tester) async {
    late BuildContext ctx;
    final theme = buildTheme(
      Brightness.dark,
      WindowClass.desktop,
      InputMode.pointer,
    );
    await pump(
      tester,
      (_) => TactileSurface(
        kind: SurfaceKind.raised,
        child: Builder(
          builder: (c) {
            ctx = c;
            return const SizedBox();
          },
        ),
      ),
      theme: theme,
    );
    expect(ctx.surface.kind, SurfaceKind.raised);
    expect(ctx.text, theme.extension<AppTypography>());
    expect(ctx.hue(HueRole.success), AppPalette.dark.hues[HueRole.success]);
    expect(ctx.hue(HueRole.danger), AppPalette.dark.hues[HueRole.danger]);
    expect(ctx.reduceMotion, isFalse);
  });

  testWidgets('under a bare MaterialApp', (tester) async {
    late BuildContext ctx;
    await pump(tester, (c) {
      ctx = c;
      return const SizedBox();
    }, reduce: true);
    expect(ctx.surface.kind, SurfaceKind.panel);
    expect(ctx.surface.brightness, Brightness.light);
    expect(
      ctx.text.body.fontSize,
      13,
      reason: 'test window is 800 wide (tablet)',
    );
    expect(ctx.hue(HueRole.accent), AppPalette.light.hues[HueRole.accent]);
    expect(ctx.reduceMotion, isTrue);
    expect(() => ctx.identity(0), throwsRangeError);
  });

  testWidgets('sizes follow the input mode', (tester) async {
    late BuildContext ctx;
    for (final (platform, expected) in [
      (TargetPlatform.android, AppSizeSet.touch),
      (TargetPlatform.macOS, AppSizeSet.pointer),
    ]) {
      debugDefaultTargetPlatformOverride = platform;
      await pump(tester, (c) {
        ctx = c;
        return const SizedBox();
      });
      expect(ctx.sizes, expected);
    }
    debugDefaultTargetPlatformOverride = null;
  });
}
