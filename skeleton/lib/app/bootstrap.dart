import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeleton/app/app_bloc_observer.dart';
import 'package:skeleton/app/di/injection.dart';
import 'package:skeleton/core/log/logger.dart';

/// Routes Flutter framework errors to [logger].
@visibleForTesting
void installFlutterErrorHandler(Logger logger) {
  FlutterError.onError = logger.logFlutterError;
}

/// Routes uncaught platform and async errors to [logger]. The handler returns
/// `true` so the error counts as handled.
@visibleForTesting
void installPlatformErrorHandler(Logger logger) {
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.logError(error, stack);
    return true;
  };
}

/// Initializes bindings, error channels, the bloc observer, and dependency
/// injection, then runs the widget [builder] returns.
Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();

  // shortcut: the logger used before DI is a plain instance; the DI one is a
  // second, stateless instance. Unify if Logger ever gains state.
  final logger = Logger();
  installFlutterErrorHandler(logger);
  installPlatformErrorHandler(logger);
  Bloc.observer = AppBlocObserver(logger);

  await configureDependencies();

  runApp(await builder());
}
