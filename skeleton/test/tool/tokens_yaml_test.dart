import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import '../../tool/radix/radix_scales.dart';

void main() {
  test('default tokens.yaml parses and names only known scales', () {
    final doc =
        loadYaml(File('design/tokens.yaml').readAsStringSync()) as YamlMap;
    expect(doc['neutral'], 'sand');
    expect(doc['primary'], 'neutral');
    expect(doc['radius_control'], 6);
    expect((doc['contrast'] as YamlMap)['tune_faint_text'], isTrue);
    expect(doc['overrides'] as YamlMap, isEmpty);

    final hues = doc['hues'] as YamlMap;
    expect(hues['identity'] as YamlList, isEmpty);
    final names = [
      doc['neutral'],
      for (final role in ['accent', 'success', 'danger', 'warning', 'info'])
        hues[role],
    ];
    for (final name in names) {
      expect(radixScales.containsKey(name), isTrue, reason: '$name');
    }
    final sans = (doc['typography'] as YamlMap)['sans'] as YamlMap;
    expect(sans['weight'], 500);
  });
}
