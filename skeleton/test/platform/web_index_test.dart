import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final html = File('web/index.html').readAsStringSync();

  String? meta(String attr, String key) => RegExp(
    '<meta\\s+$attr="$key"\\s+content="([^"]*)"',
  ).firstMatch(html)?.group(1);

  test('has title, description, and favicon', () {
    expect(html, contains('<title>Skeleton</title>'));
    expect(meta('name', 'description'), isNotEmpty);
    expect(html, contains('rel="icon"'));
  });

  test('has Open Graph tags and og:image ends with og.png', () {
    expect(meta('property', 'og:title'), isNotEmpty);
    expect(meta('property', 'og:description'), isNotEmpty);
    expect(meta('property', 'og:image'), endsWith('og.png'));
  });

  test('has the native splash markup and style', () {
    expect(html, contains('splash-screen-style'));
    expect(html, contains('id="splash"'));
  });

  test('manifest name and short_name are Skeleton', () {
    final manifest = File('web/manifest.json').readAsStringSync();
    expect(manifest, contains('"name": "Skeleton"'));
    expect(manifest, contains('"short_name": "Skeleton"'));
  });
}
