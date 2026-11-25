import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeleton/core/l10n/app_localizations.dart';
import 'package:skeleton/core/utils/extensions.dart';

Map<String, String> _strings(String locale) {
  final json =
      jsonDecode(File('lib/core/l10n/app_$locale.arb').readAsStringSync())
          as Map<String, dynamic>;
  return {
    for (final e in json.entries)
      if (!e.key.startsWith('@')) e.key: e.value as String,
  };
}

void main() {
  final en = _strings('en');
  final id = _strings('id');

  test('en and id have the same keys', () {
    expect(id.keys.toSet(), en.keys.toSet());
  });

  test('no value contains an em dash', () {
    for (final strings in [en, id]) {
      for (final e in strings.entries) {
        expect(e.value.contains('\u2014'), isFalse, reason: e.key);
      }
    }
  });

  test('loading labels end with an ellipsis', () {
    for (final strings in [en, id]) {
      for (final e in strings.entries) {
        if (e.key.endsWith('Loading') || e.key.startsWith('loading')) {
          expect(e.value.endsWith('\u2026'), isTrue, reason: e.key);
        }
      }
    }
  });

  for (final (locale, expected) in [
    (const Locale('en'), ('Dark', 'Check connection')),
    (const Locale('id'), ('Gelap', 'Periksa koneksi')),
  ]) {
    testWidgets('context.l10n resolves in ${locale.languageCode}', (
      tester,
    ) async {
      late String dark;
      late String check;
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) {
              dark = context.l10n.themeDark;
              check = context.l10n.checkConnection;
              return const SizedBox();
            },
          ),
        ),
      );

      expect((dark, check), expected);
    });
  }
}
