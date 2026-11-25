import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:skeleton/core/settings/app_settings.dart';
import 'package:skeleton/core/settings/app_settings_cubit.dart';

import '../../support/in_memory_key_value_store.dart';

const _themeKey = 'settings.themeMode';
const _localeKey = 'settings.locale';

void main() {
  // Property 1: an empty store gives defaults.
  property('empty store loads the defaults', () {
    forAll(constant(null), (_) {
      final cubit = AppSettingsCubit(InMemoryKeyValueStore())..load();

      expect(cubit.state, const AppSettings());
    });
  });

  test('state before load is the default', () {
    expect(
      AppSettingsCubit(InMemoryKeyValueStore()).state,
      const AppSettings(),
    );
  });

  // Property 2: write, new cubit, load, same values for all 9 combinations.
  property('settings survive a restart for all combinations', () {
    forAll(
      combine2(
        constantFrom(AppThemeMode.values),
        constantFrom(AppLocale.values),
      ),
      (input) async {
        final (mode, locale) = input;
        final store = InMemoryKeyValueStore();
        final first = AppSettingsCubit(store);
        await first.setThemeMode(mode);
        await first.setLocale(locale);

        final second = AppSettingsCubit(store)..load();

        expect(second.state, AppSettings(themeMode: mode, locale: locale));
      },
    );
  });

  test('all 9 combinations round-trip', () async {
    for (final mode in AppThemeMode.values) {
      for (final locale in AppLocale.values) {
        final store = InMemoryKeyValueStore();
        final first = AppSettingsCubit(store);
        await first.setThemeMode(mode);
        await first.setLocale(locale);

        final second = AppSettingsCubit(store)..load();

        expect(second.state, AppSettings(themeMode: mode, locale: locale));
      }
    }
  });

  // Property 3: any string that is not an enum name gives system.
  property('unknown stored strings fall back to system', () {
    final names = {
      ...AppThemeMode.values.map((e) => e.name),
      ...AppLocale.values.map((e) => e.name),
    };
    forAll(string().filter((s) => !names.contains(s)), (s) {
      final cubit = AppSettingsCubit(
        InMemoryKeyValueStore({_themeKey: s, _localeKey: s}),
      )..load();

      expect(cubit.state, const AppSettings());
    });
  });

  blocTest<AppSettingsCubit, AppSettings>(
    'emits the new value and saves it',
    build: () => AppSettingsCubit(InMemoryKeyValueStore()),
    act: (cubit) => cubit.setThemeMode(AppThemeMode.dark),
    expect: () => [const AppSettings(themeMode: AppThemeMode.dark)],
  );

  blocTest<AppSettingsCubit, AppSettings>(
    'a save failure keeps the in-memory value and does not throw',
    build: () => AppSettingsCubit(InMemoryKeyValueStore()..failWrites = true),
    act: (cubit) async {
      await cubit.setThemeMode(AppThemeMode.light);
      await cubit.setLocale(AppLocale.id);
    },
    expect: () => [
      const AppSettings(themeMode: AppThemeMode.light),
      const AppSettings(themeMode: AppThemeMode.light, locale: AppLocale.id),
    ],
    verify: (cubit) => expect(
      cubit.state,
      const AppSettings(themeMode: AppThemeMode.light, locale: AppLocale.id),
    ),
  );
}
