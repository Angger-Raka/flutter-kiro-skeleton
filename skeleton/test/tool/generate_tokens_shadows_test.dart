import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:skeleton/core/theme/tactile/blur_conversion.dart';

import '../../tool/generate_tokens.dart';
import '../../tool/src/color_math.dart';
import '../../tool/src/knobs.dart';
import '../../tool/src/palette.dart';
import '../../tool/src/shadow_recipes.dart';
import '../../tool/src/shadows.dart';

void main() {
  final knobs = Knobs.parse(File(defaultYamlPath).readAsStringSync());
  PaletteData palette({required bool dark}) => buildPalette(
    knobs,
    dark: dark,
    ink: baseInk(knobs, dark: dark),
  );

  test('a ring recipe gives blurRadius: 0 and keeps its spread', () {
    final src = boxShadowSource(
      const CssShadow(0, 0, 0, 1, ShadowColor(Rgb(33, 32, 28), .08)),
    );
    expect(src, contains('blurRadius: 0,'));
    expect(src, contains('spreadRadius: 1,'));
    expect(src, contains('offset: Offset(0, 0)'));
  });

  test('blur 10 is converted; offsets and spread unchanged', () {
    final src = boxShadowSource(
      const CssShadow(2, 3, 10, -4, ShadowColor(Rgb(33, 32, 28))),
    );
    expect(src, contains('blurRadius: ${cssBlurToFlutter(10)},'));
    expect(src, contains('offset: Offset(2, 3)'));
    expect(src, contains('spreadRadius: -4,'));
  });

  test('every token exists for both brightnesses; rings are zero blur', () {
    for (final dark in [false, true]) {
      final recipes = shadowRecipes(palette(dark: dark));
      expect(recipes.keys.toList(), shadowTokens);
      for (final layers in recipes.values) {
        for (final l in layers) {
          if (l.blur == 0) {
            expect(boxShadowSource(l), contains('blurRadius: 0,'));
          }
        }
      }
    }
  });

  test('CSS order is reversed for Flutter', () {
    final card = shadowRecipes(palette(dark: false))['card']!;
    final src = shadowListSource(card);
    expect(src.indexOf('Offset(0, 3)'), lessThan(src.indexOf('Offset(0, 1)')));
  });

  test('dark shadows are black drops under a solid outline', () {
    final button = shadowRecipes(palette(dark: true))['button']!;
    expect(button.first.spread, 0.5);
    expect(button.last.color.rgb.r, 0);
    expect(button.last.color.alpha, .5);
  });
}
