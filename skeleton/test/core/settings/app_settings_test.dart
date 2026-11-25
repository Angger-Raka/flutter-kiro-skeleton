import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:skeleton/core/settings/app_settings.dart';

void main() {
  test('defaults are system and system', () {
    const settings = AppSettings();

    expect(settings.themeMode, AppThemeMode.system);
    expect(settings.locale, AppLocale.system);
  });

  // Property 4: system means follow the device.
  property('system maps to the device for every enum value', () {
    forAll(
      combine2(
        constantFrom(AppThemeMode.values),
        constantFrom(AppLocale.values),
      ),
      (input) {
        final (mode, locale) = input;
        final settings = AppSettings(themeMode: mode, locale: locale);

        expect(
          settings.flutterThemeMode,
          switch (mode) {
            AppThemeMode.system => ThemeMode.system,
            AppThemeMode.light => ThemeMode.light,
            AppThemeMode.dark => ThemeMode.dark,
          },
        );
        expect(
          settings.flutterLocale,
          switch (locale) {
            AppLocale.system => isNull,
            AppLocale.en => const Locale('en'),
            AppLocale.id => const Locale('id'),
          },
        );
      },
    );
  });

  test('system values follow the device', () {
    expect(
      const AppSettings().flutterThemeMode,
      ThemeMode.system,
    );
    expect(const AppSettings().flutterLocale, isNull);
  });
}
