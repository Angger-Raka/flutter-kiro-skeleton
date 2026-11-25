/// Small non-visual helpers. No colour or size values belong here.
extension NullableStringX on String? {
  /// True when the string is null, empty, or only whitespace.
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;
}
