import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';

import 'fonts.dart';
import 'stress.dart';

/// Seed of every `stressProperty`, fixed so CI is deterministic (Req 9.8).
const stressPropertySeed = 20260126;

/// Renders [builder] with random strings and numbers drawn by `kiri_check`.
///
/// Path taken (spike A7, `spikes/crew-run/S5-A7.md`): the design's fallback.
/// A `forAll` block cannot render: it runs inside a plain `test`, where
/// `binding.pump` asserts `inTest` and there is no `WidgetTester`. So a
/// `property` first draws [maxExamples] samples with a fixed [seed], and one
/// `testWidgets` registered after it renders every sample in the quick cases
/// with the `normal` fixture. The property test runs before the render test
/// because tests of one file run in registration order.
void stressProperty(
  String name,
  StressBuilder builder, {
  int seed = stressPropertySeed,
  int maxExamples = 20,
}) {
  final samples = <StressData>[];
  property('$name | stressProperty draws samples', () {
    forAll(
      combine2(
        string(maxLength: 120),
        integer(min: -999999999, max: 999999999),
      ),
      (v) => samples.add(_sample(v.$1, v.$2)),
      seed: seed,
      maxExamples: maxExamples,
    );
  });
  setUpAll(loadInterFont);
  testWidgets('$name | stressProperty renders samples', (tester) async {
    expect(samples, isNotEmpty, reason: 'the property drew no sample');
    await runStressSamples(tester, samples, builder);
  });
}

/// Renders every sample in the `normal` cases of the quick profile. A failure
/// message starts with the case label and names the sample.
Future<void> runStressSamples(
  WidgetTester tester,
  List<StressData> samples,
  StressBuilder builder,
) async {
  final cases = stressCases(
    StressProfile.quick,
    fixtures: const {StressFixture.normal},
  );
  for (final (i, sample) in samples.indexed) {
    for (final c in cases) {
      try {
        await runStressCase(
          tester,
          c,
          builder,
          data: sample,
          saveFailureImage: false,
        );
      } on TestFailure catch (e) {
        throw TestFailure(
          '${e.message}\nsample $i: text "${sample.text}", '
          'number ${sample.number}',
        );
      }
    }
  }
}

StressData _sample(String raw, int number) {
  // The generator can draw a lone surrogate, which Text rejects. UTF-8
  // encoding replaces each one with U+FFFD.
  final text = utf8.decode(utf8.encode(raw));
  return StressData(
    fixture: StressFixture.normal,
    text: text,
    secondary: text,
    number: number,
  );
}
