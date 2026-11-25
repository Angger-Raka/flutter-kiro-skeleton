// Converts CSS shadow recipes to Flutter BoxShadow source and renders
// AppShadows.
import 'package:skeleton/core/theme/tactile/blur_conversion.dart';

import 'palette.dart';
import 'shadow_recipes.dart';

String _n(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : '$v';

String _color(ShadowColor c) {
  final a = (c.alpha * 255).round().toRadixString(16).padLeft(2, '0');
  final rgb = colorLiteralHex(c);
  return 'Color(0x${a.toUpperCase()}$rgb)';
}

/// `RRGGBB` of a shadow colour.
String colorLiteralHex(ShadowColor c) => [
  c.rgb.r,
  c.rgb.g,
  c.rgb.b,
].map((v) => v.toRadixString(16).padLeft(2, '0').toUpperCase()).join();

/// One layer as a `BoxShadow(...)` source expression. Offsets and spread are
/// unchanged; only the blur is converted. A zero blur stays 0 (a ring).
String boxShadowSource(CssShadow s) =>
    'BoxShadow(offset: Offset(${_n(s.dx)}, ${_n(s.dy)}), '
    'blurRadius: ${_n(cssBlurToFlutter(s.blur))}, '
    'spreadRadius: ${_n(s.spread)}, color: ${_color(s.color)})';

/// A recipe as a const Flutter list. CSS paints the first layer on top and
/// Flutter paints the first at the bottom, so the order is reversed.
String shadowListSource(List<CssShadow> recipe) =>
    '<BoxShadow>[${recipe.reversed.map(boxShadowSource).join(', ')}]';

String _shadowsLiteral(PaletteData p) {
  final recipes = shadowRecipes(p);
  final fields = [
    for (final t in shadowTokens) '$t: ${shadowListSource(recipes[t]!)},',
  ];
  return 'AppShadows(\n${fields.join('\n')}\n)';
}

/// Dart source for `AppShadows`.
String renderShadows(PaletteData light, PaletteData dark) =>
    '''
/// Shadow recipes resolved to BoxShadow lists, per brightness.
class AppShadows {
  /// Creates a shadow set.
  const AppShadows({
${[for (final t in shadowTokens) 'required this.$t,'].join('\n')}
  });

${[for (final t in shadowTokens) 'final List<BoxShadow> $t;'].join('\n')}

  /// Light shadows.
  static const AppShadows light = ${_shadowsLiteral(light)};

  /// Dark shadows.
  static const AppShadows dark = ${_shadowsLiteral(dark)};
}
''';
