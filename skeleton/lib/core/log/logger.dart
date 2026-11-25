import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

const _mask = '***';

final _authorization = RegExp(
  r'''(authorization["']?\s*[:=]\s*["']?)(?:bearer\s+)?[^\s,;"'}]+''',
  caseSensitive: false,
);
final _bearer = RegExp(r'bearer\s+[A-Za-z0-9\-._~+/]+=*', caseSensitive: false);
final _secretField = RegExp(
  r'''(["']?\w*(?:password|token)\w*["']?\s*[:=]\s*)("[^"]*"|'[^']*'|[^\s&,;}"']+)''',
  caseSensitive: false,
);

/// Masks secrets in [input]: `Authorization` header values, bearer tokens,
/// and `password` and `token` fields (JSON, query string, or `key=value`).
///
/// `debugPrint` is not stripped in release builds, so every message goes
/// through this function before printing.
String redact(String input) => input
    .replaceAllMapped(_authorization, (m) => '${m[1]}$_mask')
    .replaceAllMapped(_bearer, (_) => 'Bearer $_mask')
    .replaceAllMapped(_secretField, (m) {
      final value = m[2]!;
      final quote = value.startsWith('"') || value.startsWith("'")
          ? value[0]
          : '';
      return '${m[1]}$quote$_mask$quote';
    });

/// The one logging sink the error handlers and the bloc observer route to.
@lazySingleton
class Logger {
  /// Logs an [error] with its [stack], redacted.
  void logError(Object error, StackTrace? stack, {String? context}) {
    final prefix = context == null ? '' : '[$context] ';
    debugPrint(redact('$prefix$error'));
    if (stack != null) {
      debugPrint(redact(stack.toString()));
    }
  }

  /// Logs a Flutter framework error.
  void logFlutterError(FlutterErrorDetails details) {
    logError(details.exception, details.stack, context: details.library);
  }

  /// Logs an informational [message], redacted.
  void logInfo(String message) => debugPrint(redact(message));
}
