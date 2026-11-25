import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:skeleton/app/router/app_shell.dart';
import 'package:skeleton/app/router/route_names.dart';

/// Builds the app router. This is the only file that declares a `GoRoute`.
GoRouter buildRouter() => GoRouter(
  initialLocation: RouteNames.root,
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: RouteNames.root,
          // Temporary until task 6.6 adds PlaceholderPage.
          builder: (context, state) => const SizedBox(key: Key('root-page')),
        ),
      ],
    ),
  ],
);
