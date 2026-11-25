import 'package:flutter/material.dart';
import 'package:skeleton/core/layout/window_class.dart';
import 'package:skeleton/core/theme/tactile/page_transition.dart';
import 'package:skeleton/core/theme/tactile/typography.dart';
import 'package:skeleton/core/theme/tokens.g.dart';

/// Tactile [ThemeData] for Material widgets that stay in use (04 §9).
///
/// Colours come from [AppPalette]; sizes, radii, and strokes do not depend on
/// [brightness], so light and dark differ only in colour. Rebuilt when the
/// window class or input mode changes.
ThemeData buildTheme(
  Brightness brightness,
  WindowClass windowClass,
  InputMode inputMode,
) {
  final p = brightness == Brightness.light ? AppPalette.light : AppPalette.dark;
  final type = AppTypography.build(windowClass, inputMode);
  final accent = p.hues[HueRole.accent]!;
  final danger = p.hues[HueRole.danger]!;
  const clear = Color(0x00000000);

  TextStyle ink(TextStyle style, int step) =>
      style.copyWith(color: p.inkStep(step));
  const strong = AppTypographyInk.strong;

  final display = ink(type.display, strong);
  final section = ink(type.section, strong);
  final body = ink(type.body, strong);
  final meta = ink(type.meta, AppTypographyInk.meta);
  final label = ink(type.label, strong);

  // Error ring: 1 px danger-11 (04 §7); BorderSide's default width is 1.
  OutlineInputBorder border(BorderSide side) =>
      OutlineInputBorder(borderRadius: AppRadius.controlAll, borderSide: side);
  final noBorder = border(BorderSide.none);
  final errorBorder = border(BorderSide(color: danger.s11));

  final scrollbarVisible = inputMode == InputMode.pointer;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: type.body.fontFamily,
    splashFactory: NoSplash.splashFactory,
    splashColor: clear,
    highlightColor: clear,
    hoverColor: clear,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: p.inkStep(12),
      onPrimary: p.inkStep(1),
      secondary: accent.s9,
      onSecondary: accent.contrast,
      tertiary: accent.s9,
      onTertiary: accent.contrast,
      error: danger.s9,
      onError: danger.contrast,
      errorContainer: danger.s3,
      onErrorContainer: danger.s11,
      surface: p.panel,
      onSurface: p.inkStep(12),
      onSurfaceVariant: p.inkStep(11),
      outline: p.inkStep(7),
      outlineVariant: p.inkStep(6),
      surfaceContainerLowest: p.inkStep(1),
      surfaceContainerLow: p.inkStep(2),
      surfaceContainer: p.inkStep(3),
      surfaceContainerHigh: p.inkStep(4),
      surfaceContainerHighest: p.inkStep(5),
    ),
    textTheme: TextTheme(
      displayLarge: display,
      displayMedium: display,
      displaySmall: display,
      headlineLarge: display,
      headlineMedium: section,
      headlineSmall: ink(type.figure, strong),
      titleLarge: section,
      titleMedium: ink(type.title, strong),
      titleSmall: body,
      bodyLarge: body,
      bodyMedium: body,
      bodySmall: meta,
      labelLarge: label,
      labelMedium: label,
      labelSmall: meta,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: WidgetStateColor.resolveWith(
        (states) =>
            states.contains(WidgetState.focused) ? p.inkStep(4) : p.inkStep(3),
      ),
      border: noBorder,
      enabledBorder: noBorder,
      disabledBorder: noBorder,
      focusedBorder: noBorder,
      errorBorder: errorBorder,
      focusedErrorBorder: errorBorder,
    ),
    tooltipTheme: TooltipThemeData(
      waitDuration: Duration.zero,
      decoration: BoxDecoration(
        color: p.inkStep(12),
        borderRadius: AppRadius.controlAll,
      ),
      textStyle: type.meta.copyWith(color: p.inkStep(1)),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thickness: WidgetStatePropertyAll(scrollbarVisible ? AppSpace.s8 : 0),
      thumbColor: WidgetStatePropertyAll(
        scrollbarVisible ? p.inkStep(6) : clear,
      ),
      radius: AppRadius.full,
    ),
    dividerTheme: DividerThemeData(
      color: p.inkStep(6),
      thickness: AppStroke.hairline,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: p.inkStep(12),
      selectionColor: accent.s4,
      selectionHandleColor: p.inkStep(12),
    ),
    pageTransitionsTheme: tactilePageTransitionsTheme,
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: p.inkStep(12),
      linearTrackColor: p.inkStep(4),
      circularTrackColor: p.inkStep(4),
    ),
    extensions: [type],
  );
}
