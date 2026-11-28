/// Turns `skeleton/` into a new, named app.
///
/// Usage: dart run tool/create_app.dart <package_name>
///   [--dir <folder>] [--org com.example] [--display-name "My App"]
///   [--out .] [--clean]
library;

import 'dart:io';

import 'src/create_app_core.dart';
import 'src/create_app_platform.dart';
import 'src/process_runner.dart';
import 'src/templates.dart';

const _usage = '''
Usage: dart run tool/create_app.dart <package_name> [options]

  --dir <folder>           Folder name under --out (default: the package name)
  --org <com.example>      Reverse-domain prefix for bundle and application ids
  --display-name "My App"  Name shown to users (default: package name in title case)
  --out <path>             Parent folder of the new app (default: .)
  --clean                  Remove the Home feature (not available yet)
''';

/// Exit code for bad usage, an invalid name, or an existing target.
const exitUsage = 64;

const _textExtensions = {
  'dart',
  'yaml',
  'yml',
  'md',
  'json',
  'kt',
  'kts',
  'gradle',
  'xml',
  'plist',
  'pbxproj',
  'xcconfig',
  'xcscheme',
  'xcworkspacedata',
  'entitlements',
  'cc',
  'cpp',
  'h',
  'txt',
  'html',
  'rc',
  'swift',
  'arb',
  'properties',
  'cmake',
  'mustache',
  'lock',
};

Future<void> main(List<String> args) async {
  final repoRoot = File(Platform.script.toFilePath()).parent.parent;
  exit(await runCreateApp(args, repoRoot: repoRoot));
}

/// Runs `create_app` for [args]. [repoRoot] holds `skeleton/`. Returns the exit
/// code instead of exiting, so tests can call it.
Future<int> runCreateApp(
  List<String> args, {
  required Directory repoRoot,
  ProcessRunner runner = runProcess,
  StringSink? out,
  StringSink? err,
}) async {
  final stdoutSink = out ?? stdout;
  final stderrSink = err ?? stderr;
  int fail(String message) {
    stderrSink.writeln('create_app: $message');
    stderrSink.writeln(_usage);
    return exitUsage;
  }

  final options = <String, String>{};
  final positional = <String>[];
  var clean = false;
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (arg == '--clean') {
      clean = true;
    } else if (arg == '--help' || arg == '-h') {
      stdoutSink.writeln(_usage);
      return 0;
    } else if (arg.startsWith('--')) {
      final eq = arg.indexOf('=');
      final key = eq == -1 ? arg.substring(2) : arg.substring(2, eq);
      if (!const {'dir', 'org', 'display-name', 'out'}.contains(key)) {
        return fail('unknown option "$arg".');
      }
      if (eq != -1) {
        options[key] = arg.substring(eq + 1);
      } else if (i + 1 < args.length) {
        options[key] = args[++i];
      } else {
        return fail('option "$arg" needs a value.');
      }
    } else {
      positional.add(arg);
    }
  }
  if (positional.length != 1) return fail('give exactly one package name.');

  final name = positional.single;
  final nameError = validateName(name);
  if (nameError != null) return fail(nameError);
  final org = options['org'] ?? 'com.example';
  final orgError = validateOrg(org);
  if (orgError != null) return fail(orgError);
  final displayName = options['display-name'] ?? defaultDisplayName(name);
  final displayError = validateDisplayName(displayName);
  if (displayError != null) return fail(displayError);
  final dir = options['dir'] ?? name;
  if (dir.isEmpty || dir.contains('/') || dir == '.' || dir == '..') {
    return fail('--dir must be a plain folder name.');
  }
  if (clean) return fail('--clean is not available yet.');

  final source = Directory('${repoRoot.path}/skeleton');
  if (!source.existsSync()) return fail('${source.path} does not exist.');
  final target = Directory('${options['out'] ?? '.'}/$dir');
  if (target.existsSync() ||
      FileSystemEntity.typeSync(target.path, followLinks: false) !=
          FileSystemEntityType.notFound) {
    return fail('the target ${target.path} already exists.');
  }

  final ids = AppIds(name: name, org: org, displayName: displayName);
  _copy(source, target, '');
  _replaceTexts(target, ids);
  rewriteCopiedWebIndexTest(target, ids);
  final missing = applyPlatformIds(target, ids);
  if (missing.isNotEmpty) {
    stderrSink.writeln(
      'create_app: pattern missing in: ${missing.join(', ')}. '
      'Using flutter create for those platforms.',
    );
    if (!await flutterCreateFallback(target, ids, missing, runner)) {
      stderrSink.writeln('create_app: flutter create failed.');
      return 1;
    }
  }
  resetTemplates(target);
  final problems = networkAccessProblems(target);
  if (problems.isNotEmpty) {
    stderrSink.writeln('create_app: missing network access: $problems');
    return 1;
  }
  stdoutSink.writeln('Created ${target.path}');
  return 0;
}

/// Copies [from] to [to] file by file. Links become real files.
void _copy(Directory from, Directory to, String relative) {
  to.createSync(recursive: true);
  for (final entity in from.listSync(followLinks: false)) {
    final base = entity.uri.pathSegments.where((s) => s.isNotEmpty).last;
    final rel = relative.isEmpty ? base : '$relative/$base';
    if (!shouldCopy(rel)) continue;
    final type = FileSystemEntity.typeSync(entity.path, followLinks: false);
    final resolvedType = type == FileSystemEntityType.link
        ? FileSystemEntity.typeSync(entity.path)
        : type;
    final path = type == FileSystemEntityType.link
        ? Link(entity.path).resolveSymbolicLinksSync()
        : entity.path;
    if (resolvedType == FileSystemEntityType.directory) {
      _copy(Directory(path), Directory('${to.path}/$base'), rel);
    } else if (resolvedType == FileSystemEntityType.file) {
      File(path).copySync('${to.path}/$base');
    }
  }
}

/// Rewrites package names in every text file of [app] and the brick package.
void _replaceTexts(Directory app, AppIds ids) {
  for (final file in app.listSync(recursive: true).whereType<File>()) {
    final base = file.uri.pathSegments.last;
    final dot = base.lastIndexOf('.');
    if (dot == -1 || !_textExtensions.contains(base.substring(dot + 1))) {
      continue;
    }
    final String text;
    try {
      text = file.readAsStringSync();
    } on FormatException {
      continue; // Not UTF-8 text after all.
    }
    var result = replaceInText(text, name: ids.name);
    final rel = file.path.substring(app.path.length + 1);
    if (RegExp(r'^bricks/[^/]+/brick\.yaml$').hasMatch(rel)) {
      result = replaceBrickPackage(result, name: ids.name);
    }
    if (result != text) file.writeAsStringSync(result);
  }
}
