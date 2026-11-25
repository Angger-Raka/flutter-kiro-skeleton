import 'package:flutter/material.dart';

/// Thin shell: a `Scaffold` with a safe area around [child].
///
/// Theme and sizes follow the window class through `app.dart`. There is no
/// rail, tab bar, or panel here.
// TODO(core-widgets-and-templates): replace with AdaptiveScaffold.
class AppShell extends StatelessWidget {
  /// Creates the shell around [child].
  const AppShell({required this.child, super.key});

  /// The current route's page.
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: child));
}
