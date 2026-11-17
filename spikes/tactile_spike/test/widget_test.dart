import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tactile_spike/main.dart';
import 'package:tactile_spike/tactile.dart';

import 'load_fonts.dart';

Future<(FocusNode, FocusNode, List<String>)> _pump(WidgetTester tester) async {
  final cancel = FocusNode(), create = FocusNode();
  final log = <String>[];
  addTearDown(cancel.dispose);
  addTearDown(create.dispose);
  tester.view.physicalSize = const Size(390 * 2, 400 * 2);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(
    theme: buildTheme(Brightness.light),
    home: Scaffold(
      body: CardDemo(
        cancelFocus: cancel,
        createFocus: create,
        onCancel: () => log.add('cancel'),
        onCreate: () => log.add('create'),
      ),
    ),
  ));
  return (cancel, create, log);
}

void main() {
  setUpAll(loadInter);

  testWidgets('Tab moves focus through the buttons in order', (tester) async {
    final (cancel, create, _) = await _pump(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(cancel.hasPrimaryFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(create.hasPrimaryFocus, isTrue);
  });

  testWidgets('Enter and Space activate the focused button', (tester) async {
    final (cancel, create, log) = await _pump(tester);
    cancel.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    create.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    expect(log, ['cancel', 'cancel', 'create', 'create']);
  });

  testWidgets('each button has a semantics label', (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester);
    for (final (key, label) in [('secondary', 'Cancel'), ('primary', 'Create project')]) {
      final node = tester.getSemantics(find.bySemanticsLabel(label));
      expect(node.label, label);
      expect(node.flagsCollection.isButton, isTrue);
      expect(find.byKey(Key(key)), findsOneWidget);
    }
    handle.dispose();
  });

  testWidgets('androidTapTargetGuideline and labeledTapTargetGuideline hold',
      (tester) async {
    final handle = tester.ensureSemantics();
    await _pump(tester);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('hit area is 48 high while the visual stays 36', (tester) async {
    final (_, _, log) = await _pump(tester);
    final slot = tester.getRect(find.byKey(const Key('primary')));
    expect(slot.height, 48);
    final visual = tester.getRect(find
        .descendant(
            of: find.byKey(const Key('primary')),
            matching: find.byType(DecoratedBox))
        .first);
    expect(visual.height, 36);
    // 3 px below the visual bottom edge is outside the visual but inside the hit area.
    await tester.tapAt(Offset(slot.center.dx, visual.bottom + 3));
    expect(log, ['create']);
  });

  testWidgets('app root: no debug underline, whole window follows the theme',
      (tester) async {
    tester.view.physicalSize = const Size(900, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const SpikeApp());
    final text = find.text('Dark mode');
    expect(DefaultTextStyle.of(tester.element(text)).style.decoration,
        isNot(TextDecoration.underline));
    expect(find.byType(Scaffold), findsOneWidget);
    expect(tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        const Color(0xFFF9F9F8));
    await tester.tap(text);
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        const Color(0xFF080807));
    expect(find.text('Light mode'), findsOneWidget);
  });

  test('S15: SpringDescription.withDurationAndBounce compiles and settles', () {
    final s = SpringDescription.withDurationAndBounce(
        duration: const Duration(milliseconds: 400), bounce: 0.12);
    // ignore: avoid_print
    print('mass ${s.mass} stiffness ${s.stiffness} damping ${s.damping}');
    final sim = SpringSimulation(s, 0, 1, 0);
    expect(sim.isDone(2), isTrue);
    expect(sim.x(2), closeTo(1, 0.01));
    expect(s.damping, greaterThan(0));
  });
}
