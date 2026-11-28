/// Pure planning for `tool/sync_core.dart` (design: sync_core, R17.2, 17.3, 17.5).
///
/// [plan] reads two project folders and returns a [SyncPlan]. It never writes.
/// The caller (S2) writes only when [SyncPlan.isOk] is true, so a conflict
/// stops everything before the first file is written.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Folders under `lib/` whose files are synced.
const syncedLibDirs = ['lib/core/widgets', 'lib/core/layout'];

/// Packages that come from the SDK and are never added by the plan.
const _sdkPackages = {'flutter', 'flutter_test', 'flutter_localizations'};

/// One file that will be written in `--to`.
class SyncCopy {
  const SyncCopy(this.path, this.bytes);

  /// Path relative to the project root, with `/` separators.
  final String path;

  /// Content to write, with imports already rewritten for Dart files.
  final Uint8List bytes;
}

/// One file that exists on both sides with different bytes.
class SyncConflict {
  const SyncConflict(this.path, this.diff);

  final String path;

  /// Output of [diffText] (or a size note for binary files).
  final String diff;
}

/// One package line to add to the `pubspec.yaml` of `--to`.
class SyncPackage {
  const SyncPackage(this.name, this.constraint, {required this.dev});

  final String name;
  final String constraint;

  /// True when only test files import it (goes under `dev_dependencies:`).
  final bool dev;
}

/// Result of [plan].
class SyncPlan {
  const SyncPlan({
    required this.copies,
    required this.conflicts,
    required this.packages,
    required this.unresolved,
  });

  final List<SyncCopy> copies;
  final List<SyncConflict> conflicts;
  final List<SyncPackage> packages;

  /// Imported packages missing in `--to` that `--from` gives no plain version
  /// for (path, git, or not declared). The plan cannot add them.
  final List<String> unresolved;

  /// True when nothing blocks writing.
  bool get isOk => conflicts.isEmpty && unresolved.isEmpty;
}

/// Reads the `name:` line of `<dir>/pubspec.yaml`.
String packageName(Directory dir) {
  final text = File('${dir.path}/pubspec.yaml').readAsStringSync();
  final m = RegExp(r'^name:\s*(\S+)', multiLine: true).firstMatch(text);
  if (m == null) {
    throw FormatException('No name: line in ${dir.path}/pubspec.yaml');
  }
  return m.group(1)!;
}

/// Replaces `package:<from>/` with `package:<to>/`.
String rewriteImports(String source, String from, String to) =>
    source.replaceAll('package:$from/', 'package:$to/');

/// Plans a sync of [from] into [to]. Writes nothing.
SyncPlan plan(Directory from, Directory to) {
  final fromName = packageName(from);
  final toName = packageName(to);

  final candidates = <String>{};
  for (final dir in syncedLibDirs) {
    for (final lib in _filesUnder(from, dir)) {
      candidates.add(lib);
      candidates.addAll(_relatedTests(from, lib));
    }
  }

  final copies = <SyncCopy>[];
  final conflicts = <SyncConflict>[];
  for (final path in (candidates.toList()..sort())) {
    final raw = File('${from.path}/$path').readAsBytesSync();
    final bytes = path.endsWith('.dart')
        ? Uint8List.fromList(
            utf8.encode(rewriteImports(utf8.decode(raw), fromName, toName)),
          )
        : raw;
    final target = File('${to.path}/$path');
    if (!target.existsSync()) {
      copies.add(SyncCopy(path, bytes));
      continue;
    }
    final existing = target.readAsBytesSync();
    if (!_sameBytes(existing, bytes)) {
      conflicts.add(SyncConflict(path, _diffBytes(path, existing, bytes)));
    }
  }

  final (packages, unresolved) = _packagesFor(from, to, toName, copies);
  return SyncPlan(
    copies: copies,
    conflicts: conflicts,
    packages: packages,
    unresolved: unresolved,
  );
}

/// Unified-style line diff of [oldText] to [newText] (no context trimming).
String diffText(String path, String oldText, String newText) {
  final a = const LineSplitter().convert(oldText);
  final b = const LineSplitter().convert(newText);
  // Longest common subsequence table.
  final lcs = List.generate(a.length + 1, (_) => List.filled(b.length + 1, 0));
  for (var i = a.length - 1; i >= 0; i--) {
    for (var j = b.length - 1; j >= 0; j--) {
      lcs[i][j] = a[i] == b[j]
          ? lcs[i + 1][j + 1] + 1
          : (lcs[i + 1][j] >= lcs[i][j + 1] ? lcs[i + 1][j] : lcs[i][j + 1]);
    }
  }
  final out = StringBuffer()
    ..writeln('--- to/$path')
    ..writeln('+++ from/$path');
  var i = 0;
  var j = 0;
  while (i < a.length && j < b.length) {
    if (a[i] == b[j]) {
      out.writeln(' ${a[i]}');
      i++;
      j++;
    } else if (lcs[i + 1][j] >= lcs[i][j + 1]) {
      out.writeln('-${a[i++]}');
    } else {
      out.writeln('+${b[j++]}');
    }
  }
  while (i < a.length) {
    out.writeln('-${a[i++]}');
  }
  while (j < b.length) {
    out.writeln('+${b[j++]}');
  }
  return out.toString();
}

String _diffBytes(String path, Uint8List existing, Uint8List incoming) {
  try {
    return diffText(path, utf8.decode(existing), utf8.decode(incoming));
  } on FormatException {
    return 'Binary files differ: $path '
        '(to ${existing.length} bytes, from ${incoming.length} bytes)\n';
  }
}

bool _sameBytes(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Files under `<root>/<dir>`, as root-relative paths with `/` separators.
List<String> _filesUnder(Directory root, String dir) {
  final d = Directory('${root.path}/$dir');
  if (!d.existsSync()) return const [];
  return [
    for (final e in d.listSync(recursive: true))
      if (e is File) _relative(root, e.path),
  ];
}

String _relative(Directory root, String path) =>
    path.substring(root.path.length + 1).replaceAll(r'\', '/');

/// Test and golden files that belong to a `lib/core/...` file.
///
/// `lib/core/widgets/app_button.dart` gives
/// `test/core/widgets/app_button_test.dart`,
/// `test/core/widgets/app_button_golden_test.dart` and
/// `test/core/widgets/goldens/app_button_*.png`.
List<String> _relatedTests(Directory from, String libPath) {
  if (!libPath.endsWith('.dart')) return const [];
  final rel = libPath.substring('lib/'.length);
  final slash = rel.lastIndexOf('/');
  final dir = 'test/${rel.substring(0, slash)}';
  final base = rel.substring(slash + 1, rel.length - '.dart'.length);
  final found = <String>[];
  for (final name in ['${base}_test.dart', '${base}_golden_test.dart']) {
    if (File('${from.path}/$dir/$name').existsSync()) found.add('$dir/$name');
  }
  final goldens = Directory('${from.path}/$dir/goldens');
  if (goldens.existsSync()) {
    for (final e in goldens.listSync()) {
      final file = e.uri.pathSegments.last;
      if (e is File && file.startsWith('${base}_') && file.endsWith('.png')) {
        found.add('$dir/goldens/$file');
      }
    }
  }
  return found;
}

/// Packages imported by copied files that `--to` does not declare.
(List<SyncPackage>, List<String>) _packagesFor(
  Directory from,
  Directory to,
  String toName,
  List<SyncCopy> copies,
) {
  final used = <String, bool>{}; // name -> imported by a non-test file
  final importRe = RegExp(r'''['"]package:([a-z0-9_]+)/''');
  for (final c in copies) {
    if (!c.path.endsWith('.dart')) continue;
    final isLib = c.path.startsWith('lib/');
    for (final m in importRe.allMatches(utf8.decode(c.bytes))) {
      final name = m.group(1)!;
      if (name == toName || _sdkPackages.contains(name)) continue;
      used[name] = (used[name] ?? false) || isLib;
    }
  }

  final toText = File('${to.path}/pubspec.yaml').readAsStringSync();
  final fromText = File('${from.path}/pubspec.yaml').readAsStringSync();
  final have = {
    ..._section(toText, 'dependencies').keys,
    ..._section(toText, 'dev_dependencies').keys,
  };
  final fromDeps = {
    ..._section(fromText, 'dev_dependencies'),
    ..._section(fromText, 'dependencies'),
  };

  final packages = <SyncPackage>[];
  final unresolved = <String>[];
  for (final name in used.keys.toList()..sort()) {
    if (have.contains(name)) continue;
    final constraint = fromDeps[name];
    if (constraint == null || constraint.isEmpty) {
      unresolved.add(name);
    } else {
      packages.add(SyncPackage(name, constraint, dev: !used[name]!));
    }
  }
  return (packages, unresolved);
}

/// Top-level `<key>:` section of a pubspec as name to plain scalar constraint.
/// Entries with nested values (sdk, path, git) map to an empty string.
Map<String, String> _section(String pubspec, String key) {
  final out = <String, String>{};
  var inside = false;
  for (final line in const LineSplitter().convert(pubspec)) {
    if (line.startsWith('$key:')) {
      inside = true;
      continue;
    }
    if (!inside) continue;
    if (line.isNotEmpty && !line.startsWith(' ') && !line.startsWith('#')) {
      inside = false;
      continue;
    }
    final m = RegExp(r'^  ([a-z0-9_]+):\s*(.*?)\s*(#.*)?$').firstMatch(line);
    if (m != null) out[m.group(1)!] = m.group(2)!;
  }
  return out;
}
