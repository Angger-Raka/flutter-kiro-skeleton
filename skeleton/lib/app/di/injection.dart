import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:skeleton/app/di/injection.config.dart';

/// The app's service locator.
final GetIt getIt = GetIt.instance;

/// Registers every dependency. Call once, before `runApp`.
@InjectableInit()
Future<void> configureDependencies() => getIt.init();

/// Test helper: resets [getIt] so [configureDependencies] can run again.
Future<void> resetDependencies() => getIt.reset();
