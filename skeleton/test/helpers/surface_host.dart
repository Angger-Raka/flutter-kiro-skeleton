import 'package:flutter/material.dart';
import 'package:skeleton/core/theme/tactile/surface.dart';
import 'package:skeleton/core/theme/tokens.g.dart';

/// Space between the window edge and the widget under test.
const double hostInset = 8;

/// Test host: a root ground [SurfaceScope] for [brightness] and bounded, loose
/// constraints of [size] minus [hostInset] on every side, at the top left.
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
          // The inset keeps the widget off the window edge: the Flutter tap
          // target guideline skips any node that touches an edge.
          child: Padding(
            padding: const EdgeInsets.all(hostInset),
            child: Align(
              alignment: Alignment.topLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints.loose(
                  Size(size.width - 2 * hostInset, size.height - 2 * hostInset),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
