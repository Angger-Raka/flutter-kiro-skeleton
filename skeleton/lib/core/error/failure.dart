import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

/// Domain error contract: repositories return `Either<Failure, T>`.
@freezed
sealed class Failure with _$Failure {
  const Failure._();

  /// No connectivity, socket error, or timeout reaching the server.
  const factory Failure.network({String? message}) = NetworkFailure;

  /// Authentication or authorization required or denied (401, 403).
  const factory Failure.unauthorized({String? message}) = UnauthorizedFailure;

  /// Requested resource not found (404).
  const factory Failure.notFound({String? message}) = NotFoundFailure;

  /// Request understood but rejected (422).
  const factory Failure.validation({
    Map<String, String>? fieldErrors,
    String? message,
  }) = ValidationFailure;

  /// Server returned another error status.
  const factory Failure.server({int? statusCode, String? message}) =
      ServerFailure;

  /// Local cache, key-value, or parse failure.
  const factory Failure.cache({String? message}) = CacheFailure;

  /// Anything unmapped.
  const factory Failure.unexpected({String? message}) = UnexpectedFailure;
}
