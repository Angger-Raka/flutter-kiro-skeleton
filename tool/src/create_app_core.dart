/// Pure functions of `create_app`. No file or process access, so they are
/// tested without Flutter.
library;

const _reservedWords = <String>{
  // Reserved words.
  'assert', 'break', 'case', 'catch', 'class', 'const', 'continue',
  'default', 'do', 'else', 'enum', 'extends', 'false', 'final', 'finally',
  'for', 'if', 'in', 'is', 'new', 'null', 'rethrow', 'return', 'super',
  'switch', 'this', 'throw', 'true', 'try', 'var', 'void', 'while', 'with',
  // Built-in identifiers and contextual words that `flutter create` rejects.
  'abstract', 'as', 'async', 'await', 'covariant', 'deferred', 'dynamic',
  'export', 'extension', 'external', 'factory', 'get', 'hide', 'implements',
  'import', 'interface', 'late', 'library', 'mixin', 'of', 'on', 'operator',
  'part', 'required', 'set', 'show', 'static', 'sync', 'typedef', 'yield',
  // Names that clash with packages the app depends on or with the SDK.
  'dart', 'flutter', 'flutter_test', 'test',
};

final _nameFormat = RegExp(r'^[a-z][a-z0-9_]*$');
final _orgFormat = RegExp(r'^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)*$');
final _displayNameFormat = RegExp(r"^[\p{L}\p{N} ._'-]+$", unicode: true);

/// Returns an error message when [name] is not a usable package name, or
/// `null` when it is valid.
String? validateName(String name) {
  if (name.isEmpty) return 'The package name is empty.';
  if (!_nameFormat.hasMatch(name)) {
    return '"$name" is not a valid package name. Use lower case letters, '
        'digits and underscores, starting with a letter (for example my_app).';
  }
  if (_reservedWords.contains(name)) {
    return '"$name" is a reserved word or a name that clashes with the SDK. '
        'Choose another package name.';
  }
  return null;
}

/// Returns an error message when [org] is not a reverse-domain prefix such as
/// `com.example`, or `null` when it is valid.
String? validateOrg(String org) => _orgFormat.hasMatch(org)
    ? null
    : '"$org" is not a valid --org. Use dot separated lower case words, for '
          'example com.example.';

/// Returns an error message when [displayName] holds characters that would
/// need escaping in plist, XML, JSON, HTML or C strings, or `null` when it is
/// valid.
String? validateDisplayName(String displayName) =>
    _displayNameFormat.hasMatch(displayName)
    ? null
    : '"$displayName" is not a valid --display-name. Use letters, digits, '
          "spaces, and . _ ' - only.";

/// `my_app` becomes `My App`.
String defaultDisplayName(String name) => name
    .split('_')
    .where((word) => word.isNotEmpty)
    .map((word) => word[0].toUpperCase() + word.substring(1))
    .join(' ');

/// Whether the file or folder at [relativePath] (relative to `skeleton/`, with
/// `/` separators) is copied into a new app.
bool shouldCopy(String relativePath) {
  final segments = relativePath
      .split('/')
      .where((segment) => segment.isNotEmpty)
      .toList();
  if (segments.isEmpty) return true;
  const skippedAnywhere = {'.dart_tool', '.idea', '.fvm', '.gradle', 'Pods'};
  if (segments.any(skippedAnywhere.contains)) return false;
  // `build/` is generated output at the top level and inside platform folders.
  // A folder called `build` elsewhere (for example under `lib/`) is source.
  const platformFolders = {'android', 'ios', 'macos', 'linux', 'windows'};
  if (segments.first == 'build') return false;
  if (platformFolders.contains(segments.first) && segments.contains('build')) {
    return false;
  }
  final last = segments.last;
  if (last.endsWith('.iml')) return false;
  if (last == '.flutter-plugins-dependencies') return false;
  // Files that Flutter regenerates on the first run.
  if (segments.contains('ephemeral') || last == 'Generated.xcconfig') {
    return false;
  }
  if (last == 'flutter_export_environment.sh' || last == 'local.properties') {
    return false;
  }
  if (last == 'pubspec.lock' && segments.length == 1) return false;
  if (segments.length >= 2 &&
      segments[0] == 'test' &&
      segments[1] == 'repo_tools') {
    return false;
  }
  return true;
}

/// Rewrites the skeleton package name in [text]: `package:skeleton/` imports
/// and the `name: skeleton` line of `pubspec.yaml`. Nothing else is touched, so
/// permission strings and platform files pass through unchanged.
String replaceInText(String text, {required String name}) => text
    .replaceAll('package:skeleton/', 'package:$name/')
    .replaceAllMapped(
      RegExp(r'^name:\s*skeleton\s*$', multiLine: true),
      (_) => 'name: $name',
    );

/// Rewrites the `package` variable of a `bricks/*/brick.yaml` from `skeleton`
/// to [name]. Both the one-line form (`package: skeleton`) and the block form
/// (`package:` with `default: skeleton`) are handled.
String replaceBrickPackage(String text, {required String name}) => text
    .replaceAllMapped(
      RegExp(r'^(\s*package:[ \t]*)skeleton[ \t]*$', multiLine: true),
      (m) => '${m[1]}$name',
    )
    .replaceAllMapped(
      RegExp(
        r'^(\s*package:[ \t]*\n(?:[ \t]+[^\n]*\n)*?[ \t]+default:[ \t]*)'
        r'''['"]?skeleton['"]?[ \t]*$''',
        multiLine: true,
      ),
      (m) => '${m[1]}$name',
    );
