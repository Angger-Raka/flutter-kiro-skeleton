import 'package:intl/intl.dart';

/// Locale-aware formatting for dates, numbers, money, and compact numbers.
/// The only place values are formatted for display.
class AppFormatters {
  /// Creates formatters for [locale], a language code such as `en` or `id`.
  AppFormatters(this.locale);

  /// Language code the output follows.
  final String locale;

  /// What a missing value shows.
  static const String enDash = '\u2013';

  /// Numbers with more digits than this use compact notation.
  static const int _compactFrom = 1000000;

  /// Localized medium date, for example `Nov 26, 2026`.
  String date(DateTime date) => DateFormat.yMMMd(locale).format(date);

  /// Grouped number. Keeps up to two decimals.
  String number(num value) => NumberFormat.decimalPatternDigits(
    locale: locale,
    decimalDigits: value == value.roundToDouble() ? 0 : 2,
  ).format(value);

  /// Money in [currencyCode]. A whole amount has no decimals.
  String money(num amount, {required String currencyCode}) =>
      NumberFormat.simpleCurrency(
        locale: locale,
        name: currencyCode,
        decimalDigits: amount == amount.roundToDouble() ? 0 : 2,
      ).format(amount);

  /// Compact notation (`1.2M`, `1,2 jt`) above six digits, else [number].
  /// The full value belongs in a tooltip.
  String compact(num value) => value.abs() >= _compactFrom
      ? NumberFormat.compact(locale: locale).format(value)
      : number(value);

  /// [number] of [value], or an en dash when it is null.
  String enDashIfNull(num? value) => value == null ? enDash : number(value);
}
