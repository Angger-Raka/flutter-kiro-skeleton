// Palette derivation (04 §4.2, §4.4) and its Dart rendering.
import '../radix/radix_scales.dart';
import 'color_math.dart';
import 'knobs.dart';

/// Hues whose step-9 solid takes the neutral's ink-12 as text (04 §4.3).
const _darkContrastHues = {'sky', 'mint', 'lime', 'yellow', 'amber'};

/// One hue scale: the steps the foundation uses plus the text on a solid.
class HueData {
  /// Creates hue data.
  const HueData({
    required this.s3,
    required this.s4,
    required this.s6,
    required this.s9,
    required this.s10,
    required this.s11,
    required this.s12,
    required this.contrast,
  });

  /// Tint fill.
  final Rgb s3;

  /// Tint hover.
  final Rgb s4;

  /// Edge on a tint.
  final Rgb s6;

  /// Solid.
  final Rgb s9;

  /// Solid hover.
  final Rgb s10;

  /// Text on a tint.
  final Rgb s11;

  /// High-contrast text.
  final Rgb s12;

  /// Text on a solid.
  final Rgb contrast;
}

/// One brightness of the palette.
class PaletteData {
  /// Creates palette data.
  const PaletteData({
    required this.dark,
    required this.ink,
    required this.alphaA3,
    required this.alphaA4,
    required this.scrim,
    required this.ground,
    required this.panel,
    required this.raised,
    required this.overlay,
    required this.well,
    required this.primaryBg,
    required this.primaryFg,
    required this.primaryHover,
    required this.hues,
  });

  /// True for the dark palette.
  final bool dark;

  /// Ink steps 1..12 (index 0 is step 1).
  final List<Rgb> ink;

  /// Ink alpha step 3, `#rrggbbaa`.
  final String alphaA3;

  /// Ink alpha step 4, `#rrggbbaa`.
  final String alphaA4;

  /// Scrim behind dialogs and sheets, `#rrggbbaa`: black at 30 % alpha in
  /// light and 90 % in dark.
  final String scrim;

  /// App ground.
  final Rgb ground;

  /// Panel surface.
  final Rgb panel;

  /// Raised surface (cards).
  final Rgb raised;

  /// Overlay surface (menus, modals).
  final Rgb overlay;

  /// Field well.
  final Rgb well;

  /// Primary fill.
  final Rgb primaryBg;

  /// Text on the primary fill.
  final Rgb primaryFg;

  /// Primary hover fill.
  final Rgb primaryHover;

  /// Hue scale per role name (see [hueRoleNames]).
  final Map<String, HueData> hues;

  /// Ink [step], 1-based.
  Rgb inkStep(int step) => ink[step - 1];

  /// The surface the top of the page sits on (gates measure against it).
  Rgb get surfaceTop => panel;
}

List<Rgb> _rgbs(List<String> hexes) => [for (final h in hexes) parseHex(h)];

/// The ink ramp of the neutral, unmodified, for [dark] or light.
List<Rgb> baseInk(Knobs knobs, {required bool dark}) {
  final scale = radixScales[knobs.neutral]!;
  return _rgbs(dark ? scale.dark : scale.light);
}

HueData _hue(String name, List<Rgb> ink, {required bool dark, Rgb? s11}) {
  final scale = radixScales[name]!;
  final steps = _rgbs(dark ? scale.dark : scale.light);
  return HueData(
    s3: steps[2],
    s4: steps[3],
    s6: steps[5],
    s9: steps[8],
    s10: steps[9],
    s11: s11 ?? steps[10],
    s12: steps[11],
    contrast: _darkContrastHues.contains(name)
        ? ink[11]
        : const Rgb(255, 255, 255),
  );
}

/// Builds one brightness of the palette from [knobs] and the (possibly
/// tuned) [ink] ramp.
PaletteData buildPalette(
  Knobs knobs, {
  required bool dark,
  required List<Rgb> ink,
  Map<String, Rgb> hue11 = const {},
}) {
  final scale = radixScales[knobs.neutral]!;
  final alpha = dark ? scale.darkAlpha : scale.lightAlpha;
  final top = parseHex(knobs.surfaceTop);

  // Dark ground: ink-1 with OKLCH lightness -0.04, same hue and chroma.
  final lch = rgbToOkLch(ink[0]);
  final darkGround = okLchToRgb(OkLch(lch.l - 0.04, lch.c, lch.h));

  final hues = {
    for (final role in hueRoleNames)
      role: _hue(knobs.hues[role]!, ink, dark: dark, s11: hue11[role]),
  };

  final Rgb primaryBg;
  final Rgb primaryFg;
  final Rgb primaryHover;
  if (knobs.primary == 'accent') {
    final accent = hues['accent']!;
    primaryBg = accent.s9;
    primaryFg = accent.contrast;
    primaryHover = accent.s10;
  } else {
    primaryBg = ink[11];
    primaryFg = ink[0];
    primaryHover = mixOkLab(primaryBg, primaryFg, 0.07);
  }

  return PaletteData(
    dark: dark,
    ink: ink,
    alphaA3: alpha['a3']!,
    alphaA4: alpha['a4']!,
    scrim: dark ? '#000000e6' : '#0000004d',
    ground: dark ? darkGround : ink[1],
    panel: dark ? ink[0] : top,
    raised: dark ? ink[1] : top,
    overlay: dark ? ink[1] : top,
    well: ink[2],
    primaryBg: primaryBg,
    primaryFg: primaryFg,
    primaryHover: primaryHover,
    hues: hues,
  );
}

/// `Color(0xFFrrggbb)` for [c].
String colorLiteral(Rgb c) {
  final hex = toHex(c).substring(1).toUpperCase();
  return 'Color(0xFF$hex)';
}

/// `Color(0xAArrggbb)` for a `#rrggbbaa` string.
String alphaColorLiteral(String hex8) {
  final h = hex8.substring(1).toUpperCase();
  return 'Color(0x${h.substring(6)}${h.substring(0, 6)})';
}

String _hueLiteral(HueData h) =>
    'HueScale(s3: ${colorLiteral(h.s3)}, s4: ${colorLiteral(h.s4)}, '
    's6: ${colorLiteral(h.s6)}, s9: ${colorLiteral(h.s9)}, '
    's10: ${colorLiteral(h.s10)}, s11: ${colorLiteral(h.s11)}, '
    's12: ${colorLiteral(h.s12)}, contrast: ${colorLiteral(h.contrast)})';

String _paletteLiteral(PaletteData p) {
  final b = StringBuffer()
    ..writeln('AppPalette(')
    ..writeln('ink: [${p.ink.map(colorLiteral).join(', ')}],')
    ..writeln('alphaA3: ${alphaColorLiteral(p.alphaA3)},')
    ..writeln('alphaA4: ${alphaColorLiteral(p.alphaA4)},')
    ..writeln('scrim: ${alphaColorLiteral(p.scrim)},')
    ..writeln('ground: ${colorLiteral(p.ground)},')
    ..writeln('panel: ${colorLiteral(p.panel)},')
    ..writeln('raised: ${colorLiteral(p.raised)},')
    ..writeln('overlay: ${colorLiteral(p.overlay)},')
    ..writeln('well: ${colorLiteral(p.well)},')
    ..writeln('primaryBg: ${colorLiteral(p.primaryBg)},')
    ..writeln('primaryFg: ${colorLiteral(p.primaryFg)},')
    ..writeln('primaryHover: ${colorLiteral(p.primaryHover)},')
    ..writeln('hues: {');
  for (final role in hueRoleNames) {
    b.writeln('HueRole.$role: ${_hueLiteral(p.hues[role]!)},');
  }
  b
    ..writeln('},')
    ..writeln('identity: <HueScale>[],')
    ..write(')');
  return b.toString();
}

/// Dart source for the colour classes and both palettes.
String renderPalette(PaletteData light, PaletteData dark) =>
    '''
/// One brightness-specific ink ramp, surface fills, and hue scales.
class AppPalette {
  /// Creates a palette.
  const AppPalette({
    required this.ink,
    required this.alphaA3,
    required this.alphaA4,
    required this.scrim,
    required this.ground,
    required this.panel,
    required this.raised,
    required this.overlay,
    required this.well,
    required this.primaryBg,
    required this.primaryFg,
    required this.primaryHover,
    required this.hues,
    required this.identity,
  });

  /// Ink steps 1..12 (index 0 is step 1).
  final List<Color> ink;

  /// Ink alpha step 3.
  final Color alphaA3;

  /// Ink alpha step 4.
  final Color alphaA4;

  /// Scrim behind dialogs and sheets.
  final Color scrim;

  /// App ground.
  final Color ground;

  /// Panel surface.
  final Color panel;

  /// Raised surface.
  final Color raised;

  /// Overlay surface.
  final Color overlay;

  /// Field well.
  final Color well;

  /// Primary fill.
  final Color primaryBg;

  /// Text on the primary fill.
  final Color primaryFg;

  /// Primary hover fill.
  final Color primaryHover;

  /// Hue scale per role.
  final Map<HueRole, HueScale> hues;

  /// Identity hue scales (empty in Phase 1).
  final List<HueScale> identity;

  /// Ink [step], 1-based.
  Color inkStep(int step) => ink[step - 1];

  /// Light palette.
  static const AppPalette light = ${_paletteLiteral(light)};

  /// Dark palette.
  static const AppPalette dark = ${_paletteLiteral(dark)};
}

/// The steps of one hue the system uses.
class HueScale {
  /// Creates a hue scale.
  const HueScale({
    required this.s3,
    required this.s4,
    required this.s6,
    required this.s9,
    required this.s10,
    required this.s11,
    required this.s12,
    required this.contrast,
  });

  /// Tint fill.
  final Color s3;

  /// Tint hover.
  final Color s4;

  /// Edge on a tint.
  final Color s6;

  /// Solid.
  final Color s9;

  /// Solid hover.
  final Color s10;

  /// Text on a tint.
  final Color s11;

  /// High-contrast text.
  final Color s12;

  /// Text on a solid.
  final Color contrast;
}

/// Roles a hue can play.
enum HueRole {
  /// The brand hue.
  accent,

  /// Success and live.
  success,

  /// Failure and destructive.
  danger,

  /// Caution.
  warning,

  /// Information.
  info,
}
''';
