// The 25 core widgets of Req 1.1 with the files that must exist for each, and
// the pure checks that `catalog_blocks_test.dart` and
// `core_widget_coverage_test.dart` run over them (stand-ins for `kit check`
// rules WID002 and UI005 until Phase 2). Paths are relative to the skeleton
// root, which is the working directory of `flutter test`.

/// Z2 flips this to true: a listed widget whose file, stress test, or goldens
/// are missing then fails. While false, widgets that do not exist yet are
/// skipped so each lane can land alone.
const bool coreInventoryStrict = false;

/// The seven categories of a catalog block (`03` §6.1).
const catalogCategories = {
  'primitive',
  'action',
  'input',
  'content',
  'feedback',
  'overlay',
  'layout',
};

/// The five fields of a catalog block.
const catalogFields = [
  'category',
  'use_when',
  'avoid_when',
  'variants',
  'tags',
];

/// One core widget and the files that belong to it.
class CoreWidget {
  const CoreWidget({
    required this.name,
    required this.category,
    required this.libPath,
    required this.stressTestPath,
    required this.goldenTestPath,
    required this.goldenLightPath,
    required this.goldenDarkPath,
  });

  final String name;
  final String category;
  final String libPath;
  final String stressTestPath;
  final String goldenTestPath;
  final String goldenLightPath;
  final String goldenDarkPath;
}

CoreWidget _widget(
  String name,
  String category,
  String snake, {
  String lib = 'lib/core/widgets',
  String test = 'test/core/widgets',
  String? testBase,
  String? goldenBase,
}) {
  final stress = testBase ?? snake;
  final golden = goldenBase ?? snake;
  return CoreWidget(
    name: name,
    category: category,
    libPath: '$lib/$snake.dart',
    stressTestPath: '$test/${stress}_test.dart',
    goldenTestPath: '$test/${golden}_golden_test.dart',
    goldenLightPath: '$test/goldens/${golden}_light.png',
    goldenDarkPath: '$test/goldens/${golden}_dark.png',
  );
}

CoreWidget _layout(String name, String snake) => _widget(
  name,
  'layout',
  snake,
  lib: 'lib/core/layout',
  test: 'test/core/layout',
);

CoreWidget _primitive(String name, String snake, String libFile) => CoreWidget(
  name: name,
  category: 'primitive',
  libPath: 'lib/core/theme/tactile/$libFile.dart',
  stressTestPath: 'test/core/theme/${snake}_stress_test.dart',
  goldenTestPath: 'test/core/theme/${snake}_golden_test.dart',
  goldenLightPath: 'test/core/theme/goldens/${snake}_light.png',
  goldenDarkPath: 'test/core/theme/goldens/${snake}_dark.png',
);

/// The 25 widgets of Req 1.1. `LoadingView` and `SkeletonBlock` share one
/// stress test and one golden gallery (task F3). `AppToast` covers
/// `ToastController`, and `AppDialog` covers `showConfirm`.
final coreWidgetInventory = <CoreWidget>[
  _primitive('TactileSurface', 'tactile_surface', 'surface'),
  _primitive('Pressable', 'pressable', 'pressable'),
  _widget('AppButton', 'action', 'app_button'),
  _widget('AppIconButton', 'action', 'app_icon_button'),
  _widget('AppPill', 'action', 'app_pill'),
  _widget('AppTextField', 'input', 'app_text_field'),
  _widget('SearchField', 'input', 'search_field'),
  _widget('AppSegmented', 'input', 'app_segmented'),
  _widget('ThemeModeSwitch', 'input', 'theme_mode_switch'),
  _widget('AppCard', 'content', 'app_card'),
  _widget('AppRow', 'content', 'app_row'),
  _widget('SectionHeader', 'content', 'section_header'),
  _widget('AppBadge', 'content', 'app_badge'),
  _widget('EmptyState', 'feedback', 'empty_state'),
  _widget('ErrorView', 'feedback', 'error_view'),
  _widget('LoadingView', 'feedback', 'loading_view'),
  _widget(
    'SkeletonBlock',
    'feedback',
    'skeleton_block',
    testBase: 'loading_view',
    goldenBase: 'loading_view',
  ),
  _widget('AppToast', 'feedback', 'app_toast'),
  _widget('AppDialog', 'overlay', 'app_dialog'),
  _widget('AppSheet', 'overlay', 'app_sheet'),
  _layout('AdaptiveScaffold', 'adaptive_scaffold'),
  _layout('PageColumn', 'page_column'),
  _layout('AdaptiveGrid', 'adaptive_grid'),
  _layout('AdaptiveBuilder', 'adaptive_builder'),
  _layout('ActionGroup', 'action_group'),
];

/// Reads a file as text. Tests pass a real reader or an in-memory map.
typedef ReadFile = String Function(String path);

/// Tells whether a file exists.
typedef FileExists = bool Function(String path);

/// Problems of the catalog block of [widget] in [source] (empty when fine).
List<String> catalogErrors(String source, CoreWidget widget) {
  final name = widget.name;
  final errors = <String>[];
  final decl = RegExp(
    '^(?:abstract |final |base |sealed )*class $name\\b',
    multiLine: true,
  ).firstMatch(source);
  if (decl == null) return ['$name: class not declared in ${widget.libPath}'];

  // The doc comment is the run of `///` and annotation lines right above.
  final lines = source.substring(0, decl.start).split('\n');
  final doc = <String>[];
  for (var i = lines.length - 1; i >= 0; i--) {
    final line = lines[i].trim();
    if (line.startsWith('///')) {
      doc.insert(0, line.substring(3).trim());
    } else if (line.startsWith('@') || line.isEmpty && doc.isEmpty) {
      continue;
    } else {
      break;
    }
  }
  final text = doc.join('\n');
  final blocks = RegExp(
    r'\{@catalog\}(.*?)\{@endcatalog\}',
    dotAll: true,
  ).allMatches(text).toList();
  if (blocks.isEmpty) return ['$name: no {@catalog} block'];
  if (blocks.length > 1) errors.add('$name: more than one {@catalog} block');

  final fields = <String, String>{};
  String? current;
  for (final raw in blocks.first.group(1)!.split('\n')) {
    final line = raw.trim();
    if (line.isEmpty) continue;
    final m = RegExp(r'^(\w+):\s*(.*)$').firstMatch(line);
    if (m != null && catalogFields.contains(m.group(1))) {
      current = m.group(1);
      fields[current!] = m.group(2)!.trim();
    } else if (current != null) {
      fields[current] = '${fields[current]} $line'.trim();
    }
  }
  for (final f in catalogFields) {
    if ((fields[f] ?? '').isEmpty) {
      errors.add('$name: field "$f" missing or empty');
    }
  }
  final category = fields['category'];
  if (category != null && category.isNotEmpty) {
    if (!catalogCategories.contains(category)) {
      errors.add('$name: unknown category "$category"');
    } else if (category != widget.category) {
      errors.add(
        '$name: category "$category" differs from the inventory '
        '"${widget.category}"',
      );
    }
  }
  return errors;
}

/// Problems of the catalog blocks of every inventory widget whose file exists
/// (all of them when [strict]), plus `CATALOG.md` (Req 1.5).
List<String> inventoryCatalogErrors({
  required FileExists exists,
  required ReadFile read,
  required bool strict,
  List<CoreWidget>? widgets,
}) {
  final errors = <String>[];
  if (exists('lib/core/widgets/CATALOG.md')) {
    errors.add(
      'lib/core/widgets/CATALOG.md must not exist (Phase 2 kit catalog)',
    );
  }
  for (final w in widgets ?? coreWidgetInventory) {
    if (!exists(w.libPath)) {
      if (strict) errors.add('${w.name}: ${w.libPath} is missing');
      continue;
    }
    errors.addAll(catalogErrors(read(w.libPath), w));
  }
  return errors;
}

/// Problems of stress test and golden coverage. A widget that already has a
/// stress test file or a golden file needs both (the stress file calls
/// `stressTest(`, and the light and dark goldens exist). In [strict] mode every
/// widget needs its lib file, stress test, and goldens.
List<String> inventoryCoverageErrors({
  required FileExists exists,
  required ReadFile read,
  required bool strict,
  List<CoreWidget>? widgets,
}) {
  final errors = <String>[];
  for (final w in widgets ?? coreWidgetInventory) {
    final hasStress = exists(w.stressTestPath);
    final hasLight = exists(w.goldenLightPath);
    final hasDark = exists(w.goldenDarkPath);
    final started = hasStress || hasLight || hasDark;
    if (!started && !strict) continue;
    if (!exists(w.libPath) && strict) {
      errors.add('${w.name}: ${w.libPath} is missing');
    }
    if (!hasStress) {
      errors.add('${w.name}: stress test ${w.stressTestPath} is missing');
    } else if (!_callsStressTest(read(w.stressTestPath))) {
      errors.add('${w.name}: ${w.stressTestPath} does not call stressTest(');
    }
    if (!hasLight) {
      errors.add('${w.name}: golden ${w.goldenLightPath} is missing');
    }
    if (!hasDark) {
      errors.add('${w.name}: golden ${w.goldenDarkPath} is missing');
    }
  }
  return errors;
}

bool _callsStressTest(String source) => source.contains('stressTest(');
