// Shadow recipes of 04 §4.5 / tactile-design tokens.md §6, as CSS-notation
// data: (x, y, blur, spread, colour). Conversion to Flutter happens in
// shadows.dart.
import 'color_math.dart';
import 'palette.dart';

/// A colour with an alpha, as a CSS `rgb(r g b / a)`.
class ShadowColor {
  /// Creates a shadow colour. [alpha] is 0..1.
  const ShadowColor(this.rgb, [this.alpha = 1]);

  /// The opaque colour.
  final Rgb rgb;

  /// Opacity, 0..1.
  final double alpha;
}

/// One CSS `box-shadow` layer.
class CssShadow {
  /// Creates a layer.
  const CssShadow(this.dx, this.dy, this.blur, this.spread, this.color);

  /// Horizontal offset.
  final double dx;

  /// Vertical offset.
  final double dy;

  /// CSS blur (not yet converted).
  final double blur;

  /// Spread.
  final double spread;

  /// Colour.
  final ShadowColor color;
}

/// Token names, in emitted order.
const shadowTokens = [
  'button',
  'primary',
  'toggle',
  'card',
  'table',
  'panel',
  'menu',
  'popover',
  'modal',
  'badge',
];

const _black = Rgb(0, 0, 0);

/// The recipes for one brightness, in CSS order (first layer paints on top).
///
/// shortcut: dark `button`/`toggle` use the panel outline (ink-6); on a
/// raised surface the outline is ink-7, which `shadows.dart` (SurfaceScope)
/// swaps in. `badge` is the neutral badge (hue-11 = ink-11); coloured badges
/// are derived from their own hue-11 at the widget, when badges exist.
Map<String, List<CssShadow>> shadowRecipes(PaletteData p) {
  final dark = p.dark;
  // Light shadows use the neutral's ink-12; dark ones stay black.
  final ink = p.inkStep(12);
  ShadowColor drop(double lightAlpha, [double? darkAlpha]) => dark
      ? ShadowColor(_black, darkAlpha ?? .5)
      : ShadowColor(ink, lightAlpha);

  List<CssShadow> button() => dark
      ? [
          CssShadow(0, 0, 0, .5, ShadowColor(p.inkStep(6))),
          CssShadow(0, 1, 2, 0, drop(0)),
        ]
      : [
          CssShadow(0, 1, 2, 0, drop(.12)),
          CssShadow(0, 0, 0, 1, ShadowColor(ink, .08)),
        ];

  List<CssShadow> menu() => dark
      ? [
          CssShadow(0, 0, 0, .5, ShadowColor(p.inkStep(7))),
          CssShadow(0, 1, 2, 0, drop(0)),
          CssShadow(0, 4, 8, -4, drop(0)),
        ]
      : [
          CssShadow(0, 0, 0, 1, ShadowColor(ink, .08)),
          CssShadow(0, 1, 2, 0, drop(.12)),
          CssShadow(0, 4, 8, -4, drop(.16)),
        ];

  final badgeText = p.inkStep(11);
  return {
    'button': button(),
    'primary': dark
        ? [
            CssShadow(0, 0, 0, .5, ShadowColor(p.primaryBg)),
            CssShadow(0, 1, 2, 0, drop(0)),
          ]
        : [CssShadow(0, 0, 0, 1, ShadowColor(p.panel))],
    'toggle': button(),
    'card': dark
        ? [
            CssShadow(0, 0, 0, .5, ShadowColor(p.inkStep(6))),
            CssShadow(0, 1, 2, 0, drop(0)),
            CssShadow(0, 3, 4, -2, drop(0, .4)),
          ]
        : [
            CssShadow(0, 0, 0, 1, ShadowColor(ink, .07)),
            CssShadow(0, 1, 2, 0, drop(.12)),
            CssShadow(0, 3, 4, -2, drop(.08)),
          ],
    'table': [CssShadow(0, 1, 2, 0, drop(.12))],
    'panel': dark
        ? [
            CssShadow(0, 0, 0, .5, _alphaOf(p.alphaA3)),
            CssShadow(0, 1, 2, 0, drop(0)),
            CssShadow(0, 3, 4, -2, drop(0, .4)),
          ]
        : [
            CssShadow(0, 0, 0, .5, _alphaOf(p.alphaA4)),
            CssShadow(0, 1, 2, 0, drop(.015)),
            CssShadow(0, 3, 4, -2, drop(.025)),
          ],
    'menu': menu(),
    'popover': menu(),
    'modal': dark
        ? [
            CssShadow(0, 0, 0, .5, ShadowColor(p.inkStep(7))),
            CssShadow(0, 1, 2, 0, drop(0)),
            CssShadow(0, 6, 8, -4, drop(0)),
          ]
        : [
            CssShadow(0, 0, 0, 1, ShadowColor(ink, .07)),
            CssShadow(0, 1, 2, 0, drop(.14)),
            CssShadow(0, 6, 8, -4, drop(.14)),
          ],
    'badge': dark
        ? [
            // color-mix(currentColor 34%, #000): text colour into black.
            CssShadow(0, 0, 0, .5, ShadowColor(mixIntoBlack34(badgeText))),
            CssShadow(0, 1, 2, 0, drop(0)),
          ]
        : [
            CssShadow(0, 1, 2, 0, ShadowColor(badgeText, .16)),
            CssShadow(0, 0, 0, 1, ShadowColor(badgeText, .14)),
          ],
  };
}

/// 34% of [c] mixed into black, per sRGB channel.
Rgb mixIntoBlack34(Rgb c) =>
    Rgb((c.r * .34).round(), (c.g * .34).round(), (c.b * .34).round());

/// Splits a `#rrggbbaa` string into a [ShadowColor].
ShadowColor _alphaOf(String hex8) {
  final a = int.parse(hex8.substring(7, 9), radix: 16) / 255;
  return ShadowColor(parseHex(hex8), a);
}
