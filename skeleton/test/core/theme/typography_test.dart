import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeleton/core/layout/window_class.dart';
import 'package:skeleton/core/theme/tactile/typography.dart';

void main() {
  // role: [size, lineHeight]
  const desktop = {
    'display': [32.0, 40.0],
    'figure': [24.0, 32.0],
    'section': [20.0, 28.0],
    'title': [16.0, 24.0],
    'body': [13.0, 20.0],
    'description': [13.0, 20.0],
    'meta': [12.0, 16.0],
    'label': [13.0, 20.0],
    'field': [13.0, 20.0],
    'badge': [12.0, 20.0],
  };
  const mobile = {
    'display': [32.0, 40.0],
    'figure': [24.0, 32.0],
    'section': [20.0, 28.0],
    'title': [16.0, 24.0],
    'body': [15.0, 24.0],
    'description': [14.0, 20.0],
    'meta': [15.0, 20.0],
    'label': [15.0, 24.0],
    'field': [16.0, 24.0],
    'badge': [14.0, 22.0],
  };

  Map<String, TextStyle> roles(AppTypography t) => {
    'display': t.display,
    'figure': t.figure,
    'section': t.section,
    'title': t.title,
    'body': t.body,
    'description': t.description,
    'meta': t.meta,
    'label': t.label,
    'field': t.field,
    'badge': t.badge,
  };

  void expectTable(AppTypography t, Map<String, List<double>> table) {
    final styles = roles(t);
    for (final e in table.entries) {
      final s = styles[e.key]!;
      expect(s.fontSize, e.value[0], reason: '${e.key} size');
      expect(s.height! * s.fontSize!, closeTo(e.value[1], 1e-9));
    }
  }

  test('mobile table', () {
    expectTable(
      AppTypography.build(WindowClass.mobile, InputMode.touch),
      mobile,
    );
  });

  test('desktop and tablet table', () {
    expectTable(
      AppTypography.build(WindowClass.desktop, InputMode.pointer),
      desktop,
    );
    expectTable(
      AppTypography.build(WindowClass.tablet, InputMode.pointer),
      desktop,
    );
  });

  test('one weight, even leading, sans face for every role', () {
    for (final wc in WindowClass.values) {
      for (final mode in InputMode.values) {
        for (final s in roles(AppTypography.build(wc, mode)).values) {
          expect(s.fontWeight, FontWeight.w500);
          expect(s.fontFamily, 'Inter');
          expect(s.leadingDistribution, TextLeadingDistribution.even);
        }
      }
    }
  });

  test('tabular figures on figure only', () {
    final t = AppTypography.build(WindowClass.desktop, InputMode.pointer);
    expect(t.figure.fontFeatures, const [FontFeature.tabularFigures()]);
    expect(t.body.fontFeatures, isNull);
  });

  test('field is 16/24 on touch, also on desktop width', () {
    final t = AppTypography.build(WindowClass.desktop, InputMode.touch);
    expect(t.field.fontSize, 16);
    expect(t.field.height! * 16, 24);
  });

  test('tracking: display -0.02 em, label -0.01 em', () {
    final t = AppTypography.build(WindowClass.desktop, InputMode.pointer);
    expect(t.display.letterSpacing, closeTo(-0.64, 1e-9));
    expect(t.label.letterSpacing, closeTo(-0.13, 1e-9));
  });

  test('heading face applies to display and section only', () {
    final t = AppTypography.build(
      WindowClass.desktop,
      InputMode.pointer,
      headingFamily: 'SpaceGrotesk',
    );
    expect(t.display.fontFamily, 'SpaceGrotesk');
    expect(t.section.fontFamily, 'SpaceGrotesk');
    expect(t.title.fontFamily, 'Inter');
    expect(t.badge.fontFamily, 'Inter');
  });
}
