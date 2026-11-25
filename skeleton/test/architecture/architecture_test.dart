// Architecture rules for `lib/` (Req 22, 17.9, 18.7, 20.5, 20.6; properties
// 19 and 20). The test scans source text only; it never imports app code.
//
// `ARCH_LIB_DIR` points the scan at another copy of `lib/`. It exists so a
// deliberately broken scratch copy can prove the checks fail. Leave it unset
// for normal runs.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Allowlists
// ---------------------------------------------------------------------------

/// Generated files are never scanned: their layout is owned by the generator.
bool _isGenerated(String rel) {
  final name = rel.split('/').last;
  return name.endsWith('.g.dart') ||
      name.endsWith('.freezed.dart') ||
      name == 'injection.config.dart' ||
      (name.startsWith('app_localizations') && name.endsWith('.dart'));
}

/// Public types that are exempt from "one public class per file" and
/// "file name = snake_case of the class" in a given file. Each entry names the
/// exact exempt types and gives the reason. The rule still applies to every
/// other public type in the file, and an entry that names a type the file no
/// longer declares fails the test, so the list cannot go stale.
///
/// Extensions are not counted at all: they are named after the type they
/// extend, and several can sit next to that type (`extensions.dart`,
/// `window_class.dart`, `motion.dart`, `typography.dart`).
const _typeExceptions = <String, _Exempt>{
  // Sealed families: one base type plus its subtypes in a single file, so
  // `switch` over the family is exhaustive within one library.
  'core/error/exceptions.dart': _Exempt(
    {
      'AppException',
      'ServerException',
      'NetworkException',
      'ValidationException',
      'UnauthorizedException',
      'NotFoundException',
      'CacheException',
    },
    'sealed AppException family; the file is named for the family',
  ),
  // Companion enums, interface and implementation, or helper types that are
  // only meaningful next to the main type of the file.
  'core/settings/app_settings.dart': _Exempt(
    {'AppThemeMode', 'AppLocale'},
    'companion enums of the AppSettings model (task 5.8 puts them together)',
  ),
  'core/storage/key_value_store.dart': _Exempt(
    {'SharedPrefsKeyValueStore'},
    'interface and its shared_preferences implementation (task 5.4)',
  ),
  'core/usecase/usecase.dart': _Exempt(
    {'NoParams'},
    'NoParams is the empty parameter type of the UseCase contract (task 5.2)',
  ),
  'core/layout/window_class.dart': _Exempt(
    {'InputMode'},
    'companion enum of WindowClass; both are read together (task 3.1)',
  ),
  'core/theme/tactile/pressable.dart': _Exempt(
    {'MinHitArea'},
    'render object that only Pressable uses (task 3.9 names it here)',
  ),
  'core/theme/tactile/surface.dart': _Exempt(
    {'SurfaceKind', 'SurfaceScope', 'TactileSurface'},
    'tasks 3.5 and 3.7 define the surface kinds, their scope and the widget '
    'in surface.dart; the file is named for the concept, not one class',
  ),
  'core/theme/tactile/shadows.dart': _Exempt(
    {'ShadowRecipe', 'SurfaceShadows'},
    'task 3.6 names shadows.dart for the per-surface shadow selection',
  ),
  'core/theme/tactile/typography.dart': _Exempt(
    {'AppTypography', 'AppTypographyInk'},
    'task 3.4 names typography.dart; the ThemeExtension and its ink steps '
    'belong together',
  ),
  'core/theme/tactile/motion.dart': _Exempt(
    {'AppMotion', 'AppSprings'},
    'task 3.2 names motion.dart for curves, durations and springs',
  ),
  // Files whose only public type is a function holder or a variable.
  'app/di/injection.dart': _Exempt(
    {},
    'declares the getIt variable and configureDependencies(); no class',
  ),
};

final class _Exempt {
  const _Exempt(this.types, this.reason);
  final Set<String> types;
  final String reason;
}

/// Files whose single public type legitimately differs from the file name
/// (the one-class-per-file rule still applies). Add an entry with a reason
/// instead of renaming a file.
const _fileNameExceptions = <String, String>{
  'core/usecase/usecase.dart':
      'UseCase reads as one word; task 5.2 fixes the file name usecase.dart',
  'core/utils/formatters.dart':
      'AppFormatters is the locale-aware formatter set; task 5.10 names '
      'the file formatters.dart',
  'core/theme/tactile/page_transition.dart':
      'TactilePageTransitionsBuilder; the file is named for the concept '
      '(task 3.3)',
};

/// Raw literals that are allowed outside `core/theme/` in one file. Req 22.4
/// bans them in widget code; these are not widget code.
const _rawLiteralExceptions = <String, Map<String, String>>{
  'app/di/register_module.dart': {
    'Duration(':
        'Dio connect and receive timeouts are network configuration, not UI '
        'timing (S5, commit 4d6793a)',
  },
};

// ---------------------------------------------------------------------------
// Source helpers
// ---------------------------------------------------------------------------

final _word = RegExp(r'[A-Za-z0-9_$]+');

/// Scans Dart source once, left to right, so a `//` or `/*` inside a string is
/// text and a quote inside a comment is comment. Comments are dropped
/// (newlines kept, so `^` anchors still work). With [blankStrings] the
/// contents of every string literal are dropped too, quotes kept.
///
/// shortcut: string interpolation `${...}` is treated as string text, so code
/// inside an interpolation is not checked; use the analyzer's token stream if
/// that ever matters.
String _scan(String src, {required bool blankStrings}) {
  final out = StringBuffer();
  var i = 0;
  final n = src.length;
  bool at(String s) => src.startsWith(s, i);
  while (i < n) {
    if (at('//')) {
      while (i < n && src[i] != '\n') {
        i++;
      }
    } else if (at('/*')) {
      // Dart block comments nest.
      var depth = 0;
      while (i < n) {
        if (at('/*')) {
          depth++;
          i += 2;
        } else if (at('*/')) {
          depth--;
          i += 2;
          if (depth == 0) break;
        } else {
          if (src[i] == '\n') out.write('\n');
          i++;
        }
      }
    } else if (src[i] == "'" || src[i] == '"' || at("r'") || at('r"')) {
      final raw = src[i] == 'r';
      if (raw) {
        if (!blankStrings) out.write('r');
        i++;
      }
      final q = src[i];
      final triple = at(q * 3);
      final close = triple ? q * 3 : q;
      out.write(close);
      i += close.length;
      while (i < n && !at(close)) {
        if (!triple && src[i] == '\n') break; // unterminated: stop at the line
        final step = !raw && src[i] == r'\' && i + 1 < n ? 2 : 1;
        if (!blankStrings) {
          out.write(src.substring(i, i + step));
        } else if (src[i] == '\n') {
          out.write('\n');
        }
        i += step;
      }
      if (at(close)) {
        out.write(close);
        i += close.length;
      }
    } else {
      // An identifier ending in r (`bar'x'` is not valid Dart) is copied whole
      // so its last letter is never read as a raw-string prefix.
      final m = _word.matchAsPrefix(src, i);
      if (m != null) {
        out.write(m[0]);
        i = m.end;
      } else {
        out.write(src[i]);
        i++;
      }
    }
  }
  return out.toString();
}

String _stripComments(String src) => _scan(src, blankStrings: false);

/// Comments removed and string literal contents blanked, so patterns such as
/// `Duration(` inside text do not count as code.
String _code(String src) => _scan(src, blankStrings: true);

String _snake(String name) => name
    .replaceAllMapped(
      RegExp('(?<=[a-z0-9])([A-Z])'),
      (m) => '_${m[1]}',
    )
    .toLowerCase();

final _typeDecl = RegExp(
  r'^(?:(?:abstract|sealed|final|base|interface|mixin)\s+)*'
  r'(?:class|enum|mixin|extension\s+type)\s+(\w+)',
  multiLine: true,
);

List<String> _publicTypes(String src) => [
  for (final m in _typeDecl.allMatches(_stripComments(src)))
    if (!m[1]!.startsWith('_')) m[1]!,
];

String _base(String rel) => rel.split('/').last.replaceAll('.dart', '');

bool _under(String rel, String dir) => rel.startsWith('$dir/');

// ---------------------------------------------------------------------------
// Checks. Each takes (relative path, source) and returns violations.
// ---------------------------------------------------------------------------

typedef _Check = List<String> Function(String rel, String src);

List<String> _noFeaturesFromCore(String rel, String src) {
  if (!_under(rel, 'core')) return [];
  final hit = RegExp(
    r'''import\s+['"][^'"]*features/''',
  ).hasMatch(_stripComments(src));
  return hit ? ['$rel: core/ imports a features/ path'] : [];
}

List<String> _goRouteOnlyInRoutes(String rel, String src) {
  if (rel == 'app/router/routes.dart') return [];
  return RegExp(r'\bGoRoute\(').hasMatch(_code(src))
      ? ['$rel: GoRoute( outside app/router/routes.dart']
      : [];
}

const _domainAllowed = [
  'package:skeleton/core/error/',
  'package:skeleton/core/usecase/',
  'package:fpdart/',
  'package:freezed_annotation/',
  'package:meta/',
  'dart:',
];

List<String> _domainImports(String rel, String src) {
  if (!rel.split('/').contains('domain')) return [];
  final out = <String>[];
  for (final m in RegExp(
    r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
    multiLine: true,
  ).allMatches(_stripComments(src))) {
    final uri = m[1]!;
    if (uri.startsWith('package:dio')) {
      out.add('$rel: domain/ imports dio ($uri)');
    } else if (uri.contains(':') && !_domainAllowed.any(uri.startsWith)) {
      out.add('$rel: domain/ imports $uri');
    } else if (!uri.contains(':') && _leavesDomain(rel, uri)) {
      out.add('$rel: domain/ imports $uri, outside its domain/ folder');
    }
  }
  return out;
}

/// Whether relative [uri] in file [rel] resolves outside the `domain/` folder
/// that holds [rel].
bool _leavesDomain(String rel, String uri) {
  final parts = rel.split('/');
  final domainRoot = parts.sublist(0, parts.lastIndexOf('domain') + 1);
  final path = parts.sublist(0, parts.length - 1);
  for (final seg in uri.split('/')) {
    if (seg == '..') {
      if (path.isEmpty) return true;
      path.removeLast();
    } else if (seg != '.') {
      path.add(seg);
    }
  }
  if (path.length <= domainRoot.length) return true;
  for (var i = 0; i < domainRoot.length; i++) {
    if (path[i] != domainRoot[i]) return true;
  }
  return false;
}

List<String> _typeFileRules(String rel, String src) {
  final types = _publicTypes(src);
  final exempt = _typeExceptions[rel];
  final out = <String>[];
  if (exempt != null) {
    for (final t in exempt.types) {
      if (!types.contains(t)) {
        out.add('$rel: allowlist names $t but the file does not declare it');
      }
    }
  }
  final rest = [
    for (final t in types)
      if (!(exempt?.types.contains(t) ?? false)) t,
  ];
  if (rest.length > 1) {
    out.add('$rel: ${rest.length} public types ($rest); one per file');
  } else if (rest.length == 1 &&
      _snake(rest.single) != _base(rel) &&
      !_fileNameExceptions.containsKey(rel)) {
    out.add('$rel: file name does not match ${rest.single}');
  }
  return out;
}

List<String> _noPlatformChecks(String rel, String src) {
  if (_under(rel, 'core/layout') || rel == 'app/bootstrap.dart') return [];
  return RegExp(r'\bkIsWeb\b|\bPlatform\.').hasMatch(_code(src))
      ? ['$rel: kIsWeb or Platform. outside core/layout and bootstrap']
      : [];
}

final _tokenLiterals = <String, RegExp>{
  'Color(0x': RegExp(r'\bColor\(\s*0x'),
  'Colors.': RegExp(r'\bColors\.'),
  'fontSize:': RegExp(r'\bfontSize\s*:'),
  'FontWeight.': RegExp(r'\bFontWeight\.'),
  'Curves.': RegExp(r'\bCurves\.'),
  'Duration(': RegExp(r'\bDuration\('),
  'Color.fromARGB(': RegExp(r'\bColor\.fromARGB\('),
  'Color.fromRGBO(': RegExp(r'\bColor\.fromRGBO\('),
  'Cubic(': RegExp(r'\bCubic\('),
  'Interval(': RegExp(r'\bInterval\('),
};

List<String> _noRawTokensOutsideTheme(String rel, String src) {
  if (_under(rel, 'core/theme')) return [];
  final code = _code(src);
  return [
    for (final e in _tokenLiterals.entries)
      if (e.value.hasMatch(code) &&
          !(_rawLiteralExceptions[rel]?.containsKey(e.key) ?? false))
        '$rel: raw literal ${e.key} outside theme',
  ];
}

List<String> _noEaseInOrHeavyWeight(String rel, String src) {
  final code = _code(src);
  final out = <String>[];
  if (RegExp(r'\bCurves\.easeIn(?!Out)\w*').hasMatch(code)) {
    out.add('$rel: Curves.easeIn* is banned');
  }
  if (!_under(rel, 'core/theme') &&
      RegExp(r'\bFontWeight\.(?:w[6-9]00|bold)\b').hasMatch(code)) {
    out.add('$rel: FontWeight 600 or heavier outside core/theme');
  }
  return out;
}

/// Material controls and ink widgets. `lib/app` draws interaction with
/// `Pressable` and `TactileSurface` instead (Req 21.7).
const _materialControls = [
  'SegmentedButton',
  'ElevatedButton',
  'TextButton',
  'OutlinedButton',
  'FilledButton',
  'IconButton',
  'FloatingActionButton',
  'MaterialButton',
  'ToggleButtons',
  'InkWell',
  'InkResponse',
  'Switch',
  'Checkbox',
  'Radio',
  'Slider',
  'Chip',
  'ActionChip',
  'ChoiceChip',
  'FilterChip',
];

final _materialControl = RegExp('\\b(?:${_materialControls.join('|')})\\b');

List<String> _noMaterialButtonsInApp(String rel, String src) {
  if (!_under(rel, 'app')) return [];
  final m = _materialControl.firstMatch(_code(src));
  return m != null ? ['$rel: Material control ${m[0]} in lib/app'] : [];
}

const _reservedNames = [
  'AdaptiveScaffold',
  'AdaptiveBuilder',
  'PageColumn',
  'AdaptiveGrid',
  'ActionGroup',
];

List<String> _noReservedDeclarations(String rel, String src) {
  final code = _stripComments(src);
  return [
    for (final n in _reservedNames)
      if (RegExp(
        '(?:class|enum|mixin|extension\\s+type|typedef)\\s+$n\\b',
      ).hasMatch(code))
        '$rel: declares reserved name $n',
  ];
}

final _checks = <String, _Check>{
  'no features/ import from core/ (property 19)': _noFeaturesFromCore,
  'GoRoute( only in routes.dart (property 20)': _goRouteOnlyInRoutes,
  'domain/ imports only allowed packages, no dio (22.2)': _domainImports,
  'one public type per file, file = snake_case of type (22.3)': _typeFileRules,
  'no kIsWeb or Platform. outside core/layout and bootstrap (20.5)':
      _noPlatformChecks,
  'no raw colour, size, weight, curve, duration outside theme (22.4)':
      _noRawTokensOutsideTheme,
  'no Curves.easeIn*, no FontWeight 600+ outside theme (17.9, 18.7)':
      _noEaseInOrHeavyWeight,
  'no Material controls or ink widgets in lib/app (21.7)':
      _noMaterialButtonsInApp,
  'no reserved layout widget declared (20.6)': _noReservedDeclarations,
};

// ---------------------------------------------------------------------------
// Tree scan
// ---------------------------------------------------------------------------

Map<String, String> _readLib(Directory root) {
  final prefix = '${root.path}/';
  final files = <String, String>{};
  for (final e in root.listSync(recursive: true, followLinks: false)) {
    if (e is! File || !e.path.endsWith('.dart')) continue;
    final rel = e.path.substring(prefix.length);
    if (_isGenerated(rel)) continue;
    files[rel] = e.readAsStringSync();
  }
  return files;
}

void main() {
  final root = Directory(Platform.environment['ARCH_LIB_DIR'] ?? 'lib');

  group('lib/ architecture', () {
    late Map<String, String> files;

    setUpAll(() {
      expect(root.existsSync(), isTrue, reason: '${root.path} not found');
      files = _readLib(root);
      expect(files, isNotEmpty);
    });

    for (final entry in _checks.entries) {
      test(entry.key, () {
        final violations = [
          for (final f in files.entries) ...entry.value(f.key, f.value),
        ];
        expect(violations, isEmpty, reason: violations.join('\n'));
      });
    }

    test('lib/features does not exist (22.6)', () {
      expect(Directory('${root.path}/features').existsSync(), isFalse);
    });

    test('type allowlist points at files that exist', () {
      final missing = [
        for (final k in _typeExceptions.keys)
          if (!files.containsKey(k)) k,
      ];
      expect(missing, isEmpty);
    });
  });

  // The checks must be able to fail. These run each one on a small violating
  // snippet, so a broken regex cannot pass the tree scan silently.
  group('checks detect violations', () {
    void fails(_Check check, String rel, String src) =>
        expect(check(rel, src), isNotEmpty, reason: 'expected a violation');

    void passes(_Check check, String rel, String src) =>
        expect(check(rel, src), isEmpty);

    test('features import from core', () {
      fails(
        _noFeaturesFromCore,
        'core/a.dart',
        "import 'package:skeleton/features/x/x.dart';",
      );
      passes(_noFeaturesFromCore, 'app/a.dart', "import '../features/x.dart';");
    });

    test('GoRoute outside routes.dart', () {
      fails(
        _goRouteOnlyInRoutes,
        'app/x.dart',
        'final r = GoRoute(path: "/");',
      );
      passes(_goRouteOnlyInRoutes, 'app/router/routes.dart', 'GoRoute(a);');
    });

    test('domain imports', () {
      fails(
        _domainImports,
        'features/a/domain/x.dart',
        "import 'package:dio/dio.dart';",
      );
      fails(
        _domainImports,
        'features/a/domain/x.dart',
        "import 'package:flutter/material.dart';",
      );
      passes(
        _domainImports,
        'features/a/domain/x.dart',
        "import 'package:fpdart/fpdart.dart';",
      );
    });

    test('relative domain imports (SF3)', () {
      for (final uri in [
        '../data/impl.dart',
        '../presentation/page.dart',
        '../../b/data/x.dart',
        './../data/impl.dart',
        'entities/../../data/x.dart',
      ]) {
        fails(_domainImports, 'features/a/domain/bad.dart', "import '$uri';");
      }
      fails(
        _domainImports,
        'features/a/domain/usecases/x.dart',
        "export '../../data/impl.dart';",
      );
      for (final uri in ['entities/user.dart', '../repo.dart', './x.dart']) {
        passes(
          _domainImports,
          'features/a/domain/usecases/x.dart',
          "import '$uri';",
        );
      }
    });

    test('one type per file and file name', () {
      fails(_typeFileRules, 'core/x/foo.dart', 'class Foo {}\nclass Bar {}');
      fails(_typeFileRules, 'core/x/foo.dart', 'class Other {}');
      passes(_typeFileRules, 'core/x/foo_bar.dart', 'final class FooBar {}');
    });

    test('platform checks', () {
      fails(_noPlatformChecks, 'app/x.dart', 'final w = kIsWeb;');
      fails(_noPlatformChecks, 'core/x.dart', 'final o = Platform.isIOS;');
      passes(_noPlatformChecks, 'core/layout/x.dart', 'final w = kIsWeb;');
      passes(_noPlatformChecks, 'app/x.dart', '// kIsWeb in a comment');
    });

    test('raw tokens outside theme', () {
      for (final s in [
        'const c = Color(0xFF000000);',
        'final c = Colors.red;',
        'const s = TextStyle(fontSize: 12);',
        'final w = FontWeight.w500;',
        'final c = Curves.easeOut;',
        'const d = Duration(seconds: 1);',
        'const c = Color.fromARGB(255, 0, 0, 0);',
        'const c = Color.fromRGBO(0, 0, 0, 1);',
        'const c = Cubic(0.2, 0, 0, 1);',
        'const i = Interval(0, 0.5);',
      ]) {
        fails(_noRawTokensOutsideTheme, 'core/x.dart', s);
      }
      passes(_noRawTokensOutsideTheme, 'core/theme/x.dart', 'Colors.red');
      passes(
        _noRawTokensOutsideTheme,
        'core/x.dart',
        "const s = 'Duration(';",
      );
    });

    test('comment stripping is string-aware (SF2)', () {
      // `//` inside a string does not hide the rest of the line.
      fails(
        _noRawTokensOutsideTheme,
        'app/v1.dart',
        "final a = ['https://x.dev', const Duration(seconds: 1)];",
      );
      // `/*` and `*/` inside strings do not form a comment.
      fails(
        _noRawTokensOutsideTheme,
        'core/v2.dart',
        "const a = '/*';\nconst d = Duration(seconds: 3);\nconst b = '*/';",
      );
      fails(_noRawTokensOutsideTheme, 'core/v3.dart', r"r'\' + Colors.red");
      fails(
        _noRawTokensOutsideTheme,
        'core/v4.dart',
        "const a = '''x\n// y\n''';\nconst d = Duration(seconds: 3);",
      );
      // Real comments and string contents still do not count.
      passes(
        _noRawTokensOutsideTheme,
        'core/x.dart',
        "/* Duration( /* nested */ Colors. */ final u = 'https://x.dev';\n"
            '// Duration(\n'
            'final s = "Colors.red";',
      );
      // Imports keep their URI after comment stripping.
      expect(
        _stripComments("import 'a.dart'; // x"),
        "import 'a.dart'; ",
      );
    });

    test('easeIn and heavy weights', () {
      fails(_noEaseInOrHeavyWeight, 'core/theme/x.dart', 'Curves.easeIn');
      fails(_noEaseInOrHeavyWeight, 'core/theme/x.dart', 'Curves.easeInQuad');
      fails(_noEaseInOrHeavyWeight, 'app/x.dart', 'FontWeight.w600');
      passes(_noEaseInOrHeavyWeight, 'core/theme/x.dart', 'Curves.easeInOut');
      passes(_noEaseInOrHeavyWeight, 'core/theme/x.dart', 'FontWeight.w700');
    });

    test('Material buttons and reserved names', () {
      fails(_noMaterialButtonsInApp, 'app/x.dart', 'TextButton(a);');
      for (final s in [
        'FilledButton(onPressed: f, child: c)',
        'IconButton(onPressed: f, icon: i)',
        'InkWell(onTap: f, child: c)',
        'Switch(value: v, onChanged: f)',
      ]) {
        fails(_noMaterialButtonsInApp, 'app/x.dart', s);
      }
      passes(
        _noMaterialButtonsInApp,
        'app/x.dart',
        'final t = FilledButtonThemeData(); // InkWell',
      );
      passes(_noMaterialButtonsInApp, 'core/x.dart', 'TextButton(a);');
      fails(
        _noReservedDeclarations,
        'core/x.dart',
        'class AdaptiveScaffold extends StatelessWidget {}',
      );
      passes(_noReservedDeclarations, 'core/x.dart', 'class Other {}');
    });

    test('stale allowlist entries are reported', () {
      // `exceptions.dart` is allowlisted; a file without those types fails.
      fails(_typeFileRules, 'core/error/exceptions.dart', 'class Only {}');
    });
  });
}
