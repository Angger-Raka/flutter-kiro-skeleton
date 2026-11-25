import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeleton/core/theme/tactile/shadows.dart';
import 'package:skeleton/core/theme/tactile/surface.dart';
import 'package:skeleton/core/theme/tokens.g.dart';

void main() {
  for (final b in Brightness.values) {
    final palette = b == Brightness.light ? AppPalette.light : AppPalette.dark;

    testWidgets('raised inside panel gives its child a raised scope ($b)', (
      tester,
    ) async {
      late SurfaceScope outer;
      late SurfaceScope inner;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: b),
          home: TactileSurface(
            kind: SurfaceKind.panel,
            child: Builder(
              builder: (context) {
                outer = SurfaceScope.of(context);
                return TactileSurface(
                  kind: SurfaceKind.raised,
                  padding: const EdgeInsets.all(AppSpace.s8),
                  child: Builder(
                    builder: (context) {
                      inner = SurfaceScope.of(context);
                      return const SizedBox(key: Key('leaf'));
                    },
                  ),
                );
              },
            ),
          ),
        ),
      );
      expect(outer.kind, SurfaceKind.panel);
      expect(inner.kind, SurfaceKind.raised);
      expect(inner.brightness, b);

      final box = tester.widget<DecoratedBox>(
        find
            .ancestor(
              of: find.byKey(const Key('leaf')),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final decoration = box.decoration as BoxDecoration;
      expect(decoration.color, inner.fill);
      expect(decoration.color, palette.raised);
      expect(decoration.boxShadow, SurfaceShadows.drop(inner));
      expect(decoration.borderRadius, AppRadius.containerAll);
    });
  }

  testWidgets('explicit radius and padding are applied', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: TactileSurface(
            kind: SurfaceKind.well,
            radius: BorderRadius.zero,
            padding: EdgeInsets.all(AppSpace.s12),
            child: SizedBox(key: Key('leaf'), width: 10, height: 10),
          ),
        ),
      ),
    );
    final decoration =
        tester.widget<DecoratedBox>(find.byType(DecoratedBox).first).decoration
            as BoxDecoration;
    expect(decoration.borderRadius, BorderRadius.zero);
    expect(
      tester.getSize(find.byType(TactileSurface)),
      const Size(10 + 2 * AppSpace.s12, 10 + 2 * AppSpace.s12),
    );
  });
}
