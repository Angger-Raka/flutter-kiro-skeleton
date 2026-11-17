// Throwaway spike code (S15, S16, S17, S19). Radix sand values and shadow recipes are
// hard-coded here on purpose; the real skeleton generates them with `kit tokens`.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// ---------------------------------------------------------------- palette

const _light = <Color>[
  Color(0xFFFDFDFC), Color(0xFFF9F9F8), Color(0xFFF1F0EF), Color(0xFFE9E8E6),
  Color(0xFFE2E1DE), Color(0xFFDAD9D6), Color(0xFFCFCECA), Color(0xFFBCBBB5),
  Color(0xFF8D8D86), Color(0xFF82827C), Color(0xFF63635E), Color(0xFF21201C),
];
const _dark = <Color>[
  Color(0xFF111110), Color(0xFF191918), Color(0xFF222221), Color(0xFF2A2A28),
  Color(0xFF31312E), Color(0xFF3B3A37), Color(0xFF494844), Color(0xFF62605B),
  Color(0xFF6F6D66), Color(0xFF7C7B74), Color(0xFFB5B3AD), Color(0xFFEEEEEC),
];
const _surfaceTop = Color(0xFFFFFFFF);
const _darkGround = Color(0xFF080807);
const _lightShadowInk = Color(0xFF21201C); // rgb 33 32 28

// ---------------------------------------------------------------- shadows (04 §4.5)

/// shortcut: S16 blur conversion constants. flutterBlur = max(0, (css / 2 - kBlurOffset) / kBlurK).
/// Tune these two if the golden and the browser screenshot disagree.
const double kBlurK = 0.57735;
const double kBlurOffset = 0.5;

double flutterBlur(double cssBlur) =>
    math.max(0, (cssBlur / 2 - kBlurOffset) / kBlurK);

BoxShadow _sh(double x, double y, double blur, double spread, Color c) =>
    BoxShadow(
      offset: Offset(x, y),
      blurRadius: flutterBlur(blur),
      spreadRadius: spread,
      color: c,
    );

/// CSS lists paint the first shadow on top; Flutter paints the first at the bottom.
List<BoxShadow> _css(List<BoxShadow> l) => l.reversed.toList();

// ---------------------------------------------------------------- surfaces (04 §5)

enum SurfaceKind { ground, panel, raised, overlay }

@immutable
class SurfaceData {
  const SurfaceData(this.kind, this.brightness);
  final SurfaceKind kind;
  final Brightness brightness;

  bool get dark => brightness == Brightness.dark;
  List<Color> get _root => dark ? _dark : _light;

  /// Working ink step 1..12 for this surface (light remaps steps 1-7).
  Color ink(int n) {
    if (dark || n >= 8) return _root[n - 1];
    switch (kind) {
      case SurfaceKind.ground:
        return _light[n]; // root n + 1
      case SurfaceKind.panel:
        return n == 1 ? _surfaceTop : _light[n - 1];
      case SurfaceKind.overlay:
        return n <= 2 ? _surfaceTop : _light[n - 1];
      case SurfaceKind.raised:
        return _light[n - 1];
    }
  }

  Color rootInk(int n) => _root[n - 1];

  Color get fill {
    if (dark) {
      switch (kind) {
        case SurfaceKind.ground:
          return _darkGround;
        case SurfaceKind.panel:
          return _dark[0];
        case SurfaceKind.raised:
        case SurfaceKind.overlay:
          return _dark[1];
      }
    }
    return kind == SurfaceKind.ground ? _light[1] : _surfaceTop;
  }

  Color get _ink => _lightShadowInk;
  Color get _black => const Color(0xFF000000);

  // Control fill in dark: parent + 2 steps. Panel/ground ink-3, raised/overlay ink-4.
  bool get _onCard =>
      kind == SurfaceKind.raised || kind == SurfaceKind.overlay;
  Color get secondaryFill =>
      dark ? (_onCard ? _dark[3] : _dark[2]) : _surfaceTop;
  Color get secondaryHover => dark
      ? (_onCard ? _dark[4] : _dark[3])
      : _light[1]; // root ink-2
  Color get primaryBg => _root[11];
  Color get primaryFg => ink(1);
  Color get primaryHover => Color.lerp(primaryBg, primaryFg, 0.07)!;
  Color get focusRing => _root[9];

  List<BoxShadow> get buttonShadow => dark
      ? _css([
          _sh(0, 0, 0, 0.5, _onCard ? _dark[6] : _dark[5]),
          _sh(0, 1, 2, 0, _black.withValues(alpha: .5)),
        ])
      : _css([
          _sh(0, 1, 2, 0, _ink.withValues(alpha: .12)),
          _sh(0, 0, 0, 1, _ink.withValues(alpha: .08)),
        ]);

  List<BoxShadow> get primaryShadow => dark
      ? _css([
          _sh(0, 0, 0, 0.5, primaryBg),
          _sh(0, 1, 2, 0, _black.withValues(alpha: .5)),
        ])
      : [_sh(0, 0, 0, 1, ink(1))];

  List<BoxShadow> get cardShadow => dark
      ? _css([
          _sh(0, 0, 0, 0.5, _dark[5]),
          _sh(0, 1, 2, 0, _black.withValues(alpha: .5)),
          _sh(0, 3, 4, -2, _black.withValues(alpha: .4)),
        ])
      : _css([
          _sh(0, 0, 0, 1, _ink.withValues(alpha: .07)),
          _sh(0, 1, 2, 0, _ink.withValues(alpha: .12)),
          _sh(0, 3, 4, -2, _ink.withValues(alpha: .08)),
        ]);

  List<BoxShadow> get panelShadow => dark
      ? _css([
          _sh(0, 0, 0, 0.5, const Color(0x13F6F6F5)),
          _sh(0, 1, 2, 0, _black.withValues(alpha: .5)),
          _sh(0, 3, 4, -2, _black.withValues(alpha: .4)),
        ])
      : _css([
          _sh(0, 0, 0, 0.5, const Color(0x191F1500)),
          _sh(0, 1, 2, 0, _ink.withValues(alpha: .015)),
          _sh(0, 3, 4, -2, _ink.withValues(alpha: .025)),
        ]);

  List<BoxShadow> get modalShadow => dark
      ? _css([
          _sh(0, 0, 0, 0.5, _dark[6]),
          _sh(0, 1, 2, 0, _black.withValues(alpha: .5)),
          _sh(0, 6, 8, -4, _black.withValues(alpha: .5)),
        ])
      : _css([
          _sh(0, 0, 0, 1, _ink.withValues(alpha: .07)),
          _sh(0, 1, 2, 0, _ink.withValues(alpha: .14)),
          _sh(0, 6, 8, -4, _ink.withValues(alpha: .14)),
        ]);

  List<BoxShadow> get shadow {
    switch (kind) {
      case SurfaceKind.ground:
        return const [];
      case SurfaceKind.panel:
        return panelShadow;
      case SurfaceKind.raised:
        return cardShadow;
      case SurfaceKind.overlay:
        return modalShadow;
    }
  }
}

class SurfaceScope extends InheritedWidget {
  const SurfaceScope({super.key, required this.data, required super.child});
  final SurfaceData data;

  static SurfaceData of(BuildContext context) {
    final s = context.dependOnInheritedWidgetOfExactType<SurfaceScope>();
    return s?.data ??
        SurfaceData(SurfaceKind.ground, Theme.of(context).brightness);
  }

  @override
  bool updateShouldNotify(SurfaceScope old) =>
      old.data.kind != data.kind || old.data.brightness != data.brightness;
}

extension SurfaceContext on BuildContext {
  SurfaceData get surface => SurfaceScope.of(this);
}

/// Panel and raised surfaces: fill, ring and drop come from the kind and theme.
class TactileSurface extends StatelessWidget {
  const TactileSurface({
    super.key,
    required this.kind,
    this.radius = 8,
    this.padding = EdgeInsets.zero,
    required this.child,
  });
  final SurfaceKind kind;
  final double radius;
  final EdgeInsetsGeometry padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final data = SurfaceData(kind, Theme.of(context).brightness);
    return SurfaceScope(
      data: data,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: data.fill,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: data.shadow,
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

// ---------------------------------------------------------------- hit area (S17)

/// Pads the layout to at least [min] x [min] (child centred), so the hit and semantics
/// area is 48 on touch while the visual stays 36. Taps in the padding go to the child.
/// shortcut: centred padding only, no overlap handling between neighbours.
class MinHitArea extends SingleChildRenderObjectWidget {
  const MinHitArea({super.key, this.min = 48, super.child});
  final double min;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderMinHit(min);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) =>
      (renderObject as _RenderMinHit).min = min;
}

class _RenderMinHit extends RenderShiftedBox {
  _RenderMinHit(this.min) : super(null);
  double min;

  @override
  void performLayout() {
    final c = child!;
    c.layout(constraints.loosen(), parentUsesSize: true);
    size = constraints.constrain(
        Size(math.max(c.size.width, min), math.max(c.size.height, min)));
    (c.parentData! as BoxParentData).offset = Offset(
        (size.width - c.size.width) / 2, (size.height - c.size.height) / 2);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!size.contains(position)) return false;
    final c = child!;
    final off = (c.parentData! as BoxParentData).offset;
    final local = position - off;
    final clamped = Offset(local.dx.clamp(0.0, c.size.width - 0.01),
        local.dy.clamp(0.0, c.size.height - 0.01));
    return result.addWithRawTransform(
      transform: Matrix4.translationValues(
          clamped.dx - position.dx, clamped.dy - position.dy, 0),
      position: position,
      hitTest: (r, p) => c.hitTest(r, position: p),
    );
  }
}


// ---------------------------------------------------------------- Pressable (04 §7)

class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.onPressed,
    required this.semanticLabel,
    required this.radius,
    required this.builder,
    this.focusNode,
  });
  final VoidCallback? onPressed;
  final String semanticLabel;
  final double radius;
  final FocusNode? focusNode;

  /// `hot` is true while hovered or pressed (touch shows the hover fill while pressed).
  final Widget Function(BuildContext context, bool hot) builder;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _hover = false, _down = false, _focusVisible = false;

  bool get _enabled => widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    final body = Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedScale(
          // press scale may stay under reduced motion (04 §8)
          scale: _down && _enabled ? 0.97 : 1,
          duration: const Duration(milliseconds: 150),
          curve: const Cubic(0.23, 1, 0.32, 1),
          child: widget.builder(context, _enabled && (_hover || _down)),
        ),
        if (_focusVisible)
          Positioned(
            left: -4,
            top: -4,
            right: -4,
            bottom: -4,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.radius + 4),
                  border: Border.all(color: s.focusRing, width: 2),
                ),
              ),
            ),
          ),
      ],
    );
    final platform = Theme.of(context).platform;
    final touch = platform == TargetPlatform.iOS ||
        platform == TargetPlatform.android;
    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.semanticLabel,
      excludeSemantics: true,
      onTap: widget.onPressed,
      child: MinHitArea(
        min: touch ? 48 : 0,
        child: FocusableActionDetector(
          focusNode: widget.focusNode,
          enabled: _enabled,
          mouseCursor:
              _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
          onShowHoverHighlight: (v) => setState(() => _hover = v),
          onShowFocusHighlight: (v) => setState(() => _focusVisible = v),
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (_) => widget.onPressed?.call()),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => setState(() => _down = true),
            onTapUp: (_) => setState(() => _down = false),
            onTapCancel: () => setState(() => _down = false),
            onTap: widget.onPressed,
            child: body,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- AppButton

const double kControlHeight = 36;
const double kControlRadius = 6;

TextStyle labelStyle(Color color) => TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w500,
      fontSize: 13,
      height: 20 / 13,
      letterSpacing: -0.01 * 13,
      leadingDistribution: TextLeadingDistribution.even,
      color: color,
    );

enum _ButtonKind { primary, secondary }

class AppButton extends StatelessWidget {
  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.focusNode,
  }) : _kind = _ButtonKind.primary;
  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.focusNode,
  }) : _kind = _ButtonKind.secondary;

  final String label;
  final VoidCallback? onPressed;
  final FocusNode? focusNode;
  final _ButtonKind _kind;

  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    final primary = _kind == _ButtonKind.primary;
    return Pressable(
      onPressed: onPressed,
      semanticLabel: label,
      radius: kControlRadius,
      focusNode: focusNode,
      builder: (context, hot) {
        final bg = primary
            ? (hot ? s.primaryHover : s.primaryBg)
            : (hot ? s.secondaryHover : s.secondaryFill);
        final fg = primary ? s.primaryFg : s.rootInk(12);
        return Opacity(
          opacity: onPressed == null ? 0.6 : 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(kControlRadius),
              boxShadow: primary ? s.primaryShadow : s.buttonShadow,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: kControlHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: Text(label,
                      maxLines: 1,
                      softWrap: false,
                      style: labelStyle(fg)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------- AppCard

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => TactileSurface(
        kind: SurfaceKind.raised,
        radius: 8,
        padding: const EdgeInsets.all(24),
        child: child,
      );
}

/// The thing that is golden-tested and mirrored in web_reference.html:
/// ground -> panel (8 off the edge) -> card holding a secondary and a primary button.
class CardDemo extends StatelessWidget {
  const CardDemo({
    super.key,
    this.cancelFocus,
    this.createFocus,
    this.onCancel,
    this.onCreate,
  });
  final FocusNode? cancelFocus, createFocus;
  final VoidCallback? onCancel, onCreate;

  @override
  Widget build(BuildContext context) {
    final b = Theme.of(context).brightness;
    final ground = SurfaceData(SurfaceKind.ground, b);
    return SurfaceScope(
      data: ground,
      child: ColoredBox(
        color: ground.fill,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: TactileSurface(
            kind: SurfaceKind.panel,
            radius: 8,
            padding: const EdgeInsets.all(20),
            child: Align(
              alignment: Alignment.topCenter,
              child: AppCard(
                child: Builder(builder: (context) {
                  final s = context.surface;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('New project',
                          style: labelStyle(s.rootInk(12)).copyWith(
                              fontSize: 16,
                              height: 24 / 16,
                              letterSpacing: 0)),
                      const SizedBox(height: 2),
                      Text('Projects keep your tasks and files together.',
                          style: labelStyle(s.rootInk(11))
                              .copyWith(letterSpacing: 0)),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AppButton.secondary(
                            key: const Key('secondary'),
                            label: 'Cancel',
                            focusNode: cancelFocus,
                            onPressed: onCancel ?? () {},
                          ),
                          const SizedBox(width: 8),
                          AppButton.primary(
                            key: const Key('primary'),
                            label: 'Create project',
                            focusNode: createFocus,
                            onPressed: onCreate ?? () {},
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Theme

ThemeData buildTheme(Brightness b) => ThemeData(
      brightness: b,
      fontFamily: 'Inter',
      useMaterial3: true,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      scaffoldBackgroundColor: SurfaceData(SurfaceKind.ground, b).fill,
    );
