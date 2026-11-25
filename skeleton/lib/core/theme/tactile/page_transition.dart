import 'package:flutter/material.dart';
import 'package:skeleton/core/theme/tactile/motion.dart';

/// Tactile page entrance (04 §8): fade and 16 px rise over 300 ms, on route
/// mount only (the outgoing page does not move). With reduced motion it is a
/// 200 ms crossfade with no travel. Used for every platform.
class TactilePageTransitionsBuilder extends PageTransitionsBuilder {
  /// Creates the builder.
  const TactilePageTransitionsBuilder();

  /// Rise distance in logical pixels.
  static const double rise = 16;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final reduce = context.reduceMotion;
    // The route owns the 300 ms duration; reduced motion finishes the fade
    // within the first 200 ms of it.
    final curve = reduce
        ? Interval(
            0,
            AppMotion.d200.inMilliseconds / AppMotion.d300.inMilliseconds,
          )
        : AppMotion.easeOut;
    final curved = CurvedAnimation(parent: animation, curve: curve);
    return FadeTransition(
      opacity: curved,
      child: reduce
          ? child
          : AnimatedBuilder(
              animation: curved,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, rise * (1 - curved.value)),
                child: child,
              ),
              child: child,
            ),
    );
  }
}

/// Applies [TactilePageTransitionsBuilder] to every platform.
const PageTransitionsTheme tactilePageTransitionsTheme = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: TactilePageTransitionsBuilder(),
    TargetPlatform.iOS: TactilePageTransitionsBuilder(),
    TargetPlatform.macOS: TactilePageTransitionsBuilder(),
    TargetPlatform.windows: TactilePageTransitionsBuilder(),
    TargetPlatform.linux: TactilePageTransitionsBuilder(),
    TargetPlatform.fuchsia: TactilePageTransitionsBuilder(),
  },
);
