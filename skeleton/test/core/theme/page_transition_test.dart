import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeleton/core/theme/tactile/page_transition.dart';

void main() {
  const marker = Key('marker');

  Future<void> pushPage(WidgetTester tester, {required bool reduce}) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(disableAnimations: reduce),
        child: MaterialApp(
          theme: ThemeData(pageTransitionsTheme: tactilePageTransitionsTheme),
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const Scaffold(
                    body: Align(
                      alignment: Alignment.topLeft,
                      child: SizedBox(key: marker, width: 10, height: 10),
                    ),
                  ),
                ),
              ),
              child: const Text('go'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
  }

  testWidgets('normal motion rises 16 px and settles at 0', (tester) async {
    await pushPage(tester, reduce: false);
    expect(tester.getTopLeft(find.byKey(marker)).dy, closeTo(16, 0.5));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byKey(marker)).dy, 0);
  });

  testWidgets('reduced motion has no travel', (tester) async {
    await pushPage(tester, reduce: true);
    expect(tester.getTopLeft(find.byKey(marker)).dy, 0);
    final fade = tester.widget<FadeTransition>(
      find
          .ancestor(
            of: find.byKey(marker),
            matching: find.byType(FadeTransition),
          )
          .first,
    );
    expect(fade.opacity.value, lessThan(1));
    await tester.pumpAndSettle();
  });
}
