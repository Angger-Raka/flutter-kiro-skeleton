// Spacing, radius, stroke, size, and layout tokens (04 §4.2) and their Dart
// rendering. Only the radius depends on tokens.yaml.

/// Spacing ladder, in logical pixels.
const spaceLadder = <int>[2, 4, 6, 8, 12, 16, 20, 24, 32, 48, 64];

/// Stroke widths.
const strokes = <String, double>{
  'hairline': 0.5,
  'focusRing': 2,
  'focusOffset': 2,
  'mark': 1.5,
};

/// Input-dependent sizes: pointer (desktop) and touch.
const sizeNames = [
  'control',
  'compact',
  'pill',
  'inline',
  'iconButton',
  'badge',
  'row',
  'sheetRow',
  'toggleTrack',
];

/// Sizes for pointer input.
const pointerSizes = <String, double>{
  'control': 36,
  'compact': 32,
  'pill': 28,
  'inline': 24,
  'iconButton': 22,
  'badge': 20,
  'row': 38,
  'sheetRow': 48,
  'toggleTrack': 36,
};

/// Sizes for touch input.
const touchSizes = <String, double>{
  'control': 44,
  'compact': 32,
  'pill': 36,
  'inline': 24,
  'iconButton': 22,
  'badge': 22,
  'row': 44,
  'sheetRow': 48,
  'toggleTrack': 42,
};

/// Layout tokens (requirement 20.4), in emitted order.
const layoutTokens = <String, double>{
  'breakpointTablet': 768,
  'breakpointDesktop': 1200,
  'colReading': 800,
  'colData': 1200,
  'colForm': 440,
  'railExpanded': 256,
  'railCollapsed': 72,
  'topStrip': 52,
  'mobileTopBar': 56,
  'panelFloat': 8,
};

/// Sizes of overlays, toasts, sheets, and empty states, in emitted order
/// (design D13). Every value is one `double`; a pair is two names. Kept apart
/// from [layoutTokens], whose requirement 20.4 test stays unchanged.
const overlayTokens = <String, double>{
  'dialogDefault': 620,
  'dialogConfirm': 460,
  'dialogInfo': 440,
  'toastHeight': 48,
  'sheetHandleWidth': 36,
  'sheetHandleHeight': 5,
  'sheetHandleHitWidth': 88,
  'sheetHandleHitHeight': 44,
  'emptyPadding': 44,
  'dialogRise': 16,
  'dialogBlur': 4,
  'backdropBlur': 2,
};

/// The radius ladder for control radius [c]: xs = c/2, sm = c-2,
/// control = c, container = c+2, feature = container*1.5, sheet = 14.
Map<String, double> radiusLadder(double c) => {
  'xs': c / 2,
  'sm': c - 2,
  'control': c,
  'container': c + 2,
  'feature': (c + 2) * 1.5,
  'sheet': 14,
};

String _n(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : '$v';

String _consts(Map<String, double> values) => [
  for (final e in values.entries)
    'static const double ${e.key} = ${_n(e.value)};',
].join('\n');

String _sizeSet(String name, Map<String, double> values) =>
    'static const AppSizeSet $name = AppSizeSet(\n'
    '${[for (final k in sizeNames) '$k: ${_n(values[k]!)},'].join('\n')}\n);';

/// Dart source for the ladders, strokes, sizes, layout, and overlay sizes.
String renderLadders(double radiusControl) =>
    '''
/// Spacing ladder 2..64.
abstract final class AppSpace {
${[for (final s in spaceLadder) 'static const double s$s = $s;'].join('\n')}
}

/// Radius ladder derived from `radius_control`.
abstract final class AppRadius {
${_consts(radiusLadder(radiusControl))}

  /// Fully rounded.
  static const Radius full = Radius.circular(9999);

  /// Control radius on all corners.
  static const BorderRadius controlAll =
      BorderRadius.all(Radius.circular(control));

  /// Container radius on all corners.
  static const BorderRadius containerAll =
      BorderRadius.all(Radius.circular(container));
}

/// Stroke widths.
abstract final class AppStroke {
${_consts(strokes)}
}

/// Sizes that depend on input mode, as a pointer set and a touch set.
class AppSizeSet {
  /// Creates a size set.
  const AppSizeSet({
${[for (final k in sizeNames) 'required this.$k,'].join('\n')}
  });

${[for (final k in sizeNames) 'final double $k;'].join('\n')}

${_sizeSet('pointer', pointerSizes)}

${_sizeSet('touch', touchSizes)}
}

/// Breakpoints, columns, and shell dimensions.
abstract final class AppLayout {
${_consts(layoutTokens)}
}

/// Sizes of dialogs, toasts, sheets, and empty states.
abstract final class AppOverlay {
${_consts(overlayTokens)}
}
''';
