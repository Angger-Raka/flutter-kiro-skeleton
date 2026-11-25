import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/generate_tokens.dart';

void main() {
  late Directory dir;
  late String defaultYaml;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('gen_tokens_validation');
    defaultYaml = File(defaultYamlPath).readAsStringSync();
  });

  tearDown(() => dir.deleteSync(recursive: true));

  int checksum(File f) => Object.hashAll(f.readAsBytesSync());

  Future<(int, String, File, int)> run(String yaml) async {
    final yamlFile = File('${dir.path}/tokens.yaml')..writeAsStringSync(yaml);
    final out = File('${dir.path}/tokens.g.dart')
      ..writeAsStringSync('// previous output\n');
    final before = checksum(out);
    final log = StringBuffer();
    final code = await runGenerator(
      yamlPath: yamlFile.path,
      outputPath: out.path,
      stdout: log,
    );
    return (code, log.toString(), out, before);
  }

  test(
    'unknown neutral: non-zero, message points to kit, output unchanged',
    () async {
      final (code, log, out, before) = await run(
        defaultYaml.replaceFirst('neutral: sand', 'neutral: mauve'),
      );
      expect(code, isNonZero);
      expect(log, contains('mauve'));
      expect(log, contains('kit tokens'));
      expect(checksum(out), before);
    },
  );

  test('unknown hue: non-zero, output unchanged', () async {
    final (code, log, out, before) = await run(
      defaultYaml.replaceFirst('danger: red', 'danger: tomato'),
    );
    expect(code, isNonZero);
    expect(log, contains('tomato'));
    expect(checksum(out), before);
  });

  test('unknown identity hue: non-zero, output unchanged', () async {
    final (code, log, out, before) = await run(
      defaultYaml.replaceFirst('identity: []', 'identity: [cyan]'),
    );
    expect(code, isNonZero);
    expect(log, contains('cyan'));
    expect(checksum(out), before);
  });

  test('missing yaml file: non-zero, output unchanged', () async {
    final out = File('${dir.path}/tokens.g.dart')..writeAsStringSync('x');
    final code = await runGenerator(
      yamlPath: '${dir.path}/missing.yaml',
      outputPath: out.path,
      stdout: StringBuffer(),
    );
    expect(code, isNonZero);
    expect(out.readAsStringSync(), 'x');
  });

  test(
    'default yaml with identity: [] is accepted and writes the file',
    () async {
      final (code, _, out, before) = await run(defaultYaml);
      expect(code, 0);
      expect(checksum(out), isNot(before));
      expect(out.readAsStringSync(), contains('GENERATED'));
      expect(File('${out.path}.tmp').existsSync(), isFalse);
    },
  );
}
