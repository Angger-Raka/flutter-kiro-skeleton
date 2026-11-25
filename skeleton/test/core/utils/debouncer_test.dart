import 'package:flutter_test/flutter_test.dart';
import 'package:skeleton/core/utils/debouncer.dart';
import 'package:skeleton/core/utils/extensions.dart';

void main() {
  const wait = Duration(milliseconds: 400);

  testWidgets('rapid calls collapse to one', (tester) async {
    final debouncer = Debouncer(wait);
    final calls = <int>[];

    debouncer.run(() => calls.add(1));
    await tester.pump(const Duration(milliseconds: 100));
    debouncer.run(() => calls.add(2));
    await tester.pump(const Duration(milliseconds: 100));
    debouncer.run(() => calls.add(3));
    await tester.pump(const Duration(milliseconds: 399));
    expect(calls, isEmpty);

    await tester.pump(const Duration(milliseconds: 1));
    expect(calls, [3]);
  });

  testWidgets('dispose cancels the pending action', (tester) async {
    final debouncer = Debouncer(wait);
    var called = false;

    debouncer
      ..run(() => called = true)
      ..dispose();
    await tester.pump(wait * 2);

    expect(called, isFalse);
  });

  test('isNullOrBlank', () {
    expect(null.isNullOrBlank, isTrue);
    expect(' '.isNullOrBlank, isTrue);
    expect('a'.isNullOrBlank, isFalse);
  });
}
