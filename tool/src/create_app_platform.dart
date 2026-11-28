/// Platform identifier edits of `create_app`.
///
/// [platformEdits] is pure (text in, text out). [applyPlatformIds] reads and
/// writes files and uses the fallback when a pattern is missing.
library;

import 'dart:io';

import 'process_runner.dart';

/// The names a new app gets.
class AppIds {
  const AppIds({
    required this.name,
    required this.org,
    required this.displayName,
  });

  final String name;
  final String org;
  final String displayName;

  /// Android application id and Linux application id.
  String get androidId => '$org.$name';

  /// Apple bundle ids do not allow `_`, so it becomes `-` as in
  /// `flutter create`.
  String get appleId => '$org.${name.replaceAll('_', '-')}';
}

/// One text edit on one platform file.
class _Rule {
  const _Rule(this.pattern, this.replace);
  final RegExp pattern;
  final String Function(Match match) replace;
}

/// Files of the skeleton that carry its name, by platform folder.
/// The key is the path relative to the app root.
Map<String, List<_Rule>> _rules(AppIds ids) {
  final display = ids.displayName;
  final name = ids.name;
  _Rule label(RegExp pattern, String prefix, String suffix) =>
      _Rule(pattern, (_) => '$prefix$display$suffix');
  _Rule literal(String from, String to) =>
      _Rule(RegExp(RegExp.escape(from)), (_) => to);
  final xcodeBundle = RegExp(
    r'(PRODUCT_BUNDLE_IDENTIFIER = )[^;\s]*?(\.RunnerTests)?(;?)$',
    multiLine: true,
  );
  _Rule bundle() =>
      _Rule(xcodeBundle, (m) => '${m[1]}${ids.appleId}${m[2] ?? ''}${m[3]}');
  final plistName = literal(
    '<string>Skeleton</string>',
    '<string>$display</string>',
  );

  return {
    'android/app/build.gradle.kts': [
      _Rule(
        RegExp(r'namespace\s*=\s*"[^"]*"'),
        (_) => 'namespace = "${ids.androidId}"',
      ),
      _Rule(
        RegExp(r'applicationId\s*=\s*"[^"]*"'),
        (_) => 'applicationId = "${ids.androidId}"',
      ),
    ],
    'android/app/src/main/AndroidManifest.xml': [
      label(RegExp(r'android:label="[^"]*"'), 'android:label="', '"'),
    ],
    'ios/Runner.xcodeproj/project.pbxproj': [bundle()],
    'ios/Runner/Info.plist': [plistName],
    'macos/Runner.xcodeproj/project.pbxproj': [
      bundle(),
      literal('skeleton.app', '$display.app'),
      literal('/skeleton"', '/$display"'),
    ],
    'macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme': [
      literal('skeleton.app', '$display.app'),
    ],
    'macos/Runner/Configs/AppInfo.xcconfig': [
      bundle(),
      label(
        RegExp(r'^PRODUCT_NAME = .*$', multiLine: true),
        'PRODUCT_NAME = ',
        '',
      ),
    ],
    'macos/Runner/Info.plist': [plistName],
    'linux/CMakeLists.txt': [
      _Rule(
        RegExp(r'set\(BINARY_NAME "[^"]*"\)'),
        (_) => 'set(BINARY_NAME "$name")',
      ),
      _Rule(
        RegExp(r'set\(APPLICATION_ID "[^"]*"\)'),
        (_) => 'set(APPLICATION_ID "${ids.androidId}")',
      ),
    ],
    'linux/runner/my_application.cc': [literal('"Skeleton"', '"$display"')],
    'windows/CMakeLists.txt': [
      _Rule(RegExp(r'project\(skeleton '), (_) => 'project($name '),
      _Rule(
        RegExp(r'set\(BINARY_NAME "[^"]*"\)'),
        (_) => 'set(BINARY_NAME "$name")',
      ),
    ],
    'windows/runner/main.cpp': [literal('L"Skeleton"', 'L"$display"')],
    'windows/runner/Runner.rc': [
      literal('"Skeleton"', '"$display"'),
      literal('"skeleton"', '"$name"'),
      literal('"skeleton.exe"', '"$name.exe"'),
    ],
    'web/manifest.json': [
      _Rule(RegExp(r'"name":\s*"[^"]*"'), (_) => '"name": "$display"'),
      _Rule(
        RegExp(r'"short_name":\s*"[^"]*"'),
        (_) => '"short_name": "$display"',
      ),
    ],
    'web/index.html': [
      label(RegExp(r'<title>[^<]*</title>'), '<title>', '</title>'),
      label(RegExp(r'(?<=<meta property="og:title" content=")[^"]*'), '', ''),
      label(
        RegExp(r'(?<=<meta name="apple-mobile-web-app-title" content=")[^"]*'),
        '',
        '',
      ),
    ],
  };
}

/// Result of [platformEdits].
class PlatformEdit {
  const PlatformEdit(this.text, {required this.matched});

  /// The edited text.
  final String text;

  /// False when at least one rule of the file did not match.
  final bool matched;
}

/// Platform folders that have rules, in the order they are processed.
const platformFolders = ['android', 'ios', 'macos', 'linux', 'windows', 'web'];

/// Paths (relative to the app root) that have edit rules.
List<String> platformFiles(AppIds ids) => _rules(ids).keys.toList();

/// Applies the rules of [relativePath] to [text]. Returns `null` when the path
/// has no rules. A rule that does not match anywhere sets `matched` to false.
PlatformEdit? platformEdits(String relativePath, String text, AppIds ids) {
  final rules = _rules(ids)[relativePath];
  if (rules == null) return null;
  var result = text;
  var matched = true;
  for (final rule in rules) {
    if (!rule.pattern.hasMatch(result)) {
      matched = false;
      continue;
    }
    result = result.replaceAllMapped(rule.pattern, rule.replace);
  }
  return PlatformEdit(result, matched: matched);
}

/// Rewrites the `package` line of `MainActivity.kt`.
String replaceKotlinPackage(String text, AppIds ids) => text.replaceFirstMapped(
  RegExp(r'^package\s+[\w.]+', multiLine: true),
  (_) => 'package ${ids.androidId}',
);

/// Rewrites the two literals of `test/platform/web_index_test.dart` that name
/// the skeleton, so that the copied test passes in the new app.
String rewriteWebIndexTest(String text, AppIds ids) => text
    .replaceAll('<title>Skeleton</title>', '<title>${ids.displayName}</title>')
    .replaceAll('"name": "Skeleton"', '"name": "${ids.displayName}"')
    .replaceAll(
      '"short_name": "Skeleton"',
      '"short_name": "${ids.displayName}"',
    )
    .replaceAll('are Skeleton', 'are ${ids.displayName}');

/// Moves `MainActivity.kt` to the folder of the new Android package and
/// rewrites its `package` line. Does nothing when the file is not there.
void moveMainActivity(Directory app, AppIds ids) {
  final kotlin = Directory('${app.path}/android/app/src/main/kotlin');
  if (!kotlin.existsSync()) return;
  final files = kotlin
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('/MainActivity.kt'))
      .toList();
  if (files.isEmpty) return;
  final source = files.first;
  final target = File(
    '${kotlin.path}/${ids.androidId.replaceAll('.', '/')}/MainActivity.kt',
  );
  if (source.path == target.path) return;
  target.parent.createSync(recursive: true);
  target.writeAsStringSync(
    replaceKotlinPackage(source.readAsStringSync(), ids),
  );
  source.deleteSync();
  // Remove the folders the old package left empty.
  var dir = source.parent;
  while (dir.path != kotlin.path && dir.listSync().isEmpty) {
    dir.deleteSync();
    dir = dir.parent;
  }
}

/// Makes sure the Android manifest has the `INTERNET` permission and the
/// `https` queries entry (requirement 16.5).
String ensureAndroidManifest(String text) {
  var result = text;
  if (!result.contains('android.permission.INTERNET')) {
    result = result.replaceFirstMapped(
      RegExp(r'<manifest[^>]*>'),
      (m) =>
          '${m[0]}\n'
          '    <uses-permission android:name="android.permission.INTERNET"/>',
    );
  }
  if (!result.contains('android:scheme="https"')) {
    const intent =
        '        <intent>\n'
        '            <action android:name="android.intent.action.VIEW"/>\n'
        '            <data android:scheme="https"/>\n'
        '        </intent>\n';
    result = result.contains('</queries>')
        ? result.replaceFirst('</queries>', '$intent    </queries>')
        : result.replaceFirst(
            '</manifest>',
            '    <queries>\n$intent    </queries>\n</manifest>',
          );
  }
  return result;
}

/// Makes sure a macOS entitlements file has `network.client`.
String ensureMacEntitlements(String text) {
  if (text.contains('com.apple.security.network.client')) return text;
  return text.replaceFirst(
    '</dict>',
    '\t<key>com.apple.security.network.client</key>\n\t<true/>\n</dict>',
  );
}

const _macEntitlementFiles = [
  'macos/Runner/DebugProfile.entitlements',
  'macos/Runner/Release.entitlements',
];
const _androidManifest = 'android/app/src/main/AndroidManifest.xml';

/// Re-applies the permission and entitlement edits to the files that exist.
void applyNetworkAccess(Directory app) {
  void edit(String path, String Function(String) change) {
    final file = File('${app.path}/$path');
    if (!file.existsSync()) return;
    final before = file.readAsStringSync();
    final after = change(before);
    if (after != before) file.writeAsStringSync(after);
  }

  edit(_androidManifest, ensureAndroidManifest);
  for (final path in _macEntitlementFiles) {
    edit(path, ensureMacEntitlements);
  }
}

/// Lists the network access entries that are missing from [app].
List<String> networkAccessProblems(Directory app) {
  final problems = <String>[];
  final manifest = File('${app.path}/$_androidManifest');
  if (manifest.existsSync()) {
    final text = manifest.readAsStringSync();
    if (!text.contains('android.permission.INTERNET')) {
      problems.add('$_androidManifest: INTERNET permission');
    }
    if (!text.contains('android:scheme="https"')) {
      problems.add('$_androidManifest: https queries entry');
    }
  }
  for (final path in _macEntitlementFiles) {
    final file = File('${app.path}/$path');
    if (file.existsSync() &&
        !file.readAsStringSync().contains(
          'com.apple.security.network.client',
        )) {
      problems.add('$path: com.apple.security.network.client');
    }
  }
  return problems;
}

/// Applies the platform edits to [app] (a fresh copy of the skeleton).
///
/// Returns the platform folders whose files did not match a pattern. J3 sends
/// them through the `flutter create` fallback.
List<String> applyPlatformIds(Directory app, AppIds ids) {
  final missing = <String>{};
  for (final path in platformFiles(ids)) {
    final file = File('${app.path}/$path');
    final platform = path.split('/').first;
    if (!file.existsSync()) {
      missing.add(platform);
      continue;
    }
    final edit = platformEdits(path, file.readAsStringSync(), ids)!;
    if (!edit.matched) missing.add(platform);
    file.writeAsStringSync(edit.text);
  }
  moveMainActivity(app, ids);
  return platformFolders.where(missing.contains).toList();
}

/// Replaces the folders of [platforms] in [app] with fresh ones from
/// `flutter create` (requirement 16.6), then re-applies the permission and
/// entitlement edits. Returns false when `flutter create` fails.
///
/// shortcut: the fresh folder has Flutter's default icons and labels, not the
/// skeleton's. Upgrade by re-running the platform rules on it if that matters.
Future<bool> flutterCreateFallback(
  Directory app,
  AppIds ids,
  List<String> platforms,
  ProcessRunner runner,
) async {
  final temp = Directory.systemTemp.createTempSync('create_app_fallback');
  try {
    final code = await runner('flutter', [
      'create',
      '--org',
      ids.org,
      '--project-name',
      ids.name,
      '--platforms=${platforms.join(',')}',
      temp.path,
    ]);
    if (code != 0) return false;
    for (final platform in platforms) {
      final fresh = Directory('${temp.path}/$platform');
      if (!fresh.existsSync()) continue;
      final old = Directory('${app.path}/$platform');
      if (old.existsSync()) old.deleteSync(recursive: true);
      _copyTree(fresh, old);
    }
    applyNetworkAccess(app);
    return true;
  } finally {
    temp.deleteSync(recursive: true);
  }
}

void _copyTree(Directory from, Directory to) {
  to.createSync(recursive: true);
  for (final entity in from.listSync(followLinks: false)) {
    final base = entity.uri.pathSegments.where((s) => s.isNotEmpty).last;
    if (entity is Directory) {
      _copyTree(entity, Directory('${to.path}/$base'));
    } else if (entity is File) {
      entity.copySync('${to.path}/$base');
    }
  }
}

/// Rewrites the web index test in the copy, when it exists.
void rewriteCopiedWebIndexTest(Directory app, AppIds ids) {
  final file = File('${app.path}/test/platform/web_index_test.dart');
  if (file.existsSync()) {
    file.writeAsStringSync(rewriteWebIndexTest(file.readAsStringSync(), ids));
  }
}
