import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';

/// Theme choice. `system` follows the device brightness.
enum AppThemeMode {
  /// Follow the device.
  system,

  /// Always light.
  light,

  /// Always dark.
  dark,
}

/// Language choice. `system` follows the device locale.
enum AppLocale {
  /// Follow the device.
  system,

  /// English.
  en,

  /// Indonesian.
  id,
}

/// User-facing settings. Persisted field by field through `KeyValueStore`.
@freezed
abstract class AppSettings with _$AppSettings {
  /// Creates settings. Both fields default to `system`.
  const factory AppSettings({
    @Default(AppThemeMode.system) AppThemeMode themeMode,
    @Default(AppLocale.system) AppLocale locale,
  }) = _AppSettings;

  const AppSettings._();

  /// Value for `MaterialApp.themeMode`.
  ThemeMode get flutterThemeMode => switch (themeMode) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };

  /// Value for `MaterialApp.locale`. Null means follow the device.
  Locale? get flutterLocale => switch (locale) {
    AppLocale.system => null,
    AppLocale.en => const Locale('en'),
    AppLocale.id => const Locale('id'),
  };
}
