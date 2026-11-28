import 'package:flutter_test/flutter_test.dart';

import '../../../tool/src/create_app_core.dart';

void main() {
  group('validateName', () {
    test('accepts valid package names', () {
      for (final name in ['my_app', 'a', 'app2', 'kiri_shop']) {
        expect(validateName(name), isNull, reason: name);
      }
    });

    test('rejects invalid package names', () {
      for (final name in [
        '',
        'Bad-Name',
        'BadName',
        '1app',
        '_app',
        'my app',
        'my-app',
        'class',
        'flutter',
        'test',
      ]) {
        expect(validateName(name), isNotNull, reason: name);
      }
    });
  });

  group('validateOrg and validateDisplayName', () {
    test('org must be reverse-domain words', () {
      expect(validateOrg('com.example'), isNull);
      expect(validateOrg('dev.angga'), isNull);
      expect(validateOrg('Com.Example'), isNotNull);
      expect(validateOrg('com..example'), isNotNull);
      expect(validateOrg(''), isNotNull);
    });

    test('display name rejects characters that need escaping', () {
      expect(validateDisplayName('My App'), isNull);
      expect(validateDisplayName("Kiri's Café"), isNull);
      for (final bad in ['A"B', 'A<B', 'A&B', r'A\B', 'A\nB', '']) {
        expect(validateDisplayName(bad), isNotNull, reason: bad);
      }
    });

    test('default display name is title case', () {
      expect(defaultDisplayName('my_app'), 'My App');
      expect(defaultDisplayName('shop'), 'Shop');
    });
  });

  group('shouldCopy', () {
    test('skips generated and tool-local entries', () {
      for (final path in [
        'build',
        'build/app/out.txt',
        '.dart_tool/package_config.json',
        'skeleton.iml',
        'lib/foo.iml',
        '.idea/workspace.xml',
        'pubspec.lock',
        'test/repo_tools',
        'test/repo_tools/create_app_test.dart',
        '.fvm/flutter_sdk',
        'android/app/build/outputs/x',
        'ios/Pods/Manifest.lock',
      ]) {
        expect(shouldCopy(path), isFalse, reason: path);
      }
    });

    test('keeps source and the entries that only look similar', () {
      for (final path in [
        'lib/main.dart',
        'pubspec.yaml',
        '.fvmrc',
        'test/tool/color_math_test.dart',
        'test/repo_tools_other/a.dart',
        'lib/build/source.dart',
        'android/app/src/main/AndroidManifest.xml',
        'assets/images/logo.png',
      ]) {
        expect(shouldCopy(path), isTrue, reason: path);
      }
    });
  });

  group('replaceInText', () {
    test('rewrites package imports', () {
      const input =
          "import 'package:skeleton/core/theme.dart';\n"
          "import 'package:flutter/material.dart';\n";
      expect(
        replaceInText(input, name: 'my_app'),
        "import 'package:my_app/core/theme.dart';\n"
        "import 'package:flutter/material.dart';\n",
      );
    });

    test('rewrites the pubspec name line only', () {
      const input = 'name: skeleton\ndescription: skeleton kit\n';
      expect(
        replaceInText(input, name: 'my_app'),
        'name: my_app\ndescription: skeleton kit\n',
      );
    });

    test('leaves permission strings untouched', () {
      const input =
          '<uses-permission android:name="android.permission.INTERNET"/>\n'
          '<data android:scheme="https"/>\n'
          '<key>com.apple.security.network.client</key>\n';
      expect(replaceInText(input, name: 'my_app'), input);
    });
  });

  group('replaceBrickPackage', () {
    test('handles the one-line and the block form', () {
      expect(
        replaceBrickPackage('vars:\n  package: skeleton\n', name: 'my_app'),
        'vars:\n  package: my_app\n',
      );
      expect(
        replaceBrickPackage(
          'vars:\n  package:\n    type: string\n'
          '    default: skeleton\n  name:\n    default: x\n',
          name: 'my_app',
        ),
        'vars:\n  package:\n    type: string\n'
        '    default: my_app\n  name:\n    default: x\n',
      );
    });
  });
}
