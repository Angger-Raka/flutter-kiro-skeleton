import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:skeleton/core/error/exceptions.dart';
import 'package:skeleton/core/settings/app_settings.dart';
import 'package:skeleton/core/storage/key_value_store.dart';

/// Loads, exposes, and persists [AppSettings].
@injectable
class AppSettingsCubit extends Cubit<AppSettings> {
  /// Creates the cubit with default settings. Call [load] to read the store.
  AppSettingsCubit(this._store) : super(const AppSettings());

  final KeyValueStore _store;

  static const _themeModeKey = 'settings.themeMode';
  static const _localeKey = 'settings.locale';

  /// Reads the stored values. A missing or unknown value becomes `system`.
  void load() {
    emit(
      AppSettings(
        themeMode: _parse(
          _store.getString(_themeModeKey),
          AppThemeMode.values,
          AppThemeMode.system,
        ),
        locale: _parse(
          _store.getString(_localeKey),
          AppLocale.values,
          AppLocale.system,
        ),
      ),
    );
  }

  /// Applies [mode] now, then saves it.
  Future<void> setThemeMode(AppThemeMode mode) async {
    emit(state.copyWith(themeMode: mode));
    await _save(_themeModeKey, mode.name);
  }

  /// Applies [locale] now, then saves it.
  Future<void> setLocale(AppLocale locale) async {
    emit(state.copyWith(locale: locale));
    await _save(_localeKey, locale.name);
  }

  /// A failed save keeps the in-memory value for the session.
  Future<void> _save(String key, String value) async {
    try {
      await _store.setString(key, value);
    } on CacheException {
      // The new value stays in memory; it is lost at restart.
    }
  }

  static T _parse<T extends Enum>(String? raw, List<T> values, T fallback) {
    for (final value in values) {
      if (value.name == raw) {
        return value;
      }
    }
    return fallback;
  }
}
