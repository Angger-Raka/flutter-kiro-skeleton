import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:skeleton/core/error/exceptions.dart';
import 'package:skeleton/core/error/failure.dart';
import 'package:skeleton/core/network/dio_error_mapper.dart';

Failure _status(int code) => mapDioException(
  DioException.badResponse(
    statusCode: code,
    requestOptions: RequestOptions(),
    response: Response<dynamic>(
      requestOptions: RequestOptions(),
      statusCode: code,
    ),
  ),
);

Failure _expectedFor(int c) => switch (c) {
  401 || 403 => const Failure.unauthorized(),
  404 => const Failure.notFound(),
  422 => const Failure.validation(),
  _ => Failure.server(statusCode: c),
};

void main() {
  // Property 5: guardRepository is total.
  property('guardRepository never throws for any thrown object', () {
    forAll(
      combine2(integer(min: 0, max: 7), string()),
      (input) async {
        final (kind, text) = input;
        final thrown = switch (kind) {
          0 => text,
          1 => StateError(text),
          2 => const FormatException('bad'),
          3 => ServerException(statusCode: 500, message: text),
          4 => CacheException(text),
          5 => DioException(requestOptions: RequestOptions(), message: text),
          6 => kind,
          _ => Exception(text),
        };

        final result = await guardRepository<int>(
          // Any object can be thrown in Dart; that is the point.
          // ignore: only_throw_errors
          () async => throw thrown,
        );

        expect(result.isLeft(), isTrue);
      },
    );
  });

  test('guardRepository returns Right for a value', () async {
    expect(
      await guardRepository(() async => 3),
      const Right<Failure, int>(3),
    );
  });

  // Property 6: status mapping.
  property('badResponse status maps per the table for 100 to 599', () {
    forAll(integer(min: 100, max: 599), (c) {
      expect(_status(c), _expectedFor(c));
    });
  });

  test('status mapping holds for every integer 100 to 599', () {
    for (var c = 100; c <= 599; c++) {
      expect(_status(c), _expectedFor(c), reason: 'status $c');
    }
  });

  test('specific statuses get their subtype, others map to server', () {
    expect(_status(401), isA<UnauthorizedFailure>());
    expect(_status(403), isA<UnauthorizedFailure>());
    expect(_status(404), isA<NotFoundFailure>());
    expect(_status(422), isA<ValidationFailure>());
    for (final c in [400, 409, 429, 500, 503]) {
      expect(_status(c), isA<ServerFailure>(), reason: 'status $c');
    }
  });

  // Property 7: connectivity mapping.
  property('connectivity types map to NetworkFailure', () {
    forAll(
      constantFrom(const [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.connectionError,
      ]),
      (type) {
        final failure = mapDioException(
          DioException(requestOptions: RequestOptions(), type: type),
        );
        expect(failure, isA<NetworkFailure>());
      },
    );
  });

  group('other cases', () {
    test('badResponse without a status maps to server with null status', () {
      final failure = mapDioException(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.badResponse,
        ),
      );
      expect(failure, const Failure.server());
    });

    test('cancel maps to unexpected', () {
      final failure = mapDioException(
        DioException.requestCancelled(
          requestOptions: RequestOptions(),
          reason: 'x',
        ),
      );
      expect(failure, isA<UnexpectedFailure>());
    });

    test('AppException subtypes map to the matching Failure', () {
      expect(
        mapAppException(const ServerException(statusCode: 500)),
        const Failure.server(statusCode: 500),
      );
      expect(
        mapAppException(const NetworkException()),
        const Failure.network(),
      );
      expect(
        mapAppException(const ValidationException()),
        const Failure.validation(),
      );
      expect(
        mapAppException(const UnauthorizedException()),
        const Failure.unauthorized(),
      );
      expect(
        mapAppException(const NotFoundException()),
        const Failure.notFound(),
      );
      expect(
        mapAppException(const CacheException('c')),
        const Failure.cache(message: 'c'),
      );
    });
  });
}
