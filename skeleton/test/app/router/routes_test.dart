import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeleton/app/router/app_shell.dart';
import 'package:skeleton/app/router/routes.dart';

void main() {
  testWidgets('the root route renders inside AppShell', (tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: buildRouter()));
    await tester.pumpAndSettle();

    expect(find.byType(AppShell), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppShell),
        matching: find.byKey(const Key('root-page')),
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
