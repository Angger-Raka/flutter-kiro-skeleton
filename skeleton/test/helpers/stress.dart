import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skeleton/core/l10n/app_localizations.dart';
import 'package:skeleton/core/layout/window_class.dart';
import 'package:skeleton/core/theme/app_theme.dart';

import 'fonts.dart';
import 'surface_host.dart';

/// Hostile data a widget must survive (design "Fixtures").
enum StressFixture {
  normal,
  long,
  longWord,
  empty,
  emoji,
  rtl,
  bigNumber,
  nullValue,
}

/// What a fixture gives to the widget builder.
class StressData {
  const StressData({
    required this.fixture,
    required this.text,
    required this.number,
    this.secondary,
    this.direction = TextDirection.ltr,
  });

  /// Data of [fixture] (the exact values of the design table).
  factory StressData.of(StressFixture fixture) => switch (fixture) {
    StressFixture.normal => StressData(
      fixture: fixture,
      text: 'Weekly report',
      secondary: 'Updated today',
      number: 1280,
    ),
    StressFixture.long => StressData(
      fixture: fixture,
      text: _words(60),
      secondary: _words(60),
      number: 1280,
    ),
    StressFixture.longWord => StressData(
      fixture: fixture,
      text: 'W' * 80,
      secondary: 'W' * 80,
      number: 1280,
    ),
    StressFixture.empty => StressData(
      fixture: fixture,
      text: '',
      secondary: '',
      number: 0,
    ),
    StressFixture.emoji => StressData(
      fixture: fixture,
      text: 'Plan 🚀 review 👩\u200D💻✅',
      secondary: 'Done ✅',
      number: 1280,
    ),
    StressFixture.rtl => StressData(
      fixture: fixture,
      text: 'مرحبا بكم في التطبيق الجديد',
      secondary: 'تم التحديث اليوم',
      number: 1280,
      direction: TextDirection.rtl,
    ),
    StressFixture.bigNumber => StressData(
      fixture: fixture,
      text: 'Total',
      secondary: 'Sum',
      number: 123456789,
    ),
    StressFixture.nullValue => StressData(
      fixture: fixture,
      text: null,
      number: null,
    ),
  };

  final StressFixture fixture;
  final String? text;
  final String? secondary;
  final num? number;
  final TextDirection direction;

  static String _words(int count) {
    const base = [
      'lorem',
      'ipsum',
      'dolor',
      'sit',
      'amet',
      'consectetur',
      'adipiscing',
      'elit',
      'sed',
      'do',
    ];
    return [for (var i = 0; i < count; i++) base[i % base.length]].join(' ');
  }
}

typedef StressBuilder = Widget Function(BuildContext context, StressData data);

/// Size of the render set of one [stressTest].
enum StressProfile {
  /// 17 renders per widget.
  quick,

  /// 384 renders per widget in 48 groups.
  full;

  /// Profile named by `--dart-define=STRESS=full`. Default `quick`.
  static StressProfile get fromEnvironment =>
      const String.fromEnvironment('STRESS') == 'full' ? full : quick;
}

/// One render: a window, an input mode, a text scale, a theme, a fixture.
@immutable
class StressCase {
  const StressCase({
    required this.size,
    required this.devicePixelRatio,
    required this.textScale,
    required this.brightness,
    required this.input,
    required this.fixture,
  });

  final Size size;
  final double devicePixelRatio;
  final double textScale;
  final Brightness brightness;
  final InputMode input;
  final StressFixture fixture;

  /// Case label without the fixture.
  String get groupLabel =>
      '${size.width.toInt()}×${size.height.toInt()} '
      '@$devicePixelRatio x$textScale ${brightness.name} ${input.name}';

  /// Full label: `<w>×<h> @<dpr> x<scale> <theme> <input> | <fixture>`.
  String get label => '$groupLabel | ${fixture.name}';
}

/// Cases that share one window setup. `full` pumps the fixtures of a group in
/// one `testWidgets`; `quick` has one fixture per group.
class StressGroup {
  const StressGroup(this.cases);

  final List<StressCase> cases;

  String get name => cases.first.groupLabel;
}

const _quickSmall = Size(320, 640);
const _quickWide = Size(1600, 900);
const _quickDark = Size(375, 812);
const _fullSizes = <Size>[
  Size(320, 640),
  Size(375, 812),
  Size(768, 1024),
  Size(1024, 768),
  Size(1200, 800),
  Size(1600, 900),
];

/// The groups of [profile] for [fixtures].
List<StressGroup> stressGroups(
  StressProfile profile, {
  Set<StressFixture> fixtures = const {...StressFixture.values},
}) {
  final ordered = [
    for (final f in StressFixture.values)
      if (fixtures.contains(f)) f,
  ];
  StressCase make(
    Size size,
    double dpr,
    double scale,
    Brightness b,
    InputMode input,
    StressFixture f,
  ) => StressCase(
    size: size,
    devicePixelRatio: dpr,
    textScale: scale,
    brightness: b,
    input: input,
    fixture: f,
  );

  switch (profile) {
    case StressProfile.quick:
      return [
        for (final f in ordered)
          StressGroup([
            make(_quickSmall, 2, 1, Brightness.light, InputMode.touch, f),
          ]),
        for (final f in ordered)
          StressGroup([
            make(_quickWide, 1, 1, Brightness.light, InputMode.pointer, f),
          ]),
        if (fixtures.contains(StressFixture.normal))
          StressGroup([
            make(
              _quickDark,
              1,
              1,
              Brightness.dark,
              InputMode.touch,
              StressFixture.normal,
            ),
          ]),
      ];
    case StressProfile.full:
      return [
        for (final size in _fullSizes)
          for (final input in InputMode.values)
            // Touch up to and including 1024 wide, pointer from 768 wide up.
            if (input == InputMode.touch
                ? size.width <= 1024
                : size.width >= 768)
              for (final scale in const [1.0, 1.5, 2.0])
                for (final b in Brightness.values)
                  StressGroup([
                    for (final f in ordered)
                      make(
                        size,
                        input == InputMode.touch ? 2 : 1,
                        scale,
                        b,
                        input,
                        f,
                      ),
                  ]),
      ];
  }
}

/// Every labelled render of [profile].
List<StressCase> stressCases(
  StressProfile profile, {
  Set<StressFixture> fixtures = const {...StressFixture.values},
}) => [
  for (final g in stressGroups(profile, fixtures: fixtures)) ...g.cases,
];

/// Renders one case and fails with the case label on any `FlutterError`
/// (including `RenderFlex overflowed`). Leaves the tree empty and restores the
/// platform override. [saveFailureImage] writes `failures/<label>.png` next to
/// the running test file (best effort, errors ignored).
Future<void> runStressCase(
  WidgetTester tester,
  StressCase c,
  StressBuilder builder, {
  bool saveFailureImage = true,
}) async {
  tester.view
    ..devicePixelRatio = c.devicePixelRatio
    ..physicalSize = c.size * c.devicePixelRatio;
  tester.platformDispatcher
    ..textScaleFactorTestValue = c.textScale
    ..platformBrightnessTestValue = c.brightness;
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearAllTestValues();
  });

  final previousOnError = FlutterError.onError;
  final previousPlatform = debugDefaultTargetPlatformOverride;
  final errors = <FlutterErrorDetails>[];
  final boundary = GlobalKey();
  FlutterError.onError = errors.add;
  debugDefaultTargetPlatformOverride = c.input == InputMode.touch
      ? TargetPlatform.iOS
      : TargetPlatform.macOS;
  try {
    final data = StressData.of(c.fixture);
    final theme = buildTheme(
      c.brightness,
      WindowClassX.fromWidth(c.size.width),
      c.input,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        darkTheme: theme,
        locale: Locale(c.fixture == StressFixture.rtl ? 'ar' : 'en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Directionality(
          textDirection: data.direction,
          child: SurfaceHost(
            brightness: c.brightness,
            size: c.size,
            boundaryKey: boundary,
            child: Builder(builder: (context) => builder(context, data)),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    final thrown = tester.takeException();
    if (thrown != null) {
      errors.add(FlutterErrorDetails(exception: thrown as Object));
    }
    if (errors.isNotEmpty) {
      if (saveFailureImage) await _saveFailureImage(tester, boundary, c);
      final details = errors
          .map((e) => e.exceptionAsString().split('\n').first)
          .join('\n');
      throw TestFailure('${c.label}\n$details');
    }
  } finally {
    await tester.pumpWidget(const SizedBox.shrink());
    tester.takeException();
    FlutterError.onError = previousOnError;
    debugDefaultTargetPlatformOverride = previousPlatform;
  }
}

Future<void> _saveFailureImage(
  WidgetTester tester,
  GlobalKey boundary,
  StressCase c,
) async {
  try {
    final comparator = goldenFileComparator;
    if (comparator is! LocalFileComparator) return;
    final render = boundary.currentContext?.findRenderObject();
    if (render is! RenderRepaintBoundary) return;
    await tester.runAsync(() async {
      final image = await render.toImage();
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return;
      final dir = Directory.fromUri(comparator.basedir.resolve('failures/'));
      await dir.create(recursive: true);
      final name = c.label.replaceAll(RegExp('[^A-Za-z0-9.]+'), '_');
      await File('${dir.path}$name.png').writeAsBytes(
        bytes.buffer.asUint8List(),
      );
    });
  } on Object {
    // Best effort: a missing image must not hide the real failure.
  }
}

/// Renders the widget of [builder] across the cases of [profile], and fails
/// with the case label on any overflow or other `FlutterError`.
///
/// Loads the bundled Inter font once so metrics match the app.
void stressTest(
  String name,
  StressBuilder builder, {
  Set<StressFixture> fixtures = const {...StressFixture.values},
  StressProfile? profile,
}) {
  setUpAll(loadInterFont);
  for (final group in stressGroups(
    profile ?? StressProfile.fromEnvironment,
    fixtures: fixtures,
  )) {
    final single = group.cases.length == 1;
    final fixture = single ? ' | ${group.cases.first.fixture.name}' : '';
    testWidgets(
      '$name | ${group.name}$fixture',
      (tester) async {
        for (final c in group.cases) {
          await runStressCase(tester, c, builder);
        }
      },
    );
  }
}
