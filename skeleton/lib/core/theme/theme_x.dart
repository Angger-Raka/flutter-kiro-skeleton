import 'package:flutter/material.dart';
import 'package:skeleton/core/layout/window_class.dart';
import 'package:skeleton/core/theme/tactile/surface.dart';
import 'package:skeleton/core/theme/tactile/typography.dart';
import 'package:skeleton/core/theme/tokens.g.dart';

export 'package:skeleton/core/theme/tactile/motion.dart' show ReduceMotionX;

/// Token accessors on [BuildContext] (04 §4.2).
extension ThemeX on BuildContext {
  /// Nearest surface scope; the `panel` scope when there is none.
  SurfaceScope get surface => SurfaceScope.of(this);

  /// Type roles. Without an [AppTypography] in the theme (a bare
  /// `MaterialApp`) they are built for the current window class and input mode.
  AppTypography get text =>
      Theme.of(this).extension<AppTypography>() ??
      AppTypography.build(windowClass, inputMode);

  /// Control sizes for the current input mode.
  AppSizeSet get sizes =>
      inputMode == InputMode.touch ? AppSizeSet.touch : AppSizeSet.pointer;

  /// Hue scale of [role] in the active brightness.
  HueScale hue(HueRole role) => surface.palette.hues[role]!;

  /// Identity hue scale [index] in the active brightness. The identity list is
  /// empty until a tokens file defines identity hues.
  HueScale identity(int index) => surface.palette.identity[index];
}
