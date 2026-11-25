import 'package:flutter/foundation.dart';

/// Immutable configuration read from `--dart-define`s. No secrets in code.
@immutable
class Env {
  /// Creates an [Env] from explicit values.
  const Env({
    required this.flavor,
    required this.apiBaseUrl,
    required this.healthUrl,
  });

  /// Reads all values from compile-time `--dart-define` or
  /// `--dart-define-from-file`.
  factory Env.fromDartDefines() => const Env(
    flavor: String.fromEnvironment('FLAVOR', defaultValue: 'dev'),
    apiBaseUrl: String.fromEnvironment('API_BASE_URL'),
    healthUrl: String.fromEnvironment(
      'HEALTH_URL',
      defaultValue: 'https://example.com',
    ),
  );

  /// Build flavor, for example `dev` or `prod`.
  final String flavor;

  /// Base URL of the app's API. Empty until an app sets it.
  final String apiBaseUrl;

  /// Target of the placeholder page's "Check connection" button. Absolute URL.
  final String healthUrl;

  /// Whether this is the production flavor.
  bool get isProd => flavor == 'prod';
}
