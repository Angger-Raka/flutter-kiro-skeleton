import 'package:flutter/widgets.dart';
import 'package:skeleton/core/l10n/app_localizations.dart';

/// Small non-visual helpers. No colour or size values belong here.
extension NullableStringX on String? {
  /// True when the string is null, empty, or only whitespace.
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;
}

/// Shortcut to the generated localizations: `context.l10n.themeDark`.
extension L10nX on BuildContext {
  /// The [AppLocalizations] of the nearest `Localizations` ancestor.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
