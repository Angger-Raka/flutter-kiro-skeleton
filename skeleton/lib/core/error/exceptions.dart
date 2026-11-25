/// Base type for errors thrown by data sources. Never crosses into domain:
/// `guardRepository` maps these to a `Failure`.
sealed class AppException implements Exception {
  /// Creates an exception with an optional developer [message].
  const AppException([this.message]);

  /// Developer-facing message.
  final String? message;
}

/// The server answered with an error status.
class ServerException extends AppException {
  /// Creates a [ServerException].
  const ServerException({this.statusCode, String? message}) : super(message);

  /// HTTP status code when known.
  final int? statusCode;
}

/// No connectivity or timeout.
class NetworkException extends AppException {
  /// Creates a [NetworkException].
  const NetworkException([super.message]);
}

/// The request was rejected as invalid (422).
class ValidationException extends AppException {
  /// Creates a [ValidationException].
  const ValidationException({this.fieldErrors, String? message})
    : super(message);

  /// Per-field error messages.
  final Map<String, String>? fieldErrors;
}

/// Authentication is required or denied (401, 403).
class UnauthorizedException extends AppException {
  /// Creates an [UnauthorizedException].
  const UnauthorizedException([super.message]);
}

/// The resource does not exist (404).
class NotFoundException extends AppException {
  /// Creates a [NotFoundException].
  const NotFoundException([super.message]);
}

/// A local cache or key-value operation failed.
class CacheException extends AppException {
  /// Creates a [CacheException].
  const CacheException([super.message]);
}
