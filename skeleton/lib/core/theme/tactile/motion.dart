import 'package:flutter/widgets.dart';

/// Curves and durations from 04 §8. Never use `Curves.easeIn*` (TAC004) and
/// never write a literal `Duration(...)` in widget code (TAC005).
abstract final class AppMotion {
  /// Default for anything the user caused, hover and colour included.
  static const Curve easeOut = Cubic(0.23, 1, 0.32, 1);

  /// Long moves of big objects (400 to 450 ms).
  static const Curve easeMove = Cubic(0.22, 1, 0.36, 1);

  /// A sheet after release.
  static const Curve easeDrawer = Cubic(0.32, 0.72, 0, 1);

  /// One-off fold where both ends stay on screen.
  static const Curve easeInOut = Cubic(0.77, 0, 0.175, 1);

  /// No motion (tooltip wait, reduced motion).
  static const Duration d0 = Duration.zero;

  /// Silent fade.
  static const Duration d80 = Duration(milliseconds: 80);

  /// Small exit.
  static const Duration d120 = Duration(milliseconds: 120);

  /// Press, hover, menu in.
  static const Duration d150 = Duration(milliseconds: 150);

  /// Swap, exit, overlay.
  static const Duration d200 = Duration(milliseconds: 200);

  /// Modal in.
  static const Duration d240 = Duration(milliseconds: 240);

  /// Sections, height.
  static const Duration d300 = Duration(milliseconds: 300);

  /// Sheet up.
  static const Duration d320 = Duration(milliseconds: 320);

  /// Big object move (400 ms).
  static const Duration d400 = Duration(milliseconds: 400);

  /// Copy tick of a pill without a label.
  static const Duration d1000 = Duration(milliseconds: 1000);

  /// Skeleton shimmer period.
  static const Duration d1200 = Duration(milliseconds: 1200);

  /// Copy tick of a pill with a label.
  static const Duration d1500 = Duration(milliseconds: 1500);

  /// Toast on screen.
  static const Duration d6000 = Duration(milliseconds: 6000);
}

/// Springs from 04 §8. Flutter 3.44.8 has `withDurationAndBounce` (S15: yes),
/// which equals mass 1, stiffness (2π/d)², damping 4π(1 − bounce)/d.
abstract final class AppSprings {
  /// Segmented pill: bounce 0.12, 0.4 s.
  static SpringDescription get toggle =>
      SpringDescription.withDurationAndBounce(
        duration: const Duration(milliseconds: 400),
        bounce: 0.12,
      );

  /// Switch knob: bounce 0.2, 0.45 s.
  static SpringDescription get knob => SpringDescription.withDurationAndBounce(
    duration: const Duration(milliseconds: 450),
    bounce: 0.2,
  );

  /// Height reveals: bounce 0.2, 0.35 s.
  static SpringDescription get reveal =>
      SpringDescription.withDurationAndBounce(
        duration: const Duration(milliseconds: 350),
        bounce: 0.2,
      );
}

/// Reduced-motion flag. Re-exported by `theme_x.dart` (task 4.2).
extension ReduceMotionX on BuildContext {
  /// True when the platform asks for fewer animations.
  bool get reduceMotion => MediaQuery.disableAnimationsOf(this);
}
