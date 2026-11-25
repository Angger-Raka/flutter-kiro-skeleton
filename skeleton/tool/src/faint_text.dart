// tune_faint_text: moves only the OKLCH lightness of ink-9, ink-10, and (for
// hues that fail their gate) hue-11, keeping hue and chroma, until the
// contrast gate passes. Every adjustment is reported.
import 'color_math.dart';
import 'contrast_gates.dart';
import 'knobs.dart';
import 'palette.dart';

/// One lightness adjustment.
class Adjustment {
  /// Creates an adjustment.
  const Adjustment({
    required this.theme,
    required this.name,
    required this.before,
    required this.after,
    required this.rgbBefore,
    required this.rgbAfter,
  });

  /// `light` or `dark`.
  final String theme;

  /// What moved, for example `ink-10` or `hue-11 (success)`.
  final String name;

  /// OKLCH before (unquantised).
  final OkLch before;

  /// OKLCH after (unquantised): same hue and chroma, new lightness.
  final OkLch after;

  /// sRGB before.
  final Rgb rgbBefore;

  /// sRGB after (quantised to 8 bits, what is emitted).
  final Rgb rgbAfter;

  @override
  String toString() =>
      'tune $theme $name: ${toHex(rgbBefore)} -> ${toHex(rgbAfter)} '
      '(OKLCH L ${before.l.toStringAsFixed(4)} -> '
      '${after.l.toStringAsFixed(4)}, hue and chroma unchanged)';
}

/// Moves [start]'s OKLCH lightness (hue and chroma fixed) in the direction
/// that raises contrast with the background ([darker] true lowers L) until
/// [passes] holds for the 8-bit colour. Returns null if it never passes.
Adjustment? tuneLightness({
  required String theme,
  required String name,
  required Rgb start,
  required bool darker,
  required bool Function(Rgb) passes,
}) {
  if (passes(start)) return null;
  final lch = rgbToOkLch(start);
  const step = 0.0005;
  for (var i = 1; i <= 2000; i++) {
    final l = lch.l + (darker ? -step : step) * i;
    if (l < 0 || l > 1) return null;
    final after = OkLch(l, lch.c, lch.h);
    final rgb = okLchToRgb(after);
    if (passes(rgb)) {
      return Adjustment(
        theme: theme,
        name: name,
        before: lch,
        after: after,
        rgbBefore: start,
        rgbAfter: rgb,
      );
    }
  }
  return null;
}

/// The result of tuning both themes.
class Tuned {
  /// Creates a result.
  const Tuned(this.lightInk, this.darkInk, this.hue11, this.adjustments);

  /// Light ink ramp after tuning.
  final List<Rgb> lightInk;

  /// Dark ink ramp after tuning.
  final List<Rgb> darkInk;

  /// Tuned hue-11 per theme and role: `light:success` and so on.
  final Map<String, Rgb> hue11;

  /// Every adjustment made, in order.
  final List<Adjustment> adjustments;

  /// Hue-11 overrides for the [dark] palette.
  Map<String, Rgb> hue11For({required bool dark}) {
    final prefix = dark ? 'dark:' : 'light:';
    return {
      for (final e in hue11.entries)
        if (e.key.startsWith(prefix)) e.key.substring(prefix.length): e.value,
    };
  }
}

/// Tunes ink-9, ink-10, and failing hue-11 steps for both themes.
Tuned tuneFaintText(Knobs knobs) {
  final adjustments = <Adjustment>[];
  final inks = <bool, List<Rgb>>{};
  for (final dark in [false, true]) {
    final theme = dark ? 'dark' : 'light';
    final ink = [...baseInk(knobs, dark: dark)];
    final bg1 = ink[0];
    // ink-9 (3:1) first, then ink-10 (4.5:1), both on ink-1.
    for (final (step, minimum) in [(9, 3.0), (10, metaInk10Minimum)]) {
      final a = tuneLightness(
        theme: theme,
        name: 'ink-$step',
        start: ink[step - 1],
        darker: !dark,
        passes: (c) => contrastRatio(c, bg1) >= minimum,
      );
      if (a != null) {
        ink[step - 1] = a.rgbAfter;
        adjustments.add(a);
      }
    }
    inks[dark] = ink;
  }

  final hue11 = <String, Rgb>{};
  for (final dark in [false, true]) {
    final theme = dark ? 'dark' : 'light';
    final p = buildPalette(knobs, dark: dark, ink: inks[dark]!);
    for (final role in hueRoleNames) {
      final h = p.hues[role]!;
      final a = tuneLightness(
        theme: theme,
        name: 'hue-11 ($role)',
        start: h.s11,
        darker: !dark,
        passes: (c) => contrastRatio(c, h.s3) >= 4.5,
      );
      if (a != null) {
        hue11['$theme:$role'] = a.rgbAfter;
        adjustments.add(a);
      }
    }
  }
  return Tuned(inks[false]!, inks[true]!, hue11, adjustments);
}
