import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';

import 'fonts.dart';
import 'stress.dart';

/// Draws the first [count] strings with [seed], as `stressProperty` does.
void _draw(List<String> into, int seed, {int count = 20}) {
  property('draw with seed $seed (${into.hashCode})', () {
    forAll(
      string(maxLength: 120),
      into.add,
      seed: seed,
      maxExamples: count,
    );
  });
}

void main() {
  setUpAll(loadInterFont);

  // Renders a Text for 20 generated strings and numbers; the property test
  // registered inside runs first, then the render test.
  stressProperty(
    'flexible text',
    (context, data) => Text('${data.text} ${data.number}', maxLines: 2),
  );

  final first = <String>[];
  final second = <String>[];
  final other = <String>[];
  _draw(first, stressPropertySeed);
  _draw(second, stressPropertySeed);
  _draw(other, 7);

  test('the seed makes two runs generate the same values', () {
    expect(first, hasLength(20));
    expect(second, first);
    expect(other, isNot(first));
  });

  testWidgets('a known-overflowing widget makes the samples fail', (
    tester,
  ) async {
    Object? failure;
    try {
      await runStressSamples(
        tester,
        [StressData.of(StressFixture.normal)],
        (context, data) => const Row(
          children: [
            SizedBox(width: 400, height: 10),
            SizedBox(width: 400, height: 10),
          ],
        ),
      );
    } on TestFailure catch (e) {
      failure = e;
    }
    expect(failure, isA<TestFailure>());
    final message = (failure! as TestFailure).message!;
    expect(message, contains('overflowed'));
    expect(message, contains('sample 0'));
  });
}
