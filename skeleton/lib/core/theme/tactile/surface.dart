import 'package:flutter/material.dart';
import 'package:skeleton/core/theme/tokens.g.dart';

/// Kinds of surface from 04 §5.
enum SurfaceKind {
  /// App ground behind everything.
  ground,

  /// Navigation rail, drawn on the ground.
  rail,

  /// Main panel.
  panel,

  /// Card or control raised from its parent.
  raised,

  /// Menu, popover, dialog.
  overlay,

  /// Bottom sheet.
  sheet,

  /// Field well.
  well,
}

/// Working ink steps, hover and selected fills, and shadows for one surface.
///
/// Core widgets read this (`context.surface`), never absolute colours. Text
/// steps 8 to 12 never remap, so text ink is the same on every surface.
class SurfaceScope extends InheritedWidget {
  /// Creates a scope for [kind] in the given brightness.
  const SurfaceScope({
    required this.kind,
    required this.brightness,
    required this.palette,
    required this.shadows,
    required super.child,
    super.key,
  });

  /// Surface kind this scope describes.
  final SurfaceKind kind;

  /// Brightness of the active theme.
  final Brightness brightness;

  /// Palette for [brightness].
  final AppPalette palette;

  /// Shadow set for [brightness].
  final AppShadows shadows;

  bool get _light => brightness == Brightness.light;

  /// Working ink [step] (1 to 12). Steps 1 to 7 are remapped for the surface
  /// (04 §5); steps 8 to 12 are the root ink.
  Color ink(int step) {
    assert(step >= 1 && step <= 12, 'ink step must be 1..12');
    if (step > 7 || !_light) return palette.inkStep(step);
    switch (kind) {
      case SurfaceKind.ground:
      case SurfaceKind.raised:
        return palette.inkStep(step);
      case SurfaceKind.rail:
        // Root +1 on every step: working 1 = root 2, 2 = root 3, ...
        return palette.inkStep(step + 1);
      case SurfaceKind.panel:
      case SurfaceKind.well:
        return switch (step) {
          1 => palette.panel,
          2 => palette.inkStep(2),
          _ => palette.inkStep(step),
        };
      case SurfaceKind.overlay:
      case SurfaceKind.sheet:
        return step <= 2 ? palette.overlay : palette.inkStep(step);
    }
  }

  /// Fill of the surface itself.
  Color get fill => switch (kind) {
    SurfaceKind.ground || SurfaceKind.rail => palette.ground,
    SurfaceKind.panel => palette.panel,
    SurfaceKind.raised => palette.raised,
    SurfaceKind.overlay || SurfaceKind.sheet => palette.overlay,
    SurfaceKind.well => palette.well,
  };

  /// Working step (0 = below ink 1, dark ground) that matches [fill].
  int get _groundStep {
    if (_light) {
      return switch (kind) {
        SurfaceKind.ground => 2,
        SurfaceKind.rail || SurfaceKind.panel || SurfaceKind.raised => 1,
        SurfaceKind.overlay || SurfaceKind.sheet => 2,
        SurfaceKind.well => 3,
      };
    }
    return switch (kind) {
      SurfaceKind.ground || SurfaceKind.rail => 0,
      SurfaceKind.panel => 1,
      SurfaceKind.raised || SurfaceKind.overlay || SurfaceKind.sheet => 2,
      SurfaceKind.well => 3,
    };
  }

  /// Hairline and control outline colour. In dark, raised, overlay, and sheet
  /// surfaces step up to ink 7 (04 §5).
  Color get line => switch (kind) {
    SurfaceKind.raised ||
    SurfaceKind.overlay ||
    SurfaceKind.sheet when !_light => ink(7),
    _ => ink(6),
  };

  /// Local ground + 1 step.
  Color get hoverFill => ink(_groundStep + 1);

  /// Local ground + 2 steps.
  Color get selectedFill => ink(_groundStep + 2);

  /// Shadow list of a secondary button on this surface.
  List<BoxShadow> button() => shadows.button;

  /// Shadow list of a primary button on this surface.
  List<BoxShadow> primary() => shadows.primary;

  /// Shadow list of a toggle on this surface.
  List<BoxShadow> toggle() => shadows.toggle;

  /// Shadow list of a badge in [hue] (the neutral badge for now).
  List<BoxShadow> badge(HueScale hue) => shadows.badge;

  /// Copy of this scope for another [kind], same brightness and palette.
  SurfaceScope withKind(SurfaceKind kind, Widget child) => SurfaceScope(
    kind: kind,
    brightness: brightness,
    palette: palette,
    shadows: shadows,
    child: child,
  );

  /// Nearest scope. With no ancestor it returns the `panel` scope of the
  /// current theme brightness instead of throwing (Q19).
  // ignore: prefer_constructors_over_static_methods
  static SurfaceScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SurfaceScope>();
    if (scope != null) return scope;
    final light = Theme.of(context).brightness == Brightness.light;
    return SurfaceScope(
      kind: SurfaceKind.panel,
      brightness: light ? Brightness.light : Brightness.dark,
      palette: light ? AppPalette.light : AppPalette.dark,
      shadows: light ? AppShadows.light : AppShadows.dark,
      child: const SizedBox.shrink(),
    );
  }

  @override
  bool updateShouldNotify(SurfaceScope oldWidget) =>
      kind != oldWidget.kind ||
      brightness != oldWidget.brightness ||
      palette != oldWidget.palette ||
      shadows != oldWidget.shadows;
}
