import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

(int, int) _pngSize(String path) {
  final bytes = File(path).readAsBytesSync();
  expect(bytes.sublist(0, 8), [137, 80, 78, 71, 13, 10, 26, 10], reason: path);
  final data = ByteData.sublistView(bytes);
  return (data.getUint32(16), data.getUint32(20));
}

void main() {
  const expected = {
    'icon.png': (1024, 1024),
    'icon_foreground.png': (1024, 1024),
    'splash.png': (1024, 1024),
    'og.png': (1200, 630),
  };

  for (final entry in expected.entries) {
    test(
      'assets/branding/${entry.key} is ${entry.value.$1}x${entry.value.$2}',
      () {
        final path = 'assets/branding/${entry.key}';
        expect(File(path).existsSync(), isTrue);
        expect(_pngSize(path), entry.value);
      },
    );
  }
}
