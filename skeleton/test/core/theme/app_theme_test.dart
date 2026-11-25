import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeleton/core/layout/window_class.dart';
import 'package:skeleton/core/theme/app_theme.dart';
import 'package:skeleton/core/theme/tactile/page_transition.dart';
import 'package:skeleton/core/theme/tactile/typography.dart';
import 'package:skeleton/core/theme/tokens.g.dart';

void main() {
  for (final b in Brightness.values) {
    final p = b == Brightness.light ? AppPalette.light : AppPalette.dark;
    final theme = buildTheme(b, WindowClass.desktop, InputMode.pointer);
    final danger = p.hues[HueRole.danger]!;
    final accent = p.hues[HueRole.accent]!;

    group('buildTheme $b', () {
      test('ColorScheme follows 04 §9', () {
        final c = theme.colorScheme;
        expect(c.brightness, b);
        expect(c.primary, p.inkStep(12));
        expect(c.onPrimary, p.inkStep(1));
        expect(c.surface, p.panel);
        expect(c.onSurface, p.inkStep(12));
        expect(c.onSurfaceVariant, p.inkStep(11));
        expect(c.outline, p.inkStep(7));
        expect(c.outlineVariant, p.inkStep(6));
        expect(c.surfaceContainerLowest, p.inkStep(1));
        expect(c.surfaceContainerLow, p.inkStep(2));
        expect(c.surfaceContainer, p.inkStep(3));
        expect(c.surfaceContainerHigh, p.inkStep(4));
        expect(c.surfaceContainerHighest, p.inkStep(5));
        expect(c.error, danger.s9);
        expect(c.onError, danger.contrast);
        expect(c.errorContainer, danger.s3);
        expect(c.onErrorContainer, danger.s11);
        expect(c.secondary, accent.s9);
        expect(c.tertiary, accent.s9);
      });

      test('no splash or highlight, tactile page transitions', () {
        expect(theme.splashFactory, NoSplash.splashFactory);
        expect(theme.highlightColor, const Color(0x00000000));
        expect(theme.hoverColor, const Color(0x00000000));
        expect(theme.pageTransitionsTheme, tactilePageTransitionsTheme);
      });

      test('typography extension is present', () {
        final type = theme.extension<AppTypography>();
        expect(type, isNotNull);
        expect(theme.textTheme.bodyMedium!.fontSize, type!.body.fontSize);
        expect(theme.textTheme.bodyMedium!.color, p.inkStep(12));
        expect(theme.textTheme.bodySmall!.color, p.inkStep(10));
      });

      test('component themes', () {
        expect(theme.inputDecorationTheme.filled, isTrue);
        final fill = theme.inputDecorationTheme.fillColor!;
        expect(
          WidgetStateProperty.resolveAs<Color?>(fill, {WidgetState.focused}),
          p.inkStep(4),
        );
        expect(
          WidgetStateProperty.resolveAs<Color?>(fill, <WidgetState>{}),
          p.inkStep(3),
        );
        expect(theme.tooltipTheme.waitDuration, Duration.zero);
        expect(theme.dividerTheme.thickness, AppStroke.hairline);
        expect(theme.dividerTheme.color, p.inkStep(6));
        expect(theme.textSelectionTheme.selectionColor, accent.s4);
        expect(theme.progressIndicatorTheme.color, p.inkStep(12));
        expect(theme.progressIndicatorTheme.linearTrackColor, p.inkStep(4));
      });
    });
  }

  test('scrollbar is hidden on touch and 8 px on pointer', () {
    final pointer = buildTheme(
      Brightness.light,
      WindowClass.desktop,
      InputMode.pointer,
    );
    final touch = buildTheme(
      Brightness.light,
      WindowClass.mobile,
      InputMode.touch,
    );
    expect(pointer.scrollbarTheme.thickness!.resolve({}), AppSpace.s8);
    expect(touch.scrollbarTheme.thickness!.resolve({}), 0);
  });
}
