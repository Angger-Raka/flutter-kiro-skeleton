import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:skeleton/app/placeholder/connection_check_cubit.dart';
import 'package:skeleton/app/placeholder/connection_check_state.dart';
import 'package:skeleton/app/placeholder/placeholder_page.dart';
import 'package:skeleton/core/error/failure.dart';
import 'package:skeleton/core/l10n/app_localizations.dart';
import 'package:skeleton/core/layout/window_class.dart';
import 'package:skeleton/core/settings/app_settings.dart';
import 'package:skeleton/core/settings/app_settings_cubit.dart';
import 'package:skeleton/core/theme/app_theme.dart';
import 'package:skeleton/core/theme/tactile/pressable.dart';
import 'package:skeleton/core/theme/tactile/surface.dart';

class MockSettings extends MockCubit<AppSettings> implements AppSettingsCubit {}

class MockCheck extends MockCubit<ConnectionCheckState>
    implements ConnectionCheckCubit {}

late MockSettings settings;
late MockCheck check;

Future<void> pump(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  Brightness brightness = Brightness.light,
  AppSettings state = const AppSettings(),
  ConnectionCheckState checkState = const ConnectionCheckState.idle(),
}) async {
  when(() => settings.state).thenReturn(state);
  when(() => settings.setThemeMode(any())).thenAnswer((_) async {});
  when(() => settings.setLocale(any())).thenAnswer((_) async {});
  when(() => check.state).thenReturn(checkState);
  when(() => check.check()).thenAnswer((_) async {});
  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<AppSettingsCubit>.value(value: settings),
        BlocProvider<ConnectionCheckCubit>.value(value: check),
      ],
      child: MaterialApp(
        locale: locale,
        theme: buildTheme(brightness, WindowClass.mobile, InputMode.pointer),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: PlaceholderPage()),
      ),
    ),
  );
  await tester.pump();
}

Pressable pressableWith(WidgetTester tester, String label) =>
    tester.widget<Pressable>(find.widgetWithText(Pressable, label));

Color? fillBehind(WidgetTester tester, String label) {
  final box = find
      .descendant(
        of: find.widgetWithText(Pressable, label),
        matching: find.byType(DecoratedBox),
      )
      .evaluate()
      .map((e) => (e.widget as DecoratedBox).decoration)
      .whereType<BoxDecoration>()
      .where((d) => d.borderRadius != null)
      .map((d) => d.color)
      .toList();
  // Outer entries are the surface fill and shadow; the last is the selection.
  return box.last;
}

void main() {
  setUpAll(() {
    registerFallbackValue(AppThemeMode.system);
    registerFallbackValue(AppLocale.system);
  });
  setUp(() {
    settings = MockSettings();
    check = MockCheck();
  });

  for (final brightness in Brightness.values) {
    for (final locale in const [Locale('en'), Locale('id')]) {
      group('${brightness.name} ${locale.languageCode}', () {
        testWidgets('theme and locale buttons call the settings cubit', (
          tester,
        ) async {
          await pump(tester, locale: locale, brightness: brightness);
          final l10n = await AppLocalizations.delegate.load(locale);

          await tester.tap(find.text(l10n.themeDark));
          verify(() => settings.setThemeMode(AppThemeMode.dark)).called(1);
          await tester.tap(find.text(l10n.themeLight));
          verify(() => settings.setThemeMode(AppThemeMode.light)).called(1);
          await tester.tap(find.text(l10n.themeSystem).first);
          verify(() => settings.setThemeMode(AppThemeMode.system)).called(1);

          await tester.tap(find.text(l10n.localeEnglish));
          verify(() => settings.setLocale(AppLocale.en)).called(1);
          await tester.tap(find.text(l10n.localeIndonesian));
          verify(() => settings.setLocale(AppLocale.id)).called(1);
          await tester.tap(find.text(l10n.localeSystem).last);
          verify(() => settings.setLocale(AppLocale.system)).called(1);
        });

        testWidgets('the selected control differs from the others', (
          tester,
        ) async {
          await pump(
            tester,
            locale: locale,
            brightness: brightness,
            state: const AppSettings(themeMode: AppThemeMode.dark),
          );
          final l10n = await AppLocalizations.delegate.load(locale);
          final selected = fillBehind(tester, l10n.themeDark);
          expect(selected, isNotNull);
          expect(fillBehind(tester, l10n.themeLight), isNull);
          expect(fillBehind(tester, l10n.themeLight), isNot(selected));
        });

        testWidgets('loading disables the button and shows the label', (
          tester,
        ) async {
          await pump(
            tester,
            locale: locale,
            brightness: brightness,
            checkState: const ConnectionCheckState.loading(),
          );
          final l10n = await AppLocalizations.delegate.load(locale);
          expect(l10n.checkConnectionLoading, endsWith('…'));
          expect(
            pressableWith(tester, l10n.checkConnectionLoading).onPressed,
            isNull,
          );
          expect(find.text(l10n.checkConnection), findsNothing);
        });

        testWidgets('idle button calls check()', (tester) async {
          await pump(tester, locale: locale, brightness: brightness);
          final l10n = await AppLocalizations.delegate.load(locale);
          await tester.tap(find.text(l10n.checkConnection));
          verify(() => check.check()).called(1);
        });

        testWidgets('the success message shows', (tester) async {
          await pump(
            tester,
            locale: locale,
            brightness: brightness,
            checkState: const ConnectionCheckState.success(),
          );
          final l10n = await AppLocalizations.delegate.load(locale);
          expect(find.text(l10n.checkConnectionSuccess), findsOneWidget);
        });

        testWidgets('the failure message shows', (tester) async {
          final l10n = await AppLocalizations.delegate.load(locale);
          await pump(
            tester,
            locale: locale,
            brightness: brightness,
            checkState: const ConnectionCheckState.failure(
              Failure.network(),
            ),
          );
          expect(find.text(l10n.failureNetworkTitle), findsOneWidget);
          expect(find.text(l10n.failureNetworkBody), findsOneWidget);
        });
      });
    }
  }

  group('hover and pressed fill show above the surface (Req 16.2)', () {
    // `_ChoiceButton` "Dark" (not selected): its raised surface fill is opaque.
    final finder = find.widgetWithText(Pressable, 'Dark');
    final surface = find.descendant(
      of: finder,
      matching: find.byType(TactileSurface),
    );

    /// Hover fill of the raised surface (local ground + 1).
    Color hoverFill(WidgetTester tester) => SurfaceScope.of(
      tester.element(find.descendant(of: surface, matching: find.byType(Text))),
    ).hoverFill;

    /// Colours painted inside the surface fill, outermost first.
    List<Color?> painted(WidgetTester tester) => find
        .descendant(of: surface, matching: find.byType(DecoratedBox))
        .evaluate()
        .map((e) => (e.widget as DecoratedBox).decoration)
        .whereType<BoxDecoration>()
        .map((d) => d.color)
        .skip(1) // the surface's own fill
        .toList();

    for (final brightness in Brightness.values) {
      testWidgets(
        'mouse hover, ${brightness.name}',
        variant: TargetPlatformVariant.only(TargetPlatform.macOS),
        (tester) async {
          await pump(tester, brightness: brightness);
          final fill = hoverFill(tester);
          expect(painted(tester).first, fill.withAlpha(0));

          final mouse = await tester.createGesture(
            kind: PointerDeviceKind.mouse,
          );
          await mouse.addPointer(location: const Offset(-50, -50));
          addTearDown(mouse.removePointer);
          await mouse.moveTo(tester.getCenter(finder));
          await tester.pumpAndSettle();
          expect(painted(tester).first, fill);

          await mouse.moveTo(const Offset(-50, -50));
          await tester.pumpAndSettle();
          expect(painted(tester).first, fill.withAlpha(0));
        },
      );

      testWidgets('touch press, ${brightness.name}', (tester) async {
        await pump(tester, brightness: brightness);
        final fill = hoverFill(tester);
        final down = await tester.startGesture(tester.getCenter(finder));
        await tester.pumpAndSettle();
        expect(painted(tester).first, fill);
        await down.up();
        await tester.pumpAndSettle();
        expect(painted(tester).first, fill.withAlpha(0));
      });
    }
  });

  test('the page source has no Material button widgets', () {
    final source = File(
      'lib/app/placeholder/placeholder_page.dart',
    ).readAsStringSync();
    for (final name in [
      'SegmentedButton',
      'ElevatedButton',
      'TextButton',
      'OutlinedButton',
    ]) {
      expect(source, isNot(contains(name)));
    }
  });
}
