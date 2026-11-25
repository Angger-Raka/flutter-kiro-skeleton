import 'package:flutter/widgets.dart';

/// Hover or pressed state that a `Pressable` hands to the `TactileSurface`
/// directly below it. The surface paints its own `hoverFill` above its opaque
/// fill and below its content, so the fill stays visible (Req 16.2).
class PressFill extends InheritedWidget {
  /// Creates a press fill.
  const PressFill({
    required this.active,
    required this.duration,
    required super.child,
    super.key,
  });

  /// Whether the fill shows.
  final bool active;

  /// Fade time of the fill.
  final Duration duration;

  /// Nearest press fill, or `null`.
  static PressFill? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PressFill>();

  @override
  bool updateShouldNotify(PressFill oldWidget) =>
      active != oldWidget.active || duration != oldWidget.duration;
}
