import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton/app/di/injection.dart';
import 'package:skeleton/app/di/register_module.dart';
import 'package:skeleton/app/env.dart';
import 'package:skeleton/core/log/logger.dart';
import 'package:skeleton/core/network/api_client.dart';
import 'package:skeleton/core/services/clipboard_service.dart';
import 'package:skeleton/core/services/link_launcher.dart';
import 'package:skeleton/core/settings/app_settings_cubit.dart';
import 'package:skeleton/core/storage/key_value_store.dart';

void _expectResolved() {
  expect(getIt<Env>(), isA<Env>());
  expect(getIt<SharedPreferences>(), isA<SharedPreferences>());
  expect(getIt<Dio>(), isA<Dio>());
  expect(getIt<Logger>(), isA<Logger>());
  expect(getIt<ApiClient>(), isA<ApiClient>());
  expect(getIt<KeyValueStore>(), isA<SharedPrefsKeyValueStore>());
  expect(getIt<LinkLauncher>(), isA<LinkLauncher>());
  expect(getIt<ClipboardService>(), isA<ClipboardService>());
  expect(getIt<AppSettingsCubit>(), isA<AppSettingsCubit>());
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(resetDependencies);

  test('configureDependencies resolves every registration', () async {
    await configureDependencies();
    _expectResolved();
  });

  test('Dio has the connect and receive timeouts', () async {
    await configureDependencies();
    final options = getIt<Dio>().options;
    expect(options.connectTimeout, connectTimeout);
    expect(options.receiveTimeout, receiveTimeout);
  });

  test('a second call succeeds after resetDependencies', () async {
    await configureDependencies();
    await resetDependencies();
    await configureDependencies();
    _expectResolved();
  });
}
