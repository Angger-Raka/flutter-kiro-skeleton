import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:skeleton/core/theme/tokens.g.dart';

/// Window size class derived from the logical width.
enum WindowClass {
  /// Width below 768.
  mobile,

  /// Width from 768 up to 1200.
  tablet,

  /// Width of 1200 and up.
  desktop,
}

/// Width to [WindowClass] mapping.
extension WindowClassX on WindowClass {
  /// mobile < 768 <= tablet < 1200 <= desktop.
  static WindowClass fromWidth(double width) =>
      width < AppLayout.breakpointTablet
      ? WindowClass.mobile
      : width < AppLayout.breakpointDesktop
      ? WindowClass.tablet
      : WindowClass.desktop;

  /// Reads the MediaQuery width. Features never branch on kIsWeb/Platform.
  static WindowClass of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);
}

/// How the user points at the screen.
enum InputMode {
  /// Mouse or trackpad.
  pointer,

  /// Finger.
  touch,
}

/// Platform to [InputMode] mapping.
extension InputModeX on InputMode {
  /// touch on iOS and Android (also on web), pointer otherwise.
  static InputMode of(BuildContext context) {
    final platform = defaultTargetPlatform;
    final isTouch =
        platform == TargetPlatform.iOS || platform == TargetPlatform.android;
    return isTouch ? InputMode.touch : InputMode.pointer;
  }
}

/// Shortcuts on [BuildContext].
extension LayoutContextX on BuildContext {
  /// Window class of the current width.
  WindowClass get windowClass => WindowClassX.of(this);

  /// Input mode of the current platform.
  InputMode get inputMode => InputModeX.of(this);
}
