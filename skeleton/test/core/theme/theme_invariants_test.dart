import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeleton/core/layout/window_class.dart';
import 'package:skeleton/core/theme/app_theme.dart';
import 'package:skeleton/core/theme/tactile/typography.dart';

/// Everything in a theme that is not a colour or a shadow.
List<Object?> metrics(ThemeData t) {
  List<Object?> style(TextStyle? s) => [
    s?.fontFamily,
    s?.fontWeight,
    s?.fontSize,
    s?.height,
    s?.letterSpacing,
    s?.leadingDistribution,
    s?.fontFeatures,
  ];

  final tt = t.textTheme;
  final type = t.extension<AppTypography>()!;
  final input = t.inputDecorationTheme;
  final err = input.errorBorder! as OutlineInputBorder;
  final base = input.border! as OutlineInputBorder;
  return [
    for (final s in [
      tt.displayLarge,
      tt.displayMedium,
      tt.displaySmall,
      tt.headlineLarge,
      tt.headlineMedium,
      tt.headlineSmall,
      tt.titleLarge,
      tt.titleMedium,
      tt.titleSmall,
      tt.bodyLarge,
      tt.bodyMedium,
      tt.bodySmall,
      tt.labelLarge,
      tt.labelMedium,
      tt.labelSmall,
      type.display,
      type.figure,
      type.section,
      type.title,
      type.body,
      type.description,
      type.meta,
      type.label,
      type.field,
      type.badge,
      t.tooltipTheme.textStyle,
    ])
      style(s),
    t.useMaterial3,
    input.filled,
    base.borderRadius,
    base.borderSide.width,
    err.borderRadius,
    err.borderSide.width,
    t.tooltipTheme.waitDuration,
    (t.tooltipTheme.decoration! as BoxDecoration).borderRadius,
    t.scrollbarTheme.thickness!.resolve({}),
    t.scrollbarTheme.radius,
    t.dividerTheme.thickness,
    t.pageTransitionsTheme,
    t.splashFactory,
  ];
}

void main() {
  for (final wc in WindowClass.values) {
    for (final mode in InputMode.values) {
      test(
        'property 14: light and dark differ only in colour ($wc, $mode)',
        () {
          final light = buildTheme(Brightness.light, wc, mode);
          final dark = buildTheme(Brightness.dark, wc, mode);
          expect(metrics(dark), metrics(light));
          // Sanity: the comparison is not vacuous, colours do differ.
          expect(dark.colorScheme.primary, isNot(light.colorScheme.primary));
          expect(dark.colorScheme.surface, isNot(light.colorScheme.surface));
        },
      );

      test(
        'rebuilding for another window class keeps brightness and colour',
        () {
          for (final b in Brightness.values) {
            final a = buildTheme(b, wc, mode);
            for (final other in WindowClass.values) {
              final c = buildTheme(b, other, mode);
              expect(c.brightness, b);
              expect(c.colorScheme, a.colorScheme);
            }
          }
        },
      );
    }
  }
}
