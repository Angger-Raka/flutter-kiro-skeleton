import 'package:flutter/services.dart';

/// `flutter test` draws unknown fonts with Ahem, so load Inter from the asset bundle.
Future<void> loadInter() async {
  final loader = FontLoader('Inter')
    ..addFont(rootBundle.load('assets/fonts/Inter-Medium.ttf'));
  await loader.load();
}
