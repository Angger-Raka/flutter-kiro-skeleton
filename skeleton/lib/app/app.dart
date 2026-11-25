import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skeleton/app/di/injection.dart';
import 'package:skeleton/app/router/routes.dart';
import 'package:skeleton/core/l10n/app_localizations.dart';
import 'package:skeleton/core/layout/window_class.dart';
import 'package:skeleton/core/settings/app_settings.dart';
import 'package:skeleton/core/settings/app_settings_cubit.dart';
import 'package:skeleton/core/theme/app_theme.dart';

/// Root widget: `MaterialApp.router` wired to the saved settings.
///
/// It owns the one [AppSettingsCubit] and provides it to the whole tree, so the
/// placeholder page and this widget share one instance. The cubit loads the
/// stored values before the first frame.
class App extends StatefulWidget {
  /// Creates the app.
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AppSettingsCubit _settings = getIt<AppSettingsCubit>()..load();
  late final GoRouter _router = buildRouter();

  @override
  void dispose() {
    _router.dispose();
    unawaited(_settings.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: _settings,
    child: BlocBuilder<AppSettingsCubit, AppSettings>(
      builder: (context, settings) => MaterialApp.router(
        routerConfig: _router,
        onGenerateTitle: (context) =>
            AppLocalizations.of(context).placeholderTitle,
        themeMode: settings.flutterThemeMode,
        // null follows the device; an unsupported device locale resolves to
        // the first supported one, `en`.
        locale: settings.flutterLocale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        // The window class and input mode are only known under MediaQuery, so
        // the theme is built here instead of in `theme:`.
        builder: (context, child) {
          final brightness = switch (settings.themeMode) {
            AppThemeMode.light => Brightness.light,
            AppThemeMode.dark => Brightness.dark,
            AppThemeMode.system => MediaQuery.platformBrightnessOf(context),
          };
          return Theme(
            data: buildTheme(
              brightness,
              context.windowClass,
              context.inputMode,
            ),
            child: child!,
          );
        },
      ),
    ),
  );
}
