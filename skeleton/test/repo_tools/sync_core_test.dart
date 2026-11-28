import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../../tool/src/sync_core_core.dart';

void main() {
  late Directory root;
  late Directory from;
  late Directory to;

  void write(Directory dir, String path, String text) {
    File('${dir.path}/$path')
      ..createSync(recursive: true)
      ..writeAsStringSync(text);
  }

  void writeBytes(Directory dir, String path, List<int> bytes) {
    File('${dir.path}/$path')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes);
  }

  void pubspec(Directory dir, String name, String deps, {String dev = ''}) {
    write(
      dir,
      'pubspec.yaml',
      'name: $name\n\ndependencies:\n  flutter:\n    sdk: flutter\n$deps\n'
          'dev_dependencies:\n  flutter_test:\n    sdk: flutter\n$dev\n'
          'flutter:\n  uses-material-design: true\n',
    );
  }

  setUp(() {
    root = Directory.systemTemp.createTempSync('sync_core_test');
    from = Directory('${root.path}/from_app')..createSync();
    to = Directory('${root.path}/to_app')..createSync();
    pubspec(
      from,
      'from_app',
      '  fpdart: 1.2.0\n  gap: ^3.0.1\n',
      dev: '  mocktail: 1.0.5\n',
    );
    pubspec(to, 'to_app', '  fpdart: 1.2.0\n');
    write(
      from,
      'lib/core/widgets/app_pill.dart',
      "import 'package:from_app/core/theme/tokens.g.dart';\n"
          "import 'package:gap/gap.dart';\n"
          "import 'package:fpdart/fpdart.dart';\n"
          'class AppPill {}\n',
    );
    write(
      from,
      'test/core/widgets/app_pill_test.dart',
      "import 'package:mocktail/mocktail.dart';\n"
          "import 'package:from_app/core/widgets/app_pill.dart';\n",
    );
    writeBytes(from, 'test/core/widgets/goldens/app_pill_light.png', [
      137,
      80,
      78,
      71,
      0,
      255,
    ]);
    write(from, 'lib/core/layout/page_column.dart', 'class PageColumn {}\n');
    write(from, 'lib/core/theme/other.dart', 'class Other {}\n');
  });

  tearDown(() => root.deleteSync(recursive: true));

  group('plan', () {
    test('lists widgets, layout files, tests and goldens to copy', () {
      final p = plan(from, to);
      expect(p.isOk, isTrue);
      expect(p.copies.map((c) => c.path), [
        'lib/core/layout/page_column.dart',
        'lib/core/widgets/app_pill.dart',
        'test/core/widgets/app_pill_test.dart',
        'test/core/widgets/goldens/app_pill_light.png',
      ]);
    });

    test('rewrites package imports in Dart files only', () {
      final p = plan(from, to);
      String text(String path) =>
          utf8.decode(p.copies.firstWhere((c) => c.path == path).bytes);
      expect(
        text('lib/core/widgets/app_pill.dart'),
        contains("'package:to_app/core/theme/tokens.g.dart'"),
      );
      expect(
        text('test/core/widgets/app_pill_test.dart'),
        contains("'package:to_app/core/widgets/app_pill.dart'"),
      );
      expect(
        p.copies.firstWhere((c) => c.path.endsWith('.png')).bytes,
        [137, 80, 78, 71, 0, 255],
      );
      expect(
        rewriteImports('package:a/x package:ab/y', 'a', 'b'),
        'package:b/x package:ab/y',
      );
    });

    test('adds packages that to lacks, with the version from from', () {
      final p = plan(from, to);
      final byName = {for (final k in p.packages) k.name: k};
      expect(byName.keys, containsAll(['gap', 'mocktail']));
      expect(byName.containsKey('fpdart'), isFalse);
      expect(byName['gap']!.constraint, '^3.0.1');
      expect(byName['gap']!.dev, isFalse);
      expect(byName['mocktail']!.constraint, '1.0.5');
      expect(byName['mocktail']!.dev, isTrue);
    });

    test('skips identical files', () {
      final first = plan(from, to);
      for (final c in first.copies) {
        writeBytes(to, c.path, c.bytes);
      }
      final p = plan(from, to);
      expect(p.copies, isEmpty);
      expect(p.conflicts, isEmpty);
      expect(p.isOk, isTrue);
    });

    test('a conflict fails the plan and writes nothing', () {
      write(to, 'lib/core/widgets/app_pill.dart', 'class AppPill { /*x*/ }\n');
      final before = _snapshot(to);
      final p = plan(from, to);
      expect(p.isOk, isFalse);
      expect(p.conflicts.map((c) => c.path), [
        'lib/core/widgets/app_pill.dart',
      ]);
      expect(p.conflicts.single.diff, contains('--- to/'));
      expect(p.conflicts.single.diff, contains('-class AppPill { /*x*/ }'));
      expect(p.conflicts.single.diff, contains('+class AppPill {}'));
      expect(_snapshot(to), before);
    });

    test('a binary conflict prints a size note', () {
      writeBytes(to, 'test/core/widgets/goldens/app_pill_light.png', [
        255,
        254,
      ]);
      final p = plan(from, to);
      expect(p.conflicts.single.diff, startsWith('Binary files differ'));
    });

    test('reports a missing package that from does not declare', () {
      write(
        from,
        'lib/core/layout/page_column.dart',
        "import 'package:ghost/ghost.dart';\n",
      );
      final p = plan(from, to);
      expect(p.unresolved, ['ghost']);
      expect(p.isOk, isFalse);
    });
  });

  test('diffText marks removed and added lines', () {
    final d = diffText('a.txt', 'one\ntwo\n', 'one\nthree\n');
    expect(d, contains(' one'));
    expect(d, contains('-two'));
    expect(d, contains('+three'));
  });
}

Map<String, int> _snapshot(Directory dir) => {
  for (final e in dir.listSync(recursive: true))
    if (e is File) e.path: e.lengthSync(),
};
