import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:skeleton/app/env.dart';

void main() {
  test('defaults apply when no define is passed', () {
    final env = Env.fromDartDefines();
    expect(env.flavor, 'dev');
    expect(env.apiBaseUrl, isEmpty);
    expect(env.isProd, isFalse);
  });

  // Default run: the default URL. With
  // `--dart-define=HEALTH_URL=https://a.test`: the override.
  test('HEALTH_URL uses the default, or the override when defined', () {
    const override = String.fromEnvironment('HEALTH_URL');
    expect(
      Env.fromDartDefines().healthUrl,
      override.isEmpty ? 'https://example.com' : override,
    );
  });

  test('isProd is true only for the prod flavor', () {
    const prod = Env(flavor: 'prod', apiBaseUrl: '', healthUrl: '');
    expect(prod.isProd, isTrue);
  });

  test('env/example.json keys equal the keys Env reads', () {
    final json =
        jsonDecode(File('env/example.json').readAsStringSync())
            as Map<String, dynamic>;
    final source = File('lib/app/env.dart').readAsStringSync();
    final read = RegExp(
      r"fromEnvironment\(\s*'(\w+)'",
    ).allMatches(source).map((m) => m[1]!).toSet();
    expect(json.keys.toSet(), read);
  });
}
