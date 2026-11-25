import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:skeleton/core/layout/window_class.dart';
import 'package:skeleton/core/theme/tactile/motion.dart';
import 'package:skeleton/core/theme/tactile/press_fill.dart';
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
    this.enableFocusRing = true,
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

  /// Draws the 2 px keyboard focus ring (offset 2 px) around the control.
  final bool enableFocusRing;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  static const double _disabledOpacity = 0.6;
  static const Size _minTouchTarget = Size(48, 48);

  bool _hovered = false;
  bool _pressed = false;
  bool _focusRing = false;

  bool get _enabled => widget.onPressed != null;

  @override
  void didUpdateWidget(Pressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Disabled controls get no tap-up/cancel/exit to clear these.
    if (widget.onPressed == null) {
      _pressed = false;
      _hovered = false;
    }
  }

  void _setPressed({required bool value}) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  void _setHovered({required bool value}) {
    if (_hovered != value) setState(() => _hovered = value);
  }

  void _setFocusRing({required bool value}) {
    if (_focusRing != value) setState(() => _focusRing = value);
  }

  @override
  Widget build(BuildContext context) {
    final scope = SurfaceScope.of(context);
    // Reduced motion: no animated scale or fill, the end state shows at once.
    final duration = context.reduceMotion ? Duration.zero : AppMotion.d150;
    const ringOutset = AppStroke.focusOffset + AppStroke.focusRing;
    final touch = context.inputMode == InputMode.touch;
    // Hover is a mouse state; on touch the fill shows while pressed instead.
    final showFill = _enabled && (touch ? _pressed : _hovered || _pressed);
    final scale = _enabled && _pressed ? widget.pressedScale : 1.0;

    final fill = AnimatedContainer(
      duration: duration,
      curve: AppMotion.easeOut,
      decoration: BoxDecoration(
        // Same RGB when idle: the fill fades in alpha only (no grey flash).
        color: showFill ? scope.hoverFill : scope.hoverFill.withAlpha(0),
        borderRadius: widget.borderRadius,
      ),
      // A TactileSurface below paints its own opaque fill over this one, so it
      // gets the fill too and draws it above its fill (Req 16.2).
      child: PressFill(
        active: showFill,
        duration: duration,
        child: widget.child,
      ),
    );
    final ring = _enabled && widget.enableFocusRing && _focusRing;
    final visual = AnimatedScale(
      scale: scale,
      duration: duration,
      curve: AppMotion.easeOut,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          fill,
          if (ring)
            Positioned(
              left: -ringOutset,
              top: -ringOutset,
              right: -ringOutset,
              bottom: -ringOutset,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.fromBorderSide(
                      BorderSide(
                        color: scope.ink(10),
                        width: AppStroke.focusRing,
                      ),
                    ),
                    borderRadius:
                        widget.borderRadius + BorderRadius.circular(ringOutset),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    final content = _enabled
        ? visual
        : Opacity(opacity: _disabledOpacity, child: visual);

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.semanticLabel,
      // An explicit label replaces the child's own text (no "Save Save").
      excludeSemantics: widget.semanticLabel != null,
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
          // On touch the layout is padded to 48 x 48; the visual is unchanged.
          child: FocusableActionDetector(
            enabled: _enabled,
            onShowFocusHighlight: (v) => _setFocusRing(value: v),
            actions: {
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) {
                  widget.onPressed?.call();
                  return null;
                },
              ),
            },
            child: context.inputMode == InputMode.touch
                ? MinHitArea(minSize: _minTouchTarget, child: content)
                : content,
          ),
        ),
      ),
    );
  }
}

/// Lays its child out at its own size but reports at least [minSize], with the
/// child centred. The padded area counts as layout, so a parent's hit test
/// reaches it (a hit area outside the layout size is never hit-tested).
class MinHitArea extends SingleChildRenderObjectWidget {
  /// Creates a minimum hit area.
  const MinHitArea({required this.minSize, super.child, super.key});

  /// Smallest size this widget reports.
  final Size minSize;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMinHitArea(minSize);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderObject renderObject,
  ) => (renderObject as _RenderMinHitArea).minSize = minSize;
}

class _RenderMinHitArea extends RenderShiftedBox {
  _RenderMinHitArea(this._minSize) : super(null);

  Size _minSize;

  Size get minSize => _minSize;
  set minSize(Size value) {
    if (value == _minSize) return;
    _minSize = value;
    markNeedsLayout();
  }

  Size _sizeFor(Size child, BoxConstraints constraints) =>
      constraints.constrain(
        Size(
          math.max(child.width, _minSize.width),
          math.max(child.height, _minSize.height),
        ),
      );

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final child = this.child;
    if (child == null) return constraints.constrain(_minSize);
    return _sizeFor(child.getDryLayout(constraints), constraints);
  }

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.constrain(_minSize);
      return;
    }
    child.layout(constraints, parentUsesSize: true);
    size = _sizeFor(child.size, constraints);
    (child.parentData! as BoxParentData).offset = Alignment.center
        .inscribe(child.size, Offset.zero & size)
        .topLeft;
  }
}
