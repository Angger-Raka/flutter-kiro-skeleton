import 'package:flutter/material.dart';
import 'package:skeleton/core/layout/window_class.dart';
import 'package:skeleton/core/theme/tactile/motion.dart';
import 'package:skeleton/core/theme/tactile/surface.dart';
import 'package:skeleton/core/theme/tokens.g.dart';

/// The press primitive: press scale, hover or pressed fill, semantics.
///
/// [pressedScale] has no default: callers pass .97 for a button, .92 or .94
/// for an icon button (04 §7). `onPressed: null` disables the control (it is
/// drawn at 60 % opacity and ignores input).
class Pressable extends StatefulWidget {
  /// Creates a pressable.
  const Pressable({
    required this.onPressed,
    required this.child,
    required this.pressedScale,
    this.semanticLabel,
    this.borderRadius = AppRadius.controlAll,
    super.key,
  });

  /// Tap callback. `null` disables the control.
  final VoidCallback? onPressed;

  /// Content.
  final Widget child;

  /// Scale while pressed.
  final double pressedScale;

  /// Accessible name. Falls back to the text of [child].
  final String? semanticLabel;

  /// Shape of the hover fill.
  final BorderRadius borderRadius;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  static const double _disabledOpacity = 0.6;

  bool _hovered = false;
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  void _setPressed({required bool value}) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  void _setHovered({required bool value}) {
    if (_hovered != value) setState(() => _hovered = value);
  }

  @override
  Widget build(BuildContext context) {
    final scope = SurfaceScope.of(context);
    final touch = context.inputMode == InputMode.touch;
    // Hover is a mouse state; on touch the fill shows while pressed instead.
    final showFill = _enabled && (touch ? _pressed : _hovered || _pressed);
    final scale = _enabled && _pressed ? widget.pressedScale : 1.0;

    final visual = AnimatedScale(
      scale: scale,
      duration: AppMotion.d150,
      curve: AppMotion.easeOut,
      child: AnimatedContainer(
        duration: AppMotion.d150,
        curve: AppMotion.easeOut,
        decoration: BoxDecoration(
          color: showFill ? scope.hoverFill : const Color(0x00000000),
          borderRadius: widget.borderRadius,
        ),
        child: widget.child,
      ),
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.semanticLabel,
      onTap: widget.onPressed,
      child: MouseRegion(
        cursor: _enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onEnter: (_) => _setHovered(value: true),
        onExit: (_) => _setHovered(value: false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: _enabled ? (_) => _setPressed(value: true) : null,
          onTapUp: _enabled ? (_) => _setPressed(value: false) : null,
          onTapCancel: _enabled ? () => _setPressed(value: false) : null,
          onTap: widget.onPressed,
          child: _enabled
              ? visual
              : Opacity(opacity: _disabledOpacity, child: visual),
        ),
      ),
    );
  }
}
