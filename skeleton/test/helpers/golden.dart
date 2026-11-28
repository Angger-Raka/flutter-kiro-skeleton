import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeleton/core/l10n/app_localizations.dart';
import 'package:skeleton/core/layout/window_class.dart';
import 'package:skeleton/core/theme/app_theme.dart';
import 'package:skeleton/core/theme/theme_x.dart';

import 'fonts.dart';
import 'surface_host.dart';

/// Loads the bundled Inter font so goldens do not draw with Ahem.
Future<void> loadGoldenFonts() => loadInterFont();

/// Device pixel ratio of every golden (0.5 px hairlines show as 1 physical px).
const double goldenPixelRatio = 2;

/// Registers one golden test per theme in [themes] for the widget of
/// [builder]. Files are `goldens/<name>_light.png` and `goldens/<name>_dark.png`
/// next to the test file. The tests carry the tag `golden` and fail with a
/// clear message when the host is not macOS (04 §12).
///
/// [prepare] runs after the first pump, for states that need input (hover,
/// press, focus) driven through a `TestGesture`.
void goldenTest(
  String name,
  WidgetBuilder builder, {
  Size size = const Size(800, 600),
  Set<Brightness> themes = const {Brightness.light, Brightness.dark},
  Future<void> Function(WidgetTester tester)? prepare,
}) {
  setUpAll(loadGoldenFonts);
  for (final brightness in Brightness.values) {
    if (!themes.contains(brightness)) continue;
    testWidgets(
      '$name golden ${brightness.name}',
      tags: ['golden'],
      (tester) async {
        if (!Platform.isMacOS) {
          fail('Golden tests run on macOS only (04 §12).');
        }
        tester.view
          ..devicePixelRatio = goldenPixelRatio
          ..physicalSize = size * goldenPixelRatio;
        addTearDown(tester.view.reset);
        final previous = debugDefaultTargetPlatformOverride;
        debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
        try {
          final theme = buildTheme(
            brightness,
            WindowClassX.fromWidth(size.width),
            InputMode.pointer,
          ).copyWith(platform: TargetPlatform.macOS);
          final boundary = GlobalKey();
          await tester.pumpWidget(
            MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: theme,
              darkTheme: theme,
              themeMode: brightness == Brightness.light
                  ? ThemeMode.light
                  : ThemeMode.dark,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: SurfaceHost(
                brightness: brightness,
                size: size,
                boundaryKey: boundary,
                child: Builder(builder: builder),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 400));
          if (prepare != null) {
            await prepare(tester);
            await tester.pump(const Duration(milliseconds: 400));
          }
          // `matchesGoldenFile(finder)` captures at pixel ratio 1.0, so the
          // image is taken here at [goldenPixelRatio] (2x logical size).
          final render =
              tester.renderObject(find.byKey(boundary))
                  as RenderRepaintBoundary;
          final image = (await tester.runAsync(
            () => render.toImage(pixelRatio: goldenPixelRatio),
          ))!;
          addTearDown(image.dispose);
          await expectLater(
            image,
            matchesGoldenFile('goldens/${name}_${brightness.name}.png'),
          );
        } finally {
          await tester.pumpWidget(const SizedBox.shrink());
          debugDefaultTargetPlatformOverride = previous;
        }
      },
    );
  }
}

/// One image per theme: [variants] laid out in a `Wrap` on the ground surface,
/// each under a caption.
void goldenGallery(
  String name, {
  required Map<String, Widget> variants,
  Size size = const Size(800, 600),
  Future<void> Function(WidgetTester tester)? prepare,
}) {
  goldenTest(
    name,
    (context) => DefaultTextStyle(
      // The host has no Material ancestor: give text the ink colour and no
      // debug underline.
      style: context.text.body.copyWith(
        color: context.surface.ink(12),
        decoration: TextDecoration.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final e in variants.entries)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.key,
                    style: context.text.meta.copyWith(
                      color: context.surface.ink(10),
                    ),
                  ),
                  const SizedBox(height: 4),
                  e.value,
                ],
              ),
          ],
        ),
      ),
    ),
    size: size,
    prepare: prepare,
  );
}
