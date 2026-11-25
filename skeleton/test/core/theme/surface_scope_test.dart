import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
  for (final b in Brightness.values) {
    final palette = b == Brightness.light ? AppPalette.light : AppPalette.dark;
    for (final kind in SurfaceKind.values) {
      final s = scope(kind, b);
      test('property 15: text steps 8-12 do not remap ($kind, $b)', () {
        for (var step = 8; step <= 12; step++) {
          expect(s.ink(step), palette.inkStep(step));
        }
      });

      test('property 16: hover differs from selected ($kind, $b)', () {
        expect(s.hoverFill, isNot(s.selectedFill));
        expect(s.hoverFill, isNot(s.fill));
        expect(s.selectedFill, isNot(s.fill));
      });
    }
  }

  group('light remap table (04 §5)', () {
    const p = AppPalette.light;
    Color root(int n) => p.inkStep(n);

    test('rail: root 2, root 3, then root +1', () {
      final s = scope(SurfaceKind.rail, Brightness.light);
      expect(s.ink(1), root(2));
      expect(s.ink(2), root(3));
      for (var n = 3; n <= 7; n++) {
        expect(s.ink(n), root(n + 1));
      }
    });

    test('panel: surface top, root 2, then root', () {
      final s = scope(SurfaceKind.panel, Brightness.light);
      expect(s.ink(1), p.panel);
      expect(s.ink(2), root(2));
      for (var n = 3; n <= 7; n++) {
        expect(s.ink(n), root(n));
      }
    });

    test('overlay and sheet: surface top twice, then root', () {
      for (final kind in [SurfaceKind.overlay, SurfaceKind.sheet]) {
        final s = scope(kind, Brightness.light);
        expect(s.ink(1), p.overlay);
        expect(s.ink(2), p.overlay);
        for (var n = 3; n <= 7; n++) {
          expect(s.ink(n), root(n));
        }
      }
    });

    test('raised: root', () {
      final s = scope(SurfaceKind.raised, Brightness.light);
      for (var n = 1; n <= 7; n++) {
        expect(s.ink(n), root(n));
      }
    });
  });

  group('dark', () {
    test('steps stay root', () {
      for (final kind in SurfaceKind.values) {
        final s = scope(kind, Brightness.dark);
        for (var n = 1; n <= 12; n++) {
          expect(s.ink(n), AppPalette.dark.inkStep(n));
        }
      }
    });

    test('control outline: ink 6 on panel, ink 7 on raised/overlay/sheet', () {
      const p = AppPalette.dark;
      expect(scope(SurfaceKind.panel, Brightness.dark).line, p.inkStep(6));
      for (final kind in [
        SurfaceKind.raised,
        SurfaceKind.overlay,
        SurfaceKind.sheet,
      ]) {
        expect(scope(kind, Brightness.dark).line, p.inkStep(7));
      }
    });
  });

  testWidgets('without an ancestor the panel scope of the theme is used', (
    tester,
  ) async {
    late SurfaceScope found;
    for (final b in Brightness.values) {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: b),
          home: Builder(
            builder: (context) {
              found = SurfaceScope.of(context);
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(found.kind, SurfaceKind.panel);
      expect(found.brightness, b);
    }
  });
}
