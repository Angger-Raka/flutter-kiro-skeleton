import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  final readme = File('README.md').readAsStringSync();
  final pubspec = loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;

  test('names the pinned Flutter and Dart versions', () {
    expect(readme, contains('3.44.8'));
    expect(readme, contains('3.12.2'));
  });

  test('lists every package with its pubspec version', () {
    for (final section in ['dependencies', 'dev_dependencies']) {
      final packages = pubspec[section] as YamlMap;
      for (final entry in packages.entries) {
        final name = entry.key as String;
        // Table rows look like: | `dio` | `5.11.1` |
        final row = readme
            .split('\n')
            .where((l) => l.contains('`$name`'))
            .toList();
        expect(row, isNotEmpty, reason: '$name is not in the README');
        final version = entry.value;
        if (version is String) {
          expect(
            row.any((l) => l.contains(version)),
            isTrue,
            reason: '$name $version is not in the README',
          );
        }
      }
    }
  });

  test('states the policies the requirements ask for', () {
    expect(readme, contains('json_serializable'));
    expect(readme, contains('*.freezed.dart'));
    expect(readme, contains('injection.config.dart'));
    expect(readme, contains('tokens.g.dart'));
    expect(readme, contains('core/log'));
    expect(readme, contains('3.50'));
  });
}
