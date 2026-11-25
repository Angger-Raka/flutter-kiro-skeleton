import 'package:flutter/material.dart';
import 'package:skeleton/core/theme/tactile/blur_conversion.dart';
import 'package:skeleton/core/theme/tactile/surface.dart';
import 'package:skeleton/core/theme/tokens.g.dart';

/// A shadow in CSS notation (x, y, blur, spread, colour), 04 §4.5.
/// Offsets and spread carry over; blur goes through [cssBlurToFlutter].
@immutable
class ShadowRecipe {
  /// Creates a recipe.
  const ShadowRecipe({
    required this.dx,
    required this.dy,
    required this.cssBlur,
    required this.spread,
    required this.color,
  });

  /// Horizontal offset.
  final double dx;

  /// Vertical offset.
  final double dy;

  /// CSS blur (twice the Gaussian sigma).
  final double cssBlur;

  /// Spread radius.
  final double spread;

  /// Shadow colour.
  final Color color;

  /// Flutter shadow with the converted blur.
  BoxShadow toBoxShadow() => BoxShadow(
    offset: Offset(dx, dy),
    blurRadius: cssBlurToFlutter(cssBlur),
    spreadRadius: spread,
    color: color,
  );
}

/// Per-surface, per-brightness choice of shadow lists from [AppShadows].
abstract final class SurfaceShadows {
  /// Dark edge share of the badge hue mixed into black (04 §4.4).
  static const double _darkBadgeEdge = 0.34;

  /// Control shadows (button, toggle, card) on [scope]. Light shadows are the
  /// same everywhere. In dark, the 0.5 px outline is the panel's ink 6; other
  /// surfaces redeclare it as their own `line` (ink 7 on raised and up).
  static List<BoxShadow> control(List<BoxShadow> base, SurfaceScope scope) {
    if (scope.brightness == Brightness.light) return base;
    final from = scope.palette.inkStep(6);
    final to = scope.line;
    if (from == to) return base;
    return [
      for (final s in base)
        s.color == from && s.spreadRadius > 0 && s.blurRadius == 0
            ? BoxShadow(
                spreadRadius: s.spreadRadius,
                color: to,
              )
            : s,
    ];
  }

  /// Badge shadows tinted by [hue]'s step 11: light keeps each alpha and swaps
  /// the colour; dark draws the edge as 34 % of the hue mixed into black.
  static List<BoxShadow> badge(
    List<BoxShadow> neutral,
    SurfaceScope scope,
    HueScale hue,
  ) {
    final light = scope.brightness == Brightness.light;
    final edge = Color.lerp(const Color(0xFF000000), hue.s11, _darkBadgeEdge)!;
    return [
      for (final s in neutral)
        if (light)
          BoxShadow(
            offset: s.offset,
            blurRadius: s.blurRadius,
            spreadRadius: s.spreadRadius,
            color: hue.s11.withAlpha(s.color.a8),
          )
        else if (s.blurRadius == 0 && s.spreadRadius > 0)
          BoxShadow(spreadRadius: s.spreadRadius, color: edge)
        else
          s,
    ];
  }

  /// Drop shadow the surface itself casts (none for ground, rail, well).
  static List<BoxShadow> drop(SurfaceScope scope) {
    final shadows = scope.shadows;
    return switch (scope.kind) {
      SurfaceKind.ground || SurfaceKind.rail || SurfaceKind.well => const [],
      SurfaceKind.panel => shadows.panel,
      SurfaceKind.raised => control(shadows.card, scope),
      SurfaceKind.overlay => shadows.menu,
      SurfaceKind.sheet => shadows.modal,
    };
  }
}

extension on Color {
  int get a8 => (a * 255).round();
}
