import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeleton/app/di/injection.dart';
import 'package:skeleton/app/placeholder/connection_check_cubit.dart';
import 'package:skeleton/app/placeholder/placeholder_page.dart';
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
          builder: (context, state) => BlocProvider(
            create: (_) => getIt<ConnectionCheckCubit>(),
            child: const PlaceholderPage(),
          ),
        ),
      ],
    ),
  ],
);
