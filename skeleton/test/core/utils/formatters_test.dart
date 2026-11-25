import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:skeleton/core/utils/formatters.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('id');
  });

  final en = AppFormatters('en');
  final id = AppFormatters('id');

  test('money omits decimals for whole amounts', () {
    expect(en.money(1500, currencyCode: 'USD'), r'$1,500');
    expect(en.money(1500.5, currencyCode: 'USD'), r'$1,500.50');
    expect(id.money(1500, currencyCode: 'IDR'), 'Rp1.500');
    expect(id.money(1500.5, currencyCode: 'IDR'), 'Rp1.500,50');
  });

  test('number groups and keeps decimals only when present', () {
    expect(en.number(1234567), '1,234,567');
    expect(en.number(1234.5), '1,234.50');
    expect(id.number(1234567), '1.234.567');
  });

  test('compact applies above six digits only', () {
    expect(en.compact(1200000), '1.2M');
    expect(id.compact(1200000), '1,2\u00A0jt');
    expect(en.compact(999999), '999,999');
    expect(id.compact(999999), '999.999');
  });

  test('null gives an en dash', () {
    expect(en.enDashIfNull(null), '\u2013');
    expect(id.enDashIfNull(null), '\u2013');
    expect(en.enDashIfNull(5), '5');
  });

  test('date follows the locale', () {
    final day = DateTime(2026, 11, 26);

    expect(en.date(day), 'Nov 26, 2026');
    expect(id.date(day), '26 Nov 2026');
  });
}
