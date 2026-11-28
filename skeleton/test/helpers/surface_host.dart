import 'package:flutter/material.dart';
import 'package:skeleton/core/theme/tactile/surface.dart';
import 'package:skeleton/core/theme/tokens.g.dart';

/// Test host: a root ground [SurfaceScope] for [brightness] and bounded, loose
/// constraints of [size] at the top left, as the app gives a widget.
///
/// There is no `Scaffold`. [boundaryKey] marks the [RepaintBoundary] that the
/// stress harness captures when a case fails.
class SurfaceHost extends StatelessWidget {
  const SurfaceHost({
    required this.brightness,
    required this.size,
    required this.child,
    this.boundaryKey,
    super.key,
  });

  final Brightness brightness;
  final Size size;
  final Widget child;
  final GlobalKey? boundaryKey;

  @override
  Widget build(BuildContext context) {
    final light = brightness == Brightness.light;
    final palette = light ? AppPalette.light : AppPalette.dark;
    return SurfaceScope(
      kind: SurfaceKind.ground,
      brightness: brightness,
      palette: palette,
      shadows: light ? AppShadows.light : AppShadows.dark,
      child: RepaintBoundary(
        key: boundaryKey,
        child: ColoredBox(
          color: palette.inkStep(1),
          child: Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints.loose(size),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
