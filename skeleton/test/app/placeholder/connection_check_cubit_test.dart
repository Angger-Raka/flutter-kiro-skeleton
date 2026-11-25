import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skeleton/app/env.dart';
import 'package:skeleton/app/placeholder/connection_check_cubit.dart';
import 'package:skeleton/app/placeholder/connection_check_state.dart';
import 'package:skeleton/core/error/exceptions.dart';
import 'package:skeleton/core/error/failure.dart';
import 'package:skeleton/core/log/logger.dart';
import 'package:skeleton/core/network/api_client.dart';

class _MockApiClient extends Mock implements ApiClient {}

class _MockLogger extends Mock implements Logger {}

const _env = Env(flavor: 'dev', apiBaseUrl: '', healthUrl: 'https://a.test');

DioException _status(int code) => DioException(
  requestOptions: RequestOptions(path: _env.healthUrl),
  type: DioExceptionType.badResponse,
  response: Response<void>(
    requestOptions: RequestOptions(path: _env.healthUrl),
    statusCode: code,
  ),
);

void main() {
  late _MockApiClient api;
  late _MockLogger logger;

  setUp(() {
    api = _MockApiClient();
    logger = _MockLogger();
  });

  ConnectionCheckCubit build() => ConnectionCheckCubit(api, _env, logger);

  blocTest<ConnectionCheckCubit, ConnectionCheckState>(
    'emits loading then success on a 2xx response',
    setUp: () => when(() => api.get<void>(any())).thenAnswer(
      (_) async => Response<void>(requestOptions: RequestOptions()),
    ),
    build: build,
    act: (c) => c.check(),
    expect: () => const [
      ConnectionCheckState.loading(),
      ConnectionCheckState.success(),
    ],
    verify: (_) {
      verify(() => api.get<void>('https://a.test')).called(1);
      verifyNever(() => logger.logInfo(any()));
    },
  );

  final failures = <String, (Object, Failure)>{
    'network': (
      DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.connectionError,
      ),
      const Failure.network(),
    ),
    'unauthorized': (_status(401), const Failure.unauthorized()),
    'notFound': (_status(404), const Failure.notFound()),
    'validation': (_status(422), const Failure.validation()),
    'server': (_status(500), const Failure.server(statusCode: 500)),
    'cache': (const CacheException('x'), const Failure.cache(message: 'x')),
    'unexpected': (
      StateError('x'),
      const Failure.unexpected(message: 'Bad state: x'),
    ),
  };

  for (final entry in failures.entries) {
    final (error, expected) = entry.value;
    blocTest<ConnectionCheckCubit, ConnectionCheckState>(
      'emits failure(${entry.key}) and logs it',
      setUp: () => when(() => api.get<void>(any())).thenThrow(error),
      build: build,
      act: (c) => c.check(),
      expect: () => [
        const ConnectionCheckState.loading(),
        ConnectionCheckState.failure(expected),
      ],
      verify: (_) => verify(() => logger.logInfo(any())).called(1),
    );
  }

  blocTest<ConnectionCheckCubit, ConnectionCheckState>(
    'two check() calls in a row send one request',
    setUp: () => when(() => api.get<void>(any())).thenAnswer(
      (_) async => Response<void>(requestOptions: RequestOptions()),
    ),
    build: build,
    act: (c) async {
      final first = c.check();
      await c.check();
      await first;
    },
    expect: () => const [
      ConnectionCheckState.loading(),
      ConnectionCheckState.success(),
    ],
    verify: (_) => verify(() => api.get<void>(any())).called(1),
  );
}
