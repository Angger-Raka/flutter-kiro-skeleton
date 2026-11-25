// Contrast gates of 04 §4.6, both themes. A failing gate stops the generator.
import 'color_math.dart';
import 'knobs.dart';
import 'palette.dart';

/// The outcome of one gate.
class GateResult {
  /// Creates a result.
  const GateResult({
    required this.theme,
    required this.name,
    required this.fg,
    required this.bg,
    required this.ratio,
    required this.minimum,
  });

  /// `light` or `dark`.
  final String theme;

  /// What is measured, for example `ink-12 on ink-1`.
  final String name;

  /// Foreground colour.
  final Rgb fg;

  /// Background colour.
  final Rgb bg;

  /// Measured WCAG ratio.
  final double ratio;

  /// Required minimum.
  final double minimum;

  /// Whether the ratio meets the minimum.
  bool get passed => ratio >= minimum;

  @override
  String toString() =>
      '${passed ? 'ok  ' : 'FAIL'} $theme $name: '
      '${ratio.toStringAsFixed(2)}:1 (min $minimum:1, '
      '${toHex(fg)} on ${toHex(bg)})';
}

/// Minimum for ink-10 on ink-1 when ink-10 carries meta text and labels.
const metaInk10Minimum = 4.5;

/// Minimum for ink-10 on ink-1 when it only carries icons and placeholders.
const iconInk10Minimum = 3.0;

/// Runs every gate for both palettes and returns all results.
///
/// [ink10Minimum] is [metaInk10Minimum] once faint text has been tuned (or
/// is used for meta text) and [iconInk10Minimum] otherwise.
List<GateResult> runContrastGates(
  Knobs knobs,
  PaletteData light,
  PaletteData dark, {
  double ink10Minimum = iconInk10Minimum,
}) {
  final results = <GateResult>[];

  void check(
    PaletteData p,
    String name,
    Rgb fg,
    Rgb bg,
    double minimum,
  ) {
    results.add(
      GateResult(
        theme: p.dark ? 'dark' : 'light',
        name: name,
        fg: fg,
        bg: bg,
        ratio: contrastRatio(fg, bg),
        minimum: minimum,
      ),
    );
  }

  for (final p in [light, dark]) {
    for (final n in [1, 2, 3]) {
      check(p, 'ink-12 on ink-$n', p.inkStep(12), p.inkStep(n), 7);
    }
    check(p, 'ink-11 on ink-3', p.inkStep(11), p.inkStep(3), 4.5);
    check(p, 'ink-10 on ink-1', p.inkStep(10), p.inkStep(1), ink10Minimum);
    check(p, 'ink-9 on ink-1', p.inkStep(9), p.inkStep(1), 3);
    for (final role in hueRoleNames) {
      final h = p.hues[role]!;
      check(p, 'hue-11 on hue-3 ($role)', h.s11, h.s3, 4.5);
    }
    check(p, 'ink-6 hairline vs surface top', p.inkStep(6), p.surfaceTop, 1.35);
    // Focus ring (ink-10): surface top and ink-3; dark also ink-1..4.
    check(p, 'focus ring on surface top', p.inkStep(10), p.surfaceTop, 3);
    check(p, 'focus ring on ink-3', p.inkStep(10), p.inkStep(3), 3);
    if (p.dark) {
      check(p, 'focus ring on ink-1', p.inkStep(10), p.inkStep(1), 3);
      check(p, 'focus ring on ink-2', p.inkStep(10), p.inkStep(2), 3);
      check(p, 'focus ring on ink-4', p.inkStep(10), p.inkStep(4), 3);
    }
    if (knobs.primary == 'accent') {
      check(p, 'accent primary text', p.primaryFg, p.primaryBg, 4.5);
    }
  }
  return results;
}

/// The failing results among [results].
List<GateResult> failures(List<GateResult> results) => [
  for (final r in results)
    if (!r.passed) r,
];
