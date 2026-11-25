import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:skeleton/core/error/exceptions.dart';
import 'package:skeleton/core/error/failure.dart';

/// Runs [body] and maps anything it throws to a [Failure].
///
/// Data sources throw `*Exception` or `DioException`. This is the one place
/// they become a [Failure], so repositories return `Either<Failure, T>`
/// without their own try/catch. It never throws.
Future<Either<Failure, T>> guardRepository<T>(Future<T> Function() body) async {
  try {
    return Right(await body());
  } on DioException catch (e) {
    return Left(mapDioException(e));
  } on AppException catch (e) {
    return Left(mapAppException(e));
    // Anything can be thrown in Dart, and this function must never throw.
    // ignore: avoid_catches_without_on_clauses
  } catch (e) {
    return Left(Failure.unexpected(message: e.toString()));
  }
}

/// Maps a [DioException] to a [Failure].
@visibleForTesting
Failure mapDioException(DioException e) => switch (e.type) {
  DioExceptionType.connectionTimeout ||
  DioExceptionType.sendTimeout ||
  DioExceptionType.receiveTimeout ||
  DioExceptionType.connectionError => const Failure.network(),
  DioExceptionType.badResponse => mapStatus(e.response?.statusCode),
  DioExceptionType.cancel ||
  DioExceptionType.transformTimeout ||
  DioExceptionType.badCertificate ||
  DioExceptionType.unknown => Failure.unexpected(message: e.message),
};

/// Maps an [AppException] to a [Failure].
@visibleForTesting
Failure mapAppException(AppException e) => switch (e) {
  ServerException(:final statusCode, :final message) => Failure.server(
    statusCode: statusCode,
    message: message,
  ),
  NetworkException(:final message) => Failure.network(message: message),
  ValidationException(:final fieldErrors, :final message) => Failure.validation(
    fieldErrors: fieldErrors,
    message: message,
  ),
  UnauthorizedException(:final message) => Failure.unauthorized(
    message: message,
  ),
  NotFoundException(:final message) => Failure.notFound(message: message),
  CacheException(:final message) => Failure.cache(message: message),
};

/// Maps an HTTP status code: 401 and 403 unauthorized, 404 notFound,
/// 422 validation, everything else server with the status.
@visibleForTesting
Failure mapStatus(int? code) => switch (code) {
  401 || 403 => const Failure.unauthorized(),
  404 => const Failure.notFound(),
  422 => const Failure.validation(),
  _ => Failure.server(statusCode: code),
};
