import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fonts.dart';
import 'stress.dart';

/// Counts how many states were created and disposed.
class _Probe extends StatefulWidget {
  const _Probe();

  static int created = 0;
  static int disposed = 0;

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  int touched = 0;

  @override
  void initState() {
    super.initState();
    _Probe.created++;
  }

  @override
  void dispose() {
    _Probe.disposed++;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A leak would show a non-zero value on a new fixture.
    expect(touched, 0);
    touched++;
    return const SizedBox(width: 10, height: 10);
  }
}

Widget _overflowing(BuildContext context, StressData data) => const Row(
  children: [
    SizedBox(width: 400, height: 10),
    SizedBox(width: 400, height: 10),
  ],
);

void main() {
  setUpAll(loadInterFont);

  group('profiles', () {
    test('default profile is quick', () {
      expect(StressProfile.fromEnvironment, StressProfile.quick);
    });

    test('quick has 17 labels', () {
      final cases = stressCases(StressProfile.quick);
      expect(cases, hasLength(17));
      expect(cases.map((c) => c.label).toSet(), hasLength(17));
      expect(
        cases.where((c) => c.size == const Size(375, 812)).single.label,
        '375×812 @1.0 x1.0 dark touch | normal',
      );
    });

    test('full has 48 groups and 384 labels', () {
      final groups = stressGroups(StressProfile.full);
      expect(groups, hasLength(48));
      expect(groups.every((g) => g.cases.length == 8), isTrue);
      final labels = stressCases(StressProfile.full).map((c) => c.label);
      expect(labels, hasLength(384));
      expect(labels.toSet(), hasLength(384));
    });

    test('fixture table has the exact values', () {
      final long = StressData.of(StressFixture.long).text!;
      expect(long.split(' '), hasLength(60));
      final word = StressData.of(StressFixture.longWord).text!;
      expect(word.length, 80);
      expect(word.contains(' '), isFalse);
      final big = StressData.of(StressFixture.bigNumber).number!;
      expect(big.toString(), hasLength(9));
      expect(StressData.of(StressFixture.nullValue).text, isNull);
      expect(StressData.of(StressFixture.rtl).direction, TextDirection.rtl);
    });
  });

  group('stressTest', () {
    stressTest(
      'flexible text',
      (context, data) => Text(data.text ?? '', maxLines: 2),
    );
  });

  group('rendering', () {
    final first = stressCases(StressProfile.quick).first;

    testWidgets('an overflowing widget fails with the case in its message', (
      tester,
    ) async {
      Object? failure;
      try {
        await runStressCase(tester, first, _overflowing);
      } on TestFailure catch (e) {
        failure = e;
      }
      // expectLater is itself a guarded test API, so it cannot wrap a render.
      expect(failure, isA<TestFailure>());
      final message = (failure! as TestFailure).message!;
      for (final part in [
        '320×640',
        'x1.0',
        'light',
        'touch',
        'normal',
        'overflowed',
      ]) {
        expect(message, contains(part));
      }
    });

    test('the failure image folder is ignored by git', () {
      final result = Process.runSync('git', [
        'check-ignore',
        'test/core/widgets/failures/x.png',
      ]);
      expect(result.exitCode, 0, reason: 'rule missing in .gitignore');
    });

    testWidgets('a flexible Text passes in all 17 quick cases', (
      tester,
    ) async {
      for (final c in stressCases(StressProfile.quick)) {
        await runStressCase(
          tester,
          c,
          (context, data) => Text(data.text ?? '', maxLines: 2),
        );
      }
    });

    testWidgets('text is measured with Inter, not Ahem', (tester) async {
      late double width;
      await runStressCase(tester, first, (context, data) {
        final painter = TextPainter(
          text: const TextSpan(
            text: 'Weekly report',
            style: TextStyle(fontFamily: 'Inter', fontSize: 16),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        width = painter.width;
        return const SizedBox.shrink();
      });
      // Ahem is one em per character: 13 characters at 16 px.
      expect(width, isNot(13 * 16.0));
    });

    testWidgets('a group of fixtures leaks no state between fixtures', (
      tester,
    ) async {
      _Probe.created = 0;
      _Probe.disposed = 0;
      final group = stressGroups(StressProfile.full).first;
      for (final c in group.cases) {
        await runStressCase(tester, c, (context, data) => const _Probe());
      }
      expect(_Probe.created, 8);
      expect(_Probe.disposed, 8);
    });
  });
}
