import 'package:flutter_test/flutter_test.dart';
import 'package:skeleton/core/error/exceptions.dart';
import 'package:skeleton/core/error/failure.dart';

String describe(Failure f) => switch (f) {
  NetworkFailure() => 'network',
  UnauthorizedFailure() => 'unauthorized',
  NotFoundFailure() => 'notFound',
  ValidationFailure() => 'validation',
  ServerFailure(:final statusCode) => 'server$statusCode',
  CacheFailure() => 'cache',
  UnexpectedFailure(:final message) => 'unexpected$message',
};

void main() {
  test('each case constructs and the switch is exhaustive', () {
    const cases = <(Failure, String)>[
      (Failure.network(), 'network'),
      (Failure.unauthorized(), 'unauthorized'),
      (Failure.notFound(), 'notFound'),
      (Failure.validation(), 'validation'),
      (Failure.server(statusCode: 500), 'server500'),
      (Failure.cache(), 'cache'),
      (Failure.unexpected(message: 'x'), 'unexpectedx'),
    ];
    for (final (failure, name) in cases) {
      expect(describe(failure), name);
    }
  });

  test('equality is structural', () {
    expect(
      const Failure.server(statusCode: 500),
      const Failure.server(statusCode: 500),
    );
    expect(
      const Failure.server(statusCode: 500) ==
          const Failure.server(statusCode: 502),
      isFalse,
    );
    expect(const Failure.network() == const Failure.cache(), isFalse);
  });

  test('exceptions carry their message', () {
    expect(const CacheException('x').message, 'x');
    expect(const ServerException(statusCode: 500).statusCode, 500);
  });
}
