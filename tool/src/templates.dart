/// Template text that `create_app` writes over the skeleton's own API files
/// and product steering file (requirement 16.7).
///
/// The files arrive in Phase 2. Until then `create_app` skips them, so these
/// texts are short starting points that the app owner fills in.
library;

import 'dart:io';

/// Path (relative to the app root) to template text.
const Map<String, String> templateFiles = {
  'api/openapi.yaml': _openapi,
  'api/api_map.yaml': _apiMap,
  'api/CHANGELOG.md': _changelog,
  '.kiro/steering/product.md': _product,
};

/// Overwrites each template file of [app] that exists. Files that do not exist
/// are skipped. Returns the relative paths that were reset.
List<String> resetTemplates(Directory app) {
  final reset = <String>[];
  templateFiles.forEach((path, text) {
    final file = File('${app.path}/$path');
    if (!file.existsSync()) return;
    file.writeAsStringSync(text);
    reset.add(path);
  });
  return reset;
}

const _openapi = '''
openapi: 3.0.3
info:
  title: My App API
  version: 0.1.0
paths: {}
''';

const _apiMap = '''
# Maps each endpoint of openapi.yaml to the app code that calls it.
endpoints: {}
''';

const _changelog = '''
# API changelog

Record every change to `openapi.yaml` here, newest first.
''';

const _product = '''
# Product

Describe the app here: who it is for, what it does, and what it must never do.
Kiro reads this file before it plans any feature.
''';
