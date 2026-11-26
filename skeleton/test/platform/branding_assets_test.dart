import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

(int, int) _pngSize(String path) {
  final bytes = File(path).readAsBytesSync();
  expect(bytes.sublist(0, 8), [137, 80, 78, 71, 13, 10, 26, 10], reason: path);
  final data = ByteData.sublistView(bytes);
  return (data.getUint32(16), data.getUint32(20));
}

void main() {
  _blankGuard();
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

/// Share of pixels that differ from the top-left pixel, and the number of
/// distinct colours (a glyph with anti-aliased edges has more than two).
Future<(double, int)> _glyphStats(String path) async {
  final codec = await ui.instantiateImageCodec(File(path).readAsBytesSync());
  final image = (await codec.getNextFrame()).image;
  final data = (await image.toByteData())!.buffer.asUint8List();
  final colours = <int>{};
  var different = 0;
  for (var i = 0; i < data.length; i += 4) {
    final rgba =
        data[i] << 24 | data[i + 1] << 16 | data[i + 2] << 8 | data[i + 3];
    colours.add(rgba);
    if (i > 0 &&
        (data[i] != data[0] ||
            data[i + 1] != data[1] ||
            data[i + 2] != data[2] ||
            data[i + 3] != data[3])) {
      different++;
    }
  }
  return (different / (data.length / 4), colours.length);
}

void _blankGuard() {
  // Regression: the placeholders were once a plain square, so the logo looked
  // empty. A real glyph covers part of the canvas, never all of it.
  for (final file in const [
    'assets/branding/icon.png',
    'assets/branding/icon_foreground.png',
    'assets/branding/splash.png',
    'assets/branding/og.png',
    'web/icons/Icon-512.png',
    'web/splash/img/light-4x.png',
    'web/splash/img/dark-4x.png',
    'android/app/src/main/res/drawable-xxxhdpi/splash.png',
    'ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@3x.png',
    'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png',
  ]) {
    testWidgets('$file shows a glyph, not blank or a plain square', (
      tester,
    ) async {
      final (share, colours) = (await tester.runAsync(
        () => _glyphStats(file),
      ))!;
      expect(share, inInclusiveRange(0.03, 0.5), reason: file);
      expect(colours, greaterThan(4), reason: '$file has no anti-aliased edge');
    });
  }
}
