// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:skeleton/app/di/register_module.dart' as _i141;
import 'package:skeleton/app/env.dart' as _i9;
import 'package:skeleton/core/log/logger.dart' as _i854;
import 'package:skeleton/core/network/api_client.dart' as _i940;
import 'package:skeleton/core/services/clipboard_service.dart' as _i647;
import 'package:skeleton/core/services/link_launcher.dart' as _i886;
import 'package:skeleton/core/settings/app_settings_cubit.dart' as _i523;
import 'package:skeleton/core/storage/key_value_store.dart' as _i328;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i9.Env>(() => registerModule.env);
    gh.lazySingleton<_i854.Logger>(() => _i854.Logger());
    gh.lazySingleton<_i647.ClipboardService>(
      () => const _i647.ClipboardService(),
    );
    gh.lazySingleton<_i886.LinkLauncher>(() => const _i886.LinkLauncher());
    gh.lazySingleton<_i328.KeyValueStore>(
      () => _i328.SharedPrefsKeyValueStore(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i523.AppSettingsCubit>(
      () => _i523.AppSettingsCubit(gh<_i328.KeyValueStore>()),
    );
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio(gh<_i9.Env>()));
    gh.lazySingleton<_i940.ApiClient>(() => _i940.ApiClient(gh<_i361.Dio>()));
    return this;
  }
}

class _$RegisterModule extends _i141.RegisterModule {}
