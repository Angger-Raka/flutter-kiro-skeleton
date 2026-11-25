import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeleton/core/theme/tactile/blur_conversion.dart';
import 'package:skeleton/core/theme/tactile/shadows.dart';
import 'package:skeleton/core/theme/tactile/surface.dart';
import 'package:skeleton/core/theme/tokens.g.dart';

SurfaceScope scope(SurfaceKind kind, Brightness b) {
  final light = b == Brightness.light;
  return SurfaceScope(
    kind: kind,
    brightness: b,
    palette: light ? AppPalette.light : AppPalette.dark,
    shadows: light ? AppShadows.light : AppShadows.dark,
    child: const SizedBox.shrink(),
  );
}

void main() {
  test('ShadowRecipe converts blur with the shared function', () {
    const r = ShadowRecipe(
      dx: 1,
      dy: 2,
      cssBlur: 6,
      spread: -1,
      color: Color(0x33000000),
    );
    final s = r.toBoxShadow();
    expect(s.offset, const Offset(1, 2));
    expect(s.blurRadius, cssBlurToFlutter(6));
    expect(s.spreadRadius, -1);
    expect(s.color, const Color(0x33000000));
  });

  group('light: selection equals the generated lists on every surface', () {
    for (final kind in SurfaceKind.values) {
      test('$kind', () {
        final s = scope(kind, Brightness.light);
        expect(s.button(), AppShadows.light.button);
        expect(s.primary(), AppShadows.light.primary);
        expect(s.toggle(), AppShadows.light.toggle);
      });
    }
  });

  group('dark panel equals the generated lists', () {
    final s = scope(SurfaceKind.panel, Brightness.dark);
    test('button, primary, toggle', () {
      expect(s.button(), AppShadows.dark.button);
      expect(s.primary(), AppShadows.dark.primary);
      expect(s.toggle(), AppShadows.dark.toggle);
    });
    test('drop is the panel shadow', () {
      expect(SurfaceShadows.drop(s), AppShadows.dark.panel);
    });
  });

  group('dark raised, overlay, sheet use the ink 7 outline', () {
    for (final kind in [
      SurfaceKind.raised,
      SurfaceKind.overlay,
      SurfaceKind.sheet,
    ]) {
      test('$kind', () {
        final s = scope(kind, Brightness.dark);
        final ink7 = AppPalette.dark.inkStep(7);
        final button = s.button();
        expect(button.length, AppShadows.dark.button.length);
        expect(button.last.color, ink7);
        expect(button.last.spreadRadius, 0.5);
        // The tight drop is untouched.
        expect(button.first, AppShadows.dark.button.first);
      });
    }
  });

  test('drop per kind', () {
    for (final b in Brightness.values) {
      final set = b == Brightness.light ? AppShadows.light : AppShadows.dark;
      expect(SurfaceShadows.drop(scope(SurfaceKind.ground, b)), isEmpty);
      expect(SurfaceShadows.drop(scope(SurfaceKind.rail, b)), isEmpty);
      expect(SurfaceShadows.drop(scope(SurfaceKind.well, b)), isEmpty);
      expect(SurfaceShadows.drop(scope(SurfaceKind.panel, b)), set.panel);
      expect(SurfaceShadows.drop(scope(SurfaceKind.overlay, b)), set.menu);
      expect(SurfaceShadows.drop(scope(SurfaceKind.sheet, b)), set.modal);
    }
    expect(
      SurfaceShadows.drop(scope(SurfaceKind.raised, Brightness.light)),
      AppShadows.light.card,
    );
  });

  group('badge', () {
    final hue = AppPalette.light.hues[HueRole.success]!;
    test('light keeps alphas and takes the hue colour', () {
      final out = scope(SurfaceKind.panel, Brightness.light).badge(hue);
      final base = AppShadows.light.badge;
      expect(out.length, base.length);
      for (var i = 0; i < out.length; i++) {
        expect(out[i].color.a, closeTo(base[i].color.a, 1 / 255));
        expect(
          out[i].color.toARGB32() & 0xFFFFFF,
          hue.s11.toARGB32() & 0xFFFFFF,
        );
        expect(out[i].offset, base[i].offset);
      }
    });

    test('dark edge is 34 % of the hue mixed into black', () {
      final dkHue = AppPalette.dark.hues[HueRole.success]!;
      final out = scope(SurfaceKind.panel, Brightness.dark).badge(dkHue);
      final edge = Color.lerp(const Color(0xFF000000), dkHue.s11, 0.34);
      expect(out.last.color, edge);
      expect(out.first, AppShadows.dark.badge.first);
    });
  });
}
