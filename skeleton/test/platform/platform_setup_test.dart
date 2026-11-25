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

  group('macOS entitlements', () {
    for (final name in ['DebugProfile', 'Release']) {
      test('$name sets network.client to true', () {
        final plist = File(
          'macos/Runner/$name.entitlements',
        ).readAsStringSync();
        expect(
          plist,
          matches(
            RegExp(
              r'<key>com\.apple\.security\.network\.client</key>\s*<true/>',
            ),
          ),
        );
      });
    }
  });

  test('iOS Info.plist has no NSAppTransportSecurity key', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    expect(plist, isNot(contains('NSAppTransportSecurity')));
  });
}
