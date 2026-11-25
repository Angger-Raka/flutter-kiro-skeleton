import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

/// Copies text to the system clipboard.
@lazySingleton
class ClipboardService {
  /// Creates a [ClipboardService].
  const ClipboardService();

  /// Copies [text] to the clipboard.
  Future<void> copy(String text) =>
      Clipboard.setData(ClipboardData(text: text));
}
