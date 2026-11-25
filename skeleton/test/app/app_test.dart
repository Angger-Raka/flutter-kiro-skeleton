import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton/app/app.dart';
import 'package:skeleton/app/di/injection.dart';
import 'package:skeleton/app/placeholder/placeholder_page.dart';
import 'package:skeleton/core/l10n/app_localizations_en.dart';
import 'package:skeleton/core/l10n/app_localizations_id.dart';
import 'package:skeleton/core/layout/window_class.dart';
import 'package:skeleton/core/theme/tactile/typography.dart';

final AppLocalizationsEn _en = AppLocalizationsEn();
final AppLocalizationsId _id = AppLocalizationsId();

ThemeData _theme(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(PlaceholderPage)));

Future<void> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const App());
  await tester.pumpAndSettle();
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();
  });

  tearDown(resetDependencies);

  testWidgets('follows the device brightness and tracks changes', (
    tester,
  ) async {
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await _pumpApp(tester);
    expect(_theme(tester).brightness, Brightness.dark);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await tester.pumpAndSettle();
    expect(_theme(tester).brightness, Brightness.light);
  });

  testWidgets('a saved Dark and Indonesia survive a restart', (tester) async {
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await _pumpApp(tester);
    expect(_theme(tester).brightness, Brightness.light);

    await tester.tap(find.text(_en.themeDark));
    await tester.pumpAndSettle();
    await tester.tap(find.text(_en.localeIndonesian));
    await tester.pumpAndSettle();
    expect(_theme(tester).brightness, Brightness.dark);
    expect(find.text(_id.themeTitle), findsOneWidget);

    // Restart: drop the tree, then build a new App over the same store.
    await tester.pumpWidget(const SizedBox());
    await _pumpApp(tester);
    expect(_theme(tester).brightness, Brightness.dark);
    expect(find.text(_id.themeTitle), findsOneWidget);
  });

  testWidgets('an unsupported device locale resolves to English', (
    tester,
  ) async {
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    tester.platformDispatcher.localesTestValue = const [Locale('fr')];
    await _pumpApp(tester);
    expect(find.text(_en.themeTitle), findsOneWidget);
  });

  testWidgets('resizing across 768 and 1200 rebuilds the theme only', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(700, 900);
    await _pumpApp(tester);
    await tester.tap(find.text(_en.themeDark));
    await tester.pumpAndSettle();

    double display() =>
        _theme(tester).extension<AppTypography>()!.body.fontSize!;

    final mobile = display();
    tester.view.physicalSize = const Size(800, 900);
    await tester.pumpAndSettle();
    final tablet = display();
    tester.view.physicalSize = const Size(1300, 900);
    await tester.pumpAndSettle();
    final desktop = display();

    expect({mobile, tablet, desktop}.length, greaterThan(1));
    const mode = InputMode.touch; // flutter_test defaults to Android.
    expect(
      mobile,
      AppTypography.build(WindowClass.mobile, mode).body.fontSize,
    );
    expect(
      tablet,
      AppTypography.build(WindowClass.tablet, mode).body.fontSize,
    );
    expect(
      desktop,
      AppTypography.build(WindowClass.desktop, mode).body.fontSize,
    );
    expect(_theme(tester).brightness, Brightness.dark);
  });

  test('main.dart is a single statement calling bootstrap', () {
    final body = File(
      'lib/main.dart',
    ).readAsLinesSync().where((l) => !l.startsWith('import ')).join('\n');
    expect(';'.allMatches(body).length, 1);
    expect(body, contains('bootstrap('));
  });

  test('the template widget test is gone', () {
    expect(File('test/widget_test.dart').existsSync(), isFalse);
  });
}
