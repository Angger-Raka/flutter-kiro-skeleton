import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton/app/env.dart';

/// Registrations for types the app does not own.
@module
abstract class RegisterModule {
  /// Resolved before the graph is ready, so consumers get it synchronously.
  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  /// Build configuration from `--dart-define`s.
  @lazySingleton
  Env get env => Env.fromDartDefines();

  /// The HTTP client that `ApiClient` wraps.
  @lazySingleton
  Dio dio(Env env) => Dio(BaseOptions(baseUrl: env.apiBaseUrl));
}
