// Reads design/tokens.yaml into typed knobs and validates scale names.
import 'package:yaml/yaml.dart';

import '../radix/radix_scales.dart';

/// The status and brand roles, in the order they are emitted.
const hueRoleNames = ['accent', 'success', 'danger', 'warning', 'info'];

/// Raised when tokens.yaml cannot be used. The message is printed as is.
class KnobsException implements Exception {
  /// Creates the exception.
  const KnobsException(this.message);

  /// What went wrong, for the user.
  final String message;

  @override
  String toString() => message;
}

/// The values of design/tokens.yaml the foundation generator uses.
class Knobs {
  /// Creates knobs.
  const Knobs({
    required this.neutral,
    required this.surfaceTop,
    required this.hues,
    required this.identity,
    required this.primary,
    required this.radiusControl,
    required this.tuneFaintText,
    required this.overrides,
  });

  /// Parses YAML text. Throws [KnobsException] for a bad file or an unknown
  /// scale name.
  factory Knobs.parse(String source) {
    final Object? doc;
    try {
      doc = loadYaml(source);
    } on YamlException catch (e) {
      throw KnobsException('tokens.yaml does not parse: ${e.message}');
    }
    if (doc is! YamlMap) {
      throw const KnobsException('tokens.yaml must be a YAML map.');
    }
    final hues = doc['hues'];
    if (hues is! YamlMap) {
      throw const KnobsException('tokens.yaml: "hues" must be a map.');
    }
    final identity = hues['identity'];
    final contrast = doc['contrast'];
    final overrides = doc['overrides'];
    final radius = doc['radius_control'];
    final knobs = Knobs(
      neutral: '${doc['neutral']}',
      surfaceTop: '${doc['surface_top'] ?? '#ffffff'}',
      hues: {for (final role in hueRoleNames) role: '${hues[role]}'},
      identity: identity is YamlList
          ? [for (final h in identity) '$h']
          : const <String>[],
      primary: '${doc['primary'] ?? 'neutral'}',
      radiusControl: radius is num ? radius.toDouble() : 6,
      tuneFaintText: contrast is YamlMap && contrast['tune_faint_text'] == true,
      overrides: overrides is YamlMap
          ? {for (final e in overrides.entries) '${e.key}': e.value}
          : const <String, Object?>{},
    );
    return knobs..validate();
  }

  /// Neutral scale name.
  final String neutral;

  /// Top surface in light mode, `#rrggbb`.
  final String surfaceTop;

  /// Hue name per role (see [hueRoleNames]).
  final Map<String, String> hues;

  /// Identity hue names; empty in Phase 1.
  final List<String> identity;

  /// `neutral` or `accent`.
  final String primary;

  /// The control radius `c`.
  final double radiusControl;

  /// Whether ink-9 and ink-10 may be shifted to pass the gates.
  final bool tuneFaintText;

  /// Deliberate changes to system values; printed when applied.
  final Map<String, Object?> overrides;

  /// Throws [KnobsException] if a name is outside the checked-in scales.
  void validate() {
    final names = <String, String>{
      'neutral': neutral,
      for (final e in hues.entries) 'hues.${e.key}': e.value,
      for (var i = 0; i < identity.length; i++)
        'hues.identity[$i]': identity[i],
    };
    final problems = [
      for (final e in names.entries)
        if (!radixScales.containsKey(e.value))
          '${e.key}: "${e.value}" is not a checked-in scale',
    ];
    if (problems.isNotEmpty) {
      throw KnobsException(
        '${problems.join('\n')}\n'
        'The foundation generator supports only: '
        '${radixScales.keys.join(', ')}. '
        'Use `kit tokens` (Phase 2) for the full Radix set.',
      );
    }
    if (primary != 'neutral' && primary != 'accent') {
      throw const KnobsException('primary must be "neutral" or "accent".');
    }
  }
}
