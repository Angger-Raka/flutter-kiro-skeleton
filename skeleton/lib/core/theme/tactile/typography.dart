import 'package:flutter/material.dart';
import 'package:skeleton/core/layout/window_class.dart';

/// Ink step (1 to 12) each role uses, from 04 §6.1. `null` means the control
/// decides (`label`) and `badge` uses its hue's step 11 instead of ink.
/// Colours are applied by the theme from the surface scope, not here.
abstract final class AppTypographyInk {
  /// display, figure, section, title, body, field.
  static const int strong = 12;

  /// description.
  static const int description = 11;

  /// meta (11 if the contrast gate fails; decided by the theme).
  static const int meta = 10;

  /// badge: hue step, not ink.
  static const int badgeHue = 11;
}

/// Type roles of 04 §6.1. One weight for every role; line heights are
/// absolute (`height = lineHeight / fontSize`, even leading distribution).
/// Styles carry no colour: see [AppTypographyInk].
@immutable
class AppTypography extends ThemeExtension<AppTypography> {
  /// Creates a role set.
  const AppTypography({
    required this.display,
    required this.figure,
    required this.section,
    required this.title,
    required this.body,
    required this.description,
    required this.meta,
    required this.label,
    required this.field,
    required this.badge,
  });

  /// Builds the roles for a window class and input mode.
  ///
  /// shortcut: the defaults below mirror `typography` in the tokens file
  /// (Inter, w500, size_factor 1, tracking label -0.01 / display -0.02,
  /// no heading face). Pass the generated values once tokens.g.dart lands.
  factory AppTypography.build(
    WindowClass windowClass,
    InputMode inputMode, {
    String family = 'Inter',
    FontWeight weight = FontWeight.w500,
    double sizeFactor = 1,
    double labelTracking = -0.01,
    double displayTracking = -0.02,
    String? headingFamily,
  }) {
    final mobile = windowClass == WindowClass.mobile;

    TextStyle style(
      double size,
      double lineHeight, {
      double tracking = 0,
      String? fontFamily,
      bool tabular = false,
    }) {
      final scaled = size * sizeFactor;
      return TextStyle(
        fontFamily: fontFamily ?? family,
        fontWeight: weight,
        fontSize: scaled,
        height: lineHeight / scaled,
        letterSpacing: tracking * scaled,
        leadingDistribution: TextLeadingDistribution.even,
        fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
      );
    }

    final touchField = inputMode == InputMode.touch;
    return AppTypography(
      display: style(
        32,
        40,
        tracking: displayTracking,
        fontFamily: headingFamily,
      ),
      figure: style(24, 32, tabular: true),
      section: style(20, 28, fontFamily: headingFamily),
      title: style(16, 24),
      body: mobile ? style(15, 24) : style(13, 20),
      description: mobile ? style(14, 20) : style(13, 20),
      meta: mobile ? style(15, 20) : style(12, 16),
      label: mobile
          ? style(15, 24, tracking: labelTracking)
          : style(13, 20, tracking: labelTracking),
      field: mobile || touchField ? style(16, 24) : style(13, 20),
      badge: mobile ? style(14, 22) : style(12, 20),
    );
  }

  /// 32/40 page title.
  final TextStyle display;

  /// 24/32 tabular number.
  final TextStyle figure;

  /// 20/28 section title.
  final TextStyle section;

  /// 16/24 title.
  final TextStyle title;

  /// Body text.
  final TextStyle body;

  /// Secondary description.
  final TextStyle description;

  /// Small meta text.
  final TextStyle meta;

  /// Button label.
  final TextStyle label;

  /// Input text.
  final TextStyle field;

  /// Badge text.
  final TextStyle badge;

  @override
  bool operator ==(Object other) =>
      other is AppTypography &&
      display == other.display &&
      figure == other.figure &&
      section == other.section &&
      title == other.title &&
      body == other.body &&
      description == other.description &&
      meta == other.meta &&
      label == other.label &&
      field == other.field &&
      badge == other.badge;

  @override
  int get hashCode => Object.hash(
    display,
    figure,
    section,
    title,
    body,
    description,
    meta,
    label,
    field,
    badge,
  );

  @override
  AppTypography copyWith({
    TextStyle? display,
    TextStyle? figure,
    TextStyle? section,
    TextStyle? title,
    TextStyle? body,
    TextStyle? description,
    TextStyle? meta,
    TextStyle? label,
    TextStyle? field,
    TextStyle? badge,
  }) => AppTypography(
    display: display ?? this.display,
    figure: figure ?? this.figure,
    section: section ?? this.section,
    title: title ?? this.title,
    body: body ?? this.body,
    description: description ?? this.description,
    meta: meta ?? this.meta,
    label: label ?? this.label,
    field: field ?? this.field,
    badge: badge ?? this.badge,
  );

  @override
  AppTypography lerp(ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) return this;
    TextStyle l(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;
    return AppTypography(
      display: l(display, other.display),
      figure: l(figure, other.figure),
      section: l(section, other.section),
      title: l(title, other.title),
      body: l(body, other.body),
      description: l(description, other.description),
      meta: l(meta, other.meta),
      label: l(label, other.label),
      field: l(field, other.field),
      badge: l(badge, other.badge),
    );
  }
}
