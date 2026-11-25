import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skeleton/app/di/injection.dart';
import 'package:skeleton/app/placeholder/connection_check_cubit.dart';
import 'package:skeleton/app/placeholder/connection_check_state.dart';
import 'package:skeleton/app/placeholder/placeholder_page.dart';
import 'package:skeleton/app/router/app_shell.dart';
import 'package:skeleton/app/router/routes.dart';
import 'package:skeleton/core/l10n/app_localizations.dart';
import 'package:skeleton/core/settings/app_settings.dart';
import 'package:skeleton/core/settings/app_settings_cubit.dart';

class MockSettings extends MockCubit<AppSettings> implements AppSettingsCubit {}

class MockCheck extends MockCubit<ConnectionCheckState>
    implements ConnectionCheckCubit {}

void main() {
  tearDown(resetDependencies);

  testWidgets('the root route renders PlaceholderPage inside AppShell', (
    tester,
  ) async {
    final settings = MockSettings();
    when(() => settings.state).thenReturn(const AppSettings());
    final check = MockCheck();
    when(() => check.state).thenReturn(const ConnectionCheckState.idle());
    getIt.registerFactory<ConnectionCheckCubit>(() => check);

    await tester.pumpWidget(
      BlocProvider<AppSettingsCubit>.value(
        value: settings,
        child: MaterialApp.router(
          routerConfig: buildRouter(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppShell), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppShell),
        matching: find.byType(PlaceholderPage),
      ),
      findsOneWidget,
    );
  });

  test('AppShell has no rail, navigation bar, or bottom bar', () {
    final source = File('lib/app/router/app_shell.dart').readAsStringSync();
    for (final name in [
      'NavigationRail',
      'NavigationBar',
      'BottomNavigationBar',
    ]) {
      expect(source, isNot(contains(name)));
    }
  });
}
