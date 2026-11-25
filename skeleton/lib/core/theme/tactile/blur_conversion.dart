import 'dart:math' as math;

/// Converts a CSS `box-shadow` blur to a Flutter `BoxShadow.blurRadius`.
///
/// CSS uses a Gaussian sigma of `blur / 2`. Flutter derives sigma as
/// `r * 0.57735 + 0.5`. Solving for `r` gives the formula below (04 §4.5).
/// Imports only `dart:math` so the token generator and `shadows.dart` can
/// both use it.
double cssBlurToFlutter(double cssBlur) =>
    math.max(0, (cssBlur / 2 - 0.5) / 0.57735);
