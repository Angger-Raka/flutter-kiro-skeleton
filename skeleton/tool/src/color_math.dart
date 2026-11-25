// Colour maths for the token generator. Pure Dart, no Flutter imports.
// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes
import 'dart:math' as math;

/// An opaque sRGB colour with channels 0..255.
class Rgb {
  /// Creates a colour from 8-bit channels.
  const Rgb(this.r, this.g, this.b);

  /// Red, 0..255.
  final int r;

  /// Green, 0..255.
  final int g;

  /// Blue, 0..255.
  final int b;

  @override
  bool operator ==(Object other) =>
      other is Rgb && other.r == r && other.g == g && other.b == b;

  @override
  int get hashCode => Object.hash(r, g, b);

  @override
  String toString() => toHex(this);
}

/// OKLab colour: lightness [l], green-red [a], blue-yellow [b].
class OkLab {
  /// Creates an OKLab colour.
  const OkLab(this.l, this.a, this.b);

  /// Lightness, about 0..1.
  final double l;

  /// Green-red axis.
  final double a;

  /// Blue-yellow axis.
  final double b;
}

/// OKLCH colour: lightness [l], chroma [c], hue [h] in degrees.
class OkLch {
  /// Creates an OKLCH colour.
  const OkLch(this.l, this.c, this.h);

  /// Lightness, about 0..1.
  final double l;

  /// Chroma, 0 and up.
  final double c;

  /// Hue in degrees, 0..360.
  final double h;
}

/// Parses `#rrggbb` (a trailing alpha pair, `#rrggbbaa`, is ignored).
Rgb parseHex(String hex) {
  final m = RegExp(r'^#([0-9a-fA-F]{6})([0-9a-fA-F]{2})?$').firstMatch(hex);
  if (m == null) throw FormatException('Invalid hex colour', hex);
  final v = int.parse(m.group(1)!, radix: 16);
  return Rgb((v >> 16) & 0xff, (v >> 8) & 0xff, v & 0xff);
}

/// Formats [c] as lower-case `#rrggbb`.
String toHex(Rgb c) {
  String h(int v) => v.toRadixString(16).padLeft(2, '0');
  return '#${h(c.r)}${h(c.g)}${h(c.b)}';
}

double _toLinear(int channel) {
  final c = channel / 255;
  return c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4) * 1.0;
}

int _fromLinear(double lin) {
  final c = lin <= 0.0031308
      ? lin * 12.92
      : 1.055 * math.pow(lin, 1 / 2.4) - 0.055;
  return (c * 255).round().clamp(0, 255);
}

/// sRGB to OKLab (Björn Ottosson's reference matrices).
OkLab rgbToOkLab(Rgb c) {
  final r = _toLinear(c.r);
  final g = _toLinear(c.g);
  final b = _toLinear(c.b);
  final l = math.pow(
    0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b,
    1 / 3,
  );
  final m = math.pow(
    0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b,
    1 / 3,
  );
  final s = math.pow(
    0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b,
    1 / 3,
  );
  return OkLab(
    0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
    1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
    0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s,
  );
}

/// OKLab to sRGB, rounded and clamped to the gamut.
Rgb okLabToRgb(OkLab c) {
  final l = math.pow(c.l + 0.3963377774 * c.a + 0.2158037573 * c.b, 3);
  final m = math.pow(c.l - 0.1055613458 * c.a - 0.0638541728 * c.b, 3);
  final s = math.pow(c.l - 0.0894841775 * c.a - 1.2914855480 * c.b, 3);
  return Rgb(
    _fromLinear(4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s),
    _fromLinear(-1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s),
    _fromLinear(-0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s),
  );
}

/// OKLab to OKLCH.
OkLch okLabToLch(OkLab c) {
  final h = math.atan2(c.b, c.a) * 180 / math.pi;
  return OkLch(c.l, math.sqrt(c.a * c.a + c.b * c.b), h < 0 ? h + 360 : h);
}

/// OKLCH to OKLab.
OkLab okLchToLab(OkLch c) {
  final rad = c.h * math.pi / 180;
  return OkLab(c.l, c.c * math.cos(rad), c.c * math.sin(rad));
}

/// sRGB to OKLCH.
OkLch rgbToOkLch(Rgb c) => okLabToLch(rgbToOkLab(c));

/// OKLCH to sRGB.
Rgb okLchToRgb(OkLch c) => okLabToRgb(okLchToLab(c));

/// Mixes [a] and [b] in OKLab. [t] is the share of [b]: 0 gives [a], 1 gives
/// [b].
Rgb mixOkLab(Rgb a, Rgb b, double t) {
  final x = rgbToOkLab(a);
  final y = rgbToOkLab(b);
  if (t <= 0) return a;
  if (t >= 1) return b;
  return okLabToRgb(
    OkLab(
      x.l + (y.l - x.l) * t,
      x.a + (y.a - x.a) * t,
      x.b + (y.b - x.b) * t,
    ),
  );
}

/// WCAG 2.x relative luminance.
double relativeLuminance(Rgb c) =>
    0.2126 * _toLinear(c.r) + 0.7152 * _toLinear(c.g) + 0.0722 * _toLinear(c.b);

/// WCAG 2.x contrast ratio between [a] and [b] (1..21, order independent).
double contrastRatio(Rgb a, Rgb b) {
  final la = relativeLuminance(a);
  final lb = relativeLuminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}
