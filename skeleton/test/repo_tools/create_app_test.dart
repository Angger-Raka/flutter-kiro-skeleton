import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/create_app.dart';
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

  group('runCreateApp', () {
    late Directory temp;
    late Directory repo;
    late Directory out;

    String read(String path) =>
        File('${out.path}/shop/$path').readAsStringSync();

    setUp(() {
      temp = Directory.systemTemp.createTempSync('create_app_test');
      repo = Directory('${temp.path}/repo')..createSync();
      out = Directory('${temp.path}/out')..createSync();
      writeFixtureSkeleton(Directory('${repo.path}/skeleton'));
    });
    tearDown(() => temp.deleteSync(recursive: true));

    Future<int> run(List<String> args) => runCreateApp(
      args,
      repoRoot: repo,
      out: StringBuffer(),
      err: StringBuffer(),
    );

    test('copies the skeleton and sets the identifiers', () async {
      final code = await run([
        'shop',
        '--org',
        'com.acme',
        '--display-name',
        'Acme Shop',
        '--out',
        out.path,
      ]);
      expect(code, 0);
      expect(read('pubspec.yaml'), contains('name: shop'));
      expect(read('lib/main.dart'), contains('package:shop/'));
      final gradle = read('android/app/build.gradle.kts');
      expect(gradle, contains('namespace = "com.acme.shop"'));
      expect(gradle, contains('applicationId = "com.acme.shop"'));
      expect(gradle, isNot(contains('skeleton')));
      expect(
        read('macos/Runner/Configs/AppInfo.xcconfig'),
        contains('PRODUCT_BUNDLE_IDENTIFIER = com.acme.shop'),
      );
      expect(
        read('linux/CMakeLists.txt'),
        contains('APPLICATION_ID "com.acme.shop"'),
      );
      expect(read('windows/CMakeLists.txt'), contains('BINARY_NAME "shop"'));
      expect(read('web/manifest.json'), contains('"name": "Acme Shop"'));
      expect(read('web/index.html'), contains('<title>Acme Shop</title>'));
      expect(read('bricks/feature/brick.yaml'), contains('package: shop'));
      expect(
        read('test/platform/web_index_test.dart'),
        contains('<title>Acme Shop</title>'),
      );
      expect(
        read('android/app/src/main/AndroidManifest.xml'),
        contains('android.permission.INTERNET'),
      );
      expect(
        read('macos/Runner/Release.entitlements'),
        contains('network.client'),
      );
      expect(
        read('android/app/src/main/kotlin/com/acme/shop/MainActivity.kt'),
        contains('package com.acme.shop'),
      );
      expect(Directory('${out.path}/shop/test/repo_tools').existsSync(), false);
      expect(Directory('${out.path}/shop/build').existsSync(), isFalse);
    });

    test('an existing target exits 64 and writes nothing', () async {
      Directory('${out.path}/shop').createSync();
      expect(await run(['shop', '--out', out.path]), exitUsage);
      expect(Directory('${out.path}/shop').listSync(), isEmpty);
    });

    test('bad name, unknown flag and missing value exit 64', () async {
      expect(await run(['Bad-Name', '--out', out.path]), exitUsage);
      expect(await run(['shop', '--nope', '--out', out.path]), exitUsage);
      expect(await run(['shop', '--out']), exitUsage);
      expect(out.listSync(), isEmpty);
    });
  });
}

/// A small skeleton with one file for each rule that J2 checks.
void writeFixtureSkeleton(Directory root) {
  void put(String path, String text) => File('${root.path}/$path')
    ..createSync(recursive: true)
    ..writeAsStringSync(text);
  put('pubspec.yaml', 'name: skeleton\n');
  put('lib/main.dart', "import 'package:skeleton/a.dart';\n");
  put('build/x.txt', 'generated');
  put('test/repo_tools/t.dart', '');
  put(
    'test/platform/web_index_test.dart',
    "expect(html, contains('<title>Skeleton</title>'));\n",
  );
  put('bricks/feature/brick.yaml', 'vars:\n  package: skeleton\n');
  put(
    'android/app/build.gradle.kts',
    'namespace = "dev.angga.skeleton"\n'
        'applicationId = "dev.angga.skeleton"\n',
  );
  put(
    'android/app/src/main/AndroidManifest.xml',
    '<manifest xmlns:android="x">\n'
        '    <uses-permission android:name="android.permission.INTERNET"/>\n'
        '    <application android:label="Skeleton"></application>\n'
        '    <queries>\n        <intent>\n'
        '            <data android:scheme="https"/>\n'
        '        </intent>\n    </queries>\n</manifest>\n',
  );
  put(
    'android/app/src/main/kotlin/dev/angga/skeleton/MainActivity.kt',
    'package dev.angga.skeleton\n',
  );
  put(
    'macos/Runner/Configs/AppInfo.xcconfig',
    'PRODUCT_NAME = skeleton\n'
        'PRODUCT_BUNDLE_IDENTIFIER = dev.angga.skeleton\n',
  );
  for (final name in ['DebugProfile', 'Release']) {
    put(
      'macos/Runner/$name.entitlements',
      '<dict>\n\t<key>com.apple.security.network.client</key>\n'
          '\t<true/>\n</dict>\n',
    );
  }
  put(
    'linux/CMakeLists.txt',
    'set(BINARY_NAME "skeleton")\n'
        'set(APPLICATION_ID "dev.angga.skeleton")\n',
  );
  put(
    'windows/CMakeLists.txt',
    'project(skeleton LANGUAGES CXX)\nset(BINARY_NAME "skeleton")\n',
  );
  put('web/manifest.json', '{"name": "Skeleton", "short_name": "Skeleton"}\n');
  put('web/index.html', '<title>Skeleton</title>\n');
}
