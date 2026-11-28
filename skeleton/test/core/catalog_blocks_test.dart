import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../helpers/core_widget_inventory.dart';

const _widget = CoreWidget(
  name: 'AppThing',
  category: 'action',
  libPath: 'lib/core/widgets/app_thing.dart',
  stressTestPath: 'test/core/widgets/app_thing_test.dart',
  goldenTestPath: 'test/core/widgets/app_thing_golden_test.dart',
  goldenLightPath: 'test/core/widgets/goldens/app_thing_light.png',
  goldenDarkPath: 'test/core/widgets/goldens/app_thing_dark.png',
);

String _source({
  String category = 'action',
  Set<String> without = const {},
  int blocks = 1,
  bool block = true,
}) {
  final fields = {
    'category': category,
    'use_when': 'a thing is needed',
    'avoid_when': 'a card is better',
    'variants': 'primary, secondary',
    'tags': 'thing, button',
  }..removeWhere((k, _) => without.contains(k));
  final one = [
    '/// {@catalog}',
    for (final e in fields.entries) '/// ${e.key}: ${e.value}',
    '/// {@endcatalog}',
  ].join('\n');
  return '''
import 'package:flutter/widgets.dart';

/// A thing.
///
${block ? List.filled(blocks, one).join('\n///\n') : '/// No block here.'}
@immutable
class AppThing extends StatelessWidget {
  const AppThing({super.key});
}
''';
}

void main() {
  group('catalogErrors (fixtures)', () {
    test('a complete block passes', () {
      expect(catalogErrors(_source(), _widget), isEmpty);
    });

    test('a missing field fails', () {
      for (final field in catalogFields.where((f) => f != 'category')) {
        final errors = catalogErrors(_source(without: {field}), _widget);
        expect(errors, hasLength(1), reason: field);
        expect(errors.single, contains(field));
      }
      expect(
        catalogErrors(_source(without: {'category'}), _widget).single,
        contains('category'),
      );
    });

    test('an empty field fails', () {
      final source = _source().replaceFirst(
        '/// tags: thing, button',
        '/// tags:',
      );
      expect(catalogErrors(source, _widget).single, contains('tags'));
    });

    test('an unknown category fails', () {
      final errors = catalogErrors(_source(category: 'widget'), _widget);
      expect(errors.single, contains('unknown category'));
    });

    test('a category that differs from the inventory fails', () {
      final errors = catalogErrors(_source(category: 'input'), _widget);
      expect(errors.single, contains('differs from the inventory'));
    });

    test('no block fails', () {
      expect(
        catalogErrors(_source(block: false), _widget).single,
        contains('no {@catalog} block'),
      );
    });

    test('two blocks fail', () {
      expect(
        catalogErrors(_source(blocks: 2), _widget).single,
        contains('more than one'),
      );
    });

    test('an undeclared class fails', () {
      expect(
        catalogErrors('class Other {}', _widget).single,
        contains('class not declared'),
      );
    });
  });

  group('inventoryCatalogErrors (fixtures)', () {
    test('CATALOG.md fails', () {
      final errors = inventoryCatalogErrors(
        exists: (p) => p == 'lib/core/widgets/CATALOG.md',
        read: (_) => '',
        strict: false,
        widgets: const [],
      );
      expect(errors.single, contains('CATALOG.md'));
    });

    test('a missing widget file is skipped unless strict', () {
      bool exists(String p) => false;
      expect(
        inventoryCatalogErrors(
          exists: exists,
          read: (_) => '',
          strict: false,
          widgets: [_widget],
        ),
        isEmpty,
      );
      expect(
        inventoryCatalogErrors(
          exists: exists,
          read: (_) => '',
          strict: true,
          widgets: [_widget],
        ).single,
        contains('is missing'),
      );
    });
  });

  test('the inventory lists the 25 widgets of Req 1.1 once', () {
    expect(coreWidgetInventory, hasLength(25));
    expect(coreWidgetInventory.map((w) => w.name).toSet(), hasLength(25));
    expect(
      coreWidgetInventory.map((w) => w.category).toSet(),
      catalogCategories,
    );
  });

  test('every existing core widget has a complete catalog block', () {
    final errors = inventoryCatalogErrors(
      exists: (p) => File(p).existsSync(),
      read: (p) => File(p).readAsStringSync(),
      strict: coreInventoryStrict,
    );
    expect(errors, isEmpty, reason: errors.join('\n'));
  });
}
