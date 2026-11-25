import 'package:injectable/injectable.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

/// Opens external links. Wraps `url_launcher` so callers and tests do not
/// depend on the package.
@lazySingleton
class LinkLauncher {
  /// Creates a [LinkLauncher].
  const LinkLauncher();

  /// Opens [url]. Returns false if it cannot be launched, so the caller can
  /// show a message.
  Future<bool> open(Uri url) async {
    if (!await url_launcher.canLaunchUrl(url)) {
      return false;
    }
    return url_launcher.launchUrl(url);
  }
}
