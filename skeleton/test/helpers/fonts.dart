import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void>? _interLoaded;

/// Loads the bundled Inter Medium font under the family `Inter`, once per test
/// file, so text metrics are those of the app and not those of Ahem.
Future<void> loadInterFont() => _interLoaded ??= _load();

Future<void> _load() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final loader = FontLoader('Inter')
    ..addFont(rootBundle.load('assets/fonts/Inter-Medium.ttf'));
  await loader.load();
}
