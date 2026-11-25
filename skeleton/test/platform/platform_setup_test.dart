import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Android manifest', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    test('declares the INTERNET permission in the main manifest', () {
      expect(
        manifest,
        contains(
          '<uses-permission android:name="android.permission.INTERNET"/>',
        ),
      );
    });

    test('declares the https query for url_launcher', () {
      expect(
        manifest,
        matches(
          RegExp(
            r'<intent>\s*<action android:name="android\.intent\.action\.VIEW"/>'
            r'\s*<data android:scheme="https"/>\s*</intent>',
          ),
        ),
      );
    });
  });
}
