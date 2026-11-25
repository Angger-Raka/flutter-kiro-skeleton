import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skeleton/app/app_bloc_observer.dart';
import 'package:skeleton/app/bootstrap.dart';
import 'package:skeleton/core/log/logger.dart';

class _MockLogger extends Mock implements Logger {}

class _FailingCubit extends Cubit<int> {
  _FailingCubit() : super(0);
}

void main() {
  late _MockLogger logger;
  late FlutterExceptionHandler? savedFlutter;
  late ErrorCallback? savedPlatform;

  setUpAll(() {
    registerFallbackValue(const FlutterErrorDetails(exception: 'x'));
    registerFallbackValue(StackTrace.empty);
  });

  setUp(() {
    logger = _MockLogger();
    savedFlutter = FlutterError.onError;
    savedPlatform = PlatformDispatcher.instance.onError;
  });

  tearDown(() {
    FlutterError.onError = savedFlutter;
    PlatformDispatcher.instance.onError = savedPlatform;
  });

  test('FlutterError.onError logs through the logger without throwing', () {
    installFlutterErrorHandler(logger);
    const details = FlutterErrorDetails(exception: 'boom');

    expect(() => FlutterError.onError!(details), returnsNormally);
    verify(() => logger.logFlutterError(details)).called(1);
  });

  test('platform handler logs and returns true', () {
    installPlatformErrorHandler(logger);
    final stack = StackTrace.current;

    final handled = PlatformDispatcher.instance.onError!('boom', stack);

    expect(handled, isTrue);
    verify(() => logger.logError('boom', stack)).called(1);
  });

  test('observer onError logs with the bloc type as context', () {
    final cubit = _FailingCubit();
    final stack = StackTrace.current;

    AppBlocObserver(logger).onError(cubit, 'boom', stack);

    verify(
      () => logger.logError('boom', stack, context: '_FailingCubit'),
    ).called(1);
    addTearDown(cubit.close);
  });
}
