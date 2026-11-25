import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

const _mask = '***';

// Header values: the whole value goes, whatever the scheme (Basic, Digest,
// Bearer) and however many tokens it holds. Cookies hold `;` separators.
final _headerValue = RegExp(
  r'''((?:authorization|cookie|set-cookie)["']?\s*[:=]\s*)("[^"]*"|'[^']*'|[^\r\n]+)''',
  caseSensitive: false,
);
final _bearer = RegExp(r'bearer\s+[A-Za-z0-9\-._~+/]+=*', caseSensitive: false);
final _secretField = RegExp(
  r'''(["']?[\w-]*(?:password|token|secret|api[_-]?key)[\w-]*["']?\s*[:=]\s*)("[^"]*"|'[^']*'|[^\s&,;}"']+)''',
  caseSensitive: false,
);

/// Masks secrets in [input]: whole `Authorization`, `Cookie` and
/// `Set-Cookie` header values, bearer tokens, and fields named like
/// `password`, `token`, `secret`, `api_key` or `x-api-key` (JSON, query
/// string, or `key=value`).
///
/// `debugPrint` is not stripped in release builds, so every message goes
/// through this function before printing.
String redact(String input) => input
    .replaceAllMapped(_headerValue, (m) => '${m[1]}${_masked(m[2]!)}')
    .replaceAllMapped(_bearer, (_) => 'Bearer $_mask')
    .replaceAllMapped(_secretField, (m) => '${m[1]}${_masked(m[2]!)}');

String _masked(String value) {
  final quote = value.startsWith('"') || value.startsWith("'") ? value[0] : '';
  return '$quote$_mask$quote';
}

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
