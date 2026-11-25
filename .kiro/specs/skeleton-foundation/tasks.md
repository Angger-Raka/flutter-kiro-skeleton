# Implementation Plan: skeleton-foundation

## Overview

This plan implements `requirements.md` (24 requirements) and `design.md` in the build order of the design
(`Sequencing and dependencies between pieces`). All paths are relative to `skeleton/` unless stated.

How to read a task:

- Each leaf task (`N.M`) is one small change with **one Conventional Commit**. The commit line is given in the task.
- Tests live inside the task that adds the logic. A task is not done until its tests pass.
- `_Requirements: x.y_` lists the acceptance criteria the task satisfies. `_Properties: n_` lists the design properties it covers.
- Every task ends with the gate **G**: `dart format --set-exit-if-changed .`, `flutter analyze` with zero issues, and `flutter test` green (where tests exist). Tasks that change annotated code also run `dart run build_runner build -d` first. G is not repeated in each task.
- Tasks marked **[USER ACTION]** need the user and cannot be done by an agent.
- Manual verification tasks are in section 10. They change no code. Only 10.8 and 10.12 produce a commit (they record results in `README.md`).
- Rules for every task: preserve existing files (`assets/fonts/`, `THIRD_PARTY_NOTICES.md`), do not touch `docs/brief/`, `permissions.yaml`, or the Pages workflow, and do not add a dependency that is not in requirement 2.

Commit style: `type(scope): imperative subject`, at most 72 characters, scope = the area (`skeleton`, `tokens`, `theme`, `core`, `app`, `web`, `android`, `macos`, `test`, `docs`).

## Tasks

- [x] 1. Scaffold, toolchain, dependencies, platform setup

  - [x] 1.1 Create the Flutter project and pin the toolchain
    - Run `fvm use 3.44.8` inside `skeleton/` to write `skeleton/.fvmrc`, then `flutter create --org dev.angga --project-name skeleton --platforms=android,ios,web,macos,windows,linux .` in `skeleton/`. Do not overwrite `assets/fonts/` or `THIRD_PARTY_NOTICES.md`.
    - Set the Dart SDK constraint in `pubspec.yaml` to a range that includes 3.12.2 (for example `^3.12.0`).
    - Leave the template `lib/main.dart` and `test/widget_test.dart` for now. Both are replaced in 6.7.
    - Acceptance: `fvm flutter --version` prints 3.44.8 and Dart 3.12.2 in `skeleton/`. `applicationId`, `namespace`, and the iOS and macOS `PRODUCT_BUNDLE_IDENTIFIER` start with `dev.angga.skeleton`. `flutter analyze` passes on the template.
    - Commit: `chore(skeleton): scaffold Flutter project for all platforms`
    - _Requirements: 1.1, 1.2, 1.4, 1.7_

  - [x] 1.2 Set the display name "Skeleton" on all six platforms
    - Change the label in `AndroidManifest.xml`, `CFBundleDisplayName` and `CFBundleName` in iOS and macOS `Info.plist` (macOS `PRODUCT_NAME` in `AppInfo.xcconfig`), `web/index.html` `<title>` and apple-mobile-web-app-title, `web/manifest.json` `name` and `short_name`, `windows/runner/main.cpp` window title and `Runner.rc`, and `linux/runner/my_application.cc` title.
    - Acceptance: `grep -rn "skeleton"` in those files shows no user-visible lower-case name left. The display name reads "Skeleton" in each file.
    - Commit: `chore(skeleton): set display name to Skeleton on all platforms`
    - _Requirements: 1.3, 4.5_

  - [x] 1.3 Check `.gitignore` rules
    - Make sure `.gitignore` does not ignore `.kiro/`, `lib/core/theme/tokens.g.dart`, `docs/` generated files, or `pubspec.lock`. Add `*.freezed.dart`. Keep `.dart_tool/` and `build/` ignored.
    - Acceptance: `git check-ignore -v lib/core/theme/tokens.g.dart pubspec.lock lib/app/di/injection.config.dart .kiro/specs` prints nothing. `git check-ignore -v lib/core/settings/app_settings.freezed.dart` reports the rule.
    - Commit: `chore(skeleton): adjust gitignore for generated files policy`
    - _Requirements: 1.6, 2.6, 7.5_

  - [x] 1.4 Add runtime and dev dependencies with pinned versions
    - `flutter pub add` each package of requirement 2.1 and `dev:` each package of 2.2, including `kiri_check` 1.4.0. Pin each to an exact version (no caret) or a tight range, taken from `flutter pub add` on the pinned SDK.
    - Do not add `json_serializable`, `json_annotation`, `drift`, `drift_flutter`, `sqlite3_flutter_libs`, `cached_network_image`, or any `kit` dependency.
    - Add the `flutter_localizations` SDK dependency and `flutter: generate: true`.
    - Commit `pubspec.lock`.
    - Acceptance: `flutter pub get` succeeds. A script check of `pubspec.yaml` finds all required packages and none of the forbidden ones. Record the chosen versions in a scratch list for 9.1.
    - Commit: `chore(skeleton): add pinned foundation dependencies`
    - _Requirements: 2.1, 2.2, 2.3, 2.5, 2.6_

  - [x] 1.5 Enable very_good_analysis
    - Write `analysis_options.yaml` that includes `package:very_good_analysis/analysis_options.yaml`. Add excludes only for generated files (`**/*.g.dart`, `**/*.freezed.dart`, `**/injection.config.dart`, `lib/core/l10n/app_localizations*.dart`).
    - Fix lint findings in the template files that stay.
    - Acceptance: `flutter analyze` reports zero issues.
    - Commit: `chore(skeleton): enable very_good_analysis lints`
    - _Requirements: 2.4, 23.1_

  - [x] 1.6 Android: INTERNET permission and https queries
    - Add `<uses-permission android:name="android.permission.INTERNET"/>` to the main `AndroidManifest.xml` (not only debug/profile). Add the url_launcher `<queries>` entry for `https`.
    - Acceptance: a test in `test/platform/platform_setup_test.dart` reads the manifest and asserts the permission and the `https` query. `flutter analyze` and the test pass.
    - Commit: `fix(android): allow network access in release builds`
    - _Requirements: 3.1, 3.2_

  - [x] 1.7 macOS: network client entitlement
    - Set `com.apple.security.network.client` to `true` in `macos/Runner/DebugProfile.entitlements` and `Release.entitlements`. Add no iOS network configuration.
    - Acceptance: extend `platform_setup_test.dart` to assert both entitlement files, and that `ios/Runner/Info.plist` has no `NSAppTransportSecurity` key. Tests pass.
    - Commit: `fix(macos): add network client entitlement to both configurations`
    - _Requirements: 3.3, 3.4_

- [ ] 2. Radix scales, tokens file, and the token generator

  - [ ] 2.1 Fetch script and checked-in Radix scales
    - Write `tool/radix/fetch_scales.dart` (only `dart:io`, `dart:convert`). It downloads `src/light.ts`, `src/dark.ts` (and the alpha files it needs for a3 and a4) of `radix-ui/colors` at commit `dbdb854` for sand, slate, blue, green, red, and amber, parses the hex values, and writes `tool/radix/radix_scales.dart` with the `RadixScale` class of the design. No colour is typed by hand. Run it once and commit the output.
    - Write `tool/radix/README.md` (source repository, commit, how to re-run). Add Radix Colors (MIT) with the commit to `THIRD_PARTY_NOTICES.md` without changing the existing entries.
    - Test (`test/tool/radix_scales_test.dart`): every scale has 12 light and 12 dark values matching `#rrggbb`, plus a3 and a4 for both brightnesses.
    - Acceptance: the six scale names are present, the test passes, and `git diff` of `THIRD_PARTY_NOTICES.md` only adds lines.
    - Commit: `feat(tokens): add Radix scale fetcher and checked-in scales`
    - _Requirements: 13.2, 1.7_

  - [ ] 2.2 Write `design/tokens.yaml`
    - Use the default of the design: `neutral: sand`, hues accent blue, success green, danger red, warning amber, info blue, `identity: []`, `primary: neutral`, Inter Medium as sans (weight 500), `heading: null`, `mono: null`, `size_factor: 1.0`, tracking, `radius_control: 6`, `contrast.tune_faint_text: true`, `overrides: {}`.
    - Acceptance: the file parses with `package:yaml` in a test (`test/tool/tokens_yaml_test.dart`) and every named scale exists in `radixScales`.
    - Commit: `feat(tokens): add default design tokens file`
    - _Requirements: 13.1_

  - [ ] 2.3 Blur conversion as pure Dart
    - Create `lib/core/theme/tactile/blur_conversion.dart` with `double cssBlurToFlutter(double cssBlur)` = `max(0, (cssBlur / 2 - 0.5) / 0.57735)`. It imports only `dart:math`, so both the generator and `shadows.dart` can import it (see S2 gap G1).
    - Test (`test/core/theme/blur_conversion_test.dart`) with `kiri_check`: property 8 (formula and result ≥ 0), property 9 (`0` gives `0`), property 10 (monotonic). Add a table of known values.
    - Acceptance: tests pass, 100 or more generated cases per property.
    - Commit: `feat(theme): add CSS blur to Flutter blur conversion`
    - _Requirements: 14.1, 14.2, 14.3_
    - _Properties: 8, 9, 10_

  - [ ] 2.4 Colour maths for the generator
    - Create `tool/src/color_math.dart`: hex parse and format, sRGB to OKLab and OKLCH and back, OKLab mix, WCAG relative luminance and contrast ratio. Pure Dart.
    - Test (`test/tool/color_math_test.dart`): known pairs (black on white is 21:1, same colour is 1:1), round trip hex to OKLCH to hex within one unit per channel, and mix at 0 and 1.
    - Acceptance: tests pass.
    - Commit: `feat(tokens): add colour maths for the token generator`
    - _Requirements: 13.7, 14.5_

  - [ ] 2.5 Generator skeleton: read inputs and validate hues
    - Create `tool/generate_tokens.dart` with `main` calling a testable `Future<int> runGenerator({yamlPath, outputPath, stdout})`. It parses the YAML and resolves the neutral and each hue in `radixScales`. A name outside the set (including in `identity`) prints a message that points to `kit tokens`, returns a non-zero code, and does not touch the output file. Write the output atomically (write to a temp file, then rename) so a failure leaves the old file unchanged.
    - Test (`test/tool/generate_tokens_validation_test.dart`): an unknown neutral and an unknown hue return non-zero with the output file unchanged (checksum before and after). `identity: []` is accepted.
    - Acceptance: tests pass.
    - Commit: `feat(tokens): add generator entry point and hue validation`
    - _Requirements: 13.6_

  - [ ] 2.6 Generator: palette, hues, and primary
    - Emit `AppPalette.light` and `AppPalette.dark` (ink ramp, alpha a3 and a4, ground, panel, raised, overlay, well, primary background, foreground, hover with the 93%/7% OKLab mix), `HueScale`, `HueRole`, and an empty `identity` list. Follow `04` §4.2 for the derived surfaces.
    - Test (`test/tool/generate_tokens_palette_test.dart`): run on the default YAML into a temp file. Assert the output contains `AppPalette`, both brightness constants, five hue roles, and `identity: []`. Assert the header marks the file as generated.
    - Acceptance: tests pass. The temp output is valid Dart (`dart analyze` on it in the test).
    - Commit: `feat(tokens): generate palette, hue scales, and primary colours`
    - _Requirements: 13.3_

  - [ ] 2.7 Generator: ladders, sizes, and layout
    - Emit `AppSpace`, `AppRadius` (derived from `radius_control`), `AppStroke`, `AppSizeSet.pointer` and `AppSizeSet.touch`, and `AppLayout` (768, 1200, 800, 1200, 440, 256, 72, 52, 56, 8). Use the values of `04` §4.2.
    - Test: radius ladder for `radius_control: 6` and for another value (table). `AppLayout` constants match requirement 20.4 exactly.
    - Acceptance: tests pass.
    - Commit: `feat(tokens): generate spacing, radius, sizes, and layout tokens`
    - _Requirements: 13.3, 20.4_

  - [ ] 2.8 Generator: shadow recipes
    - Add the CSS shadow recipes of `04` §4.5 as data in `tool/src/shadow_recipes.dart`. Convert each blur with `cssBlurToFlutter`, keep offsets and spread, and emit rings as zero-blur spread shadows. Emit `AppShadows.light` and `AppShadows.dark` for button, primary, toggle, card, table, panel, menu, popover, modal, and badge.
    - Test: a ring recipe gives `blurRadius: 0`; a recipe with blur 10 gives the converted radius; offsets and spread are unchanged.
    - Acceptance: tests pass.
    - Commit: `feat(tokens): generate shadow lists with blur conversion`
    - _Requirements: 13.3, 14.1, 14.4_

  - [ ] 2.9 Generator: contrast gates
    - Implement every Contrast_Gate of `04` §4.6 for both themes in `tool/src/contrast_gates.dart` with the minimums given there. A failing gate prints the pair and its ratio, returns non-zero, and leaves the output unchanged. All gates passing returns 0.
    - Test (`test/tool/contrast_gates_test.dart`): the default YAML passes (exit code 0). A fixture YAML with `tune_faint_text: false` and a hue pair that fails a gate (for example a low-contrast override) returns non-zero, prints the pair, and leaves the output checksum unchanged.
    - Acceptance: tests pass. Record in the PR notes whether the default passes without tuning.
    - Commit: `feat(tokens): enforce contrast gates in the generator`
    - _Requirements: 14.5, 14.6, 14.7_
    - _Properties: 11, 12_

  - [ ] 2.10 Generator: faint-text tuning and overrides
    - When `tune_faint_text` is true, adjust only the OKLCH lightness of ink-9 and ink-10 until their gates pass, and print each adjustment. Print every applied `overrides` entry. Do not write `docs/DESIGN_TOKENS.md`.
    - Test (`test/tool/faint_text_tuning_test.dart`): hue and chroma of ink-9 and ink-10 are equal before and after (within 1e-6). Adjusted colours pass the gate. Stdout lists each adjustment and each override. No `docs/DESIGN_TOKENS.md` exists after a run.
    - Acceptance: tests pass.
    - Commit: `feat(tokens): tune faint text lightness and print overrides`
    - _Requirements: 13.7, 13.8, 13.9_
    - _Properties: 13_

  - [ ] 2.11 Generate and commit `tokens.g.dart`
    - Run `dart run tool/generate_tokens.dart`, check that the output compiles, and commit `lib/core/theme/tokens.g.dart`. The output contract (file name, class names, shape) stays compatible with `04` §4.2.
    - Test (`test/tool/generate_tokens_determinism_test.dart`): two runs with the same inputs produce byte-identical files, and the committed file equals a fresh run.
    - Acceptance: tests pass, `flutter analyze` is clean, and `git ls-files lib/core/theme/tokens.g.dart` lists the file.
    - Commit: `feat(tokens): add generated design tokens`
    - _Requirements: 13.3, 13.4, 13.5, 13.10_

- [ ] 3. Layout plumbing and tactile foundation

  - [ ] 3.1 Window class and input mode
    - Create `lib/core/layout/window_class.dart` with `WindowClass`, `InputMode`, `WindowClassX.fromWidth`, and the extensions `context.windowClass` and `context.inputMode`. Use `AppLayout` breakpoints. No `kIsWeb` and no `Platform`.
    - Test (`test/core/layout/window_class_test.dart`) with `kiri_check`: property 17 over random widths, plus the boundaries 767.99, 768, 1199.99, 1200. Property 18 over every `TargetPlatform` with `debugDefaultTargetPlatformOverride`.
    - Acceptance: tests pass.
    - Commit: `feat(layout): add window class and input mode`
    - _Requirements: 20.1, 20.2, 20.3, 20.5_
    - _Properties: 17, 18_

  - [ ] 3.2 Motion tokens and springs
    - Create `lib/core/theme/tactile/motion.dart` with `AppMotion` (curves `easeOut`, `easeMove`, `easeDrawer`, `easeInOut` and the durations 80, 120, 150, 200, 240, 300, 320 ms from `04` §8) and `AppSprings` (`toggle`, `knob`, `reveal`). Check whether Flutter 3.44.8 has `SpringDescription.withDurationAndBounce` (S15). If yes use it, otherwise use `mass 1, stiffness (2π/d)², damping 4π(1−bounce)/d`. Add `context.reduceMotion` as `MediaQuery.disableAnimationsOf(context)` in `theme_x.dart`'s file later (4.2); here add a standalone extension in `motion.dart` that 4.2 re-exports.
    - Test: duration and curve table; spring values for the three springs; `reduceMotion` returns true under `MediaQuery(disableAnimations: true)`.
    - Acceptance: tests pass. The S15 result is noted in the task commit body.
    - Commit: `feat(theme): add motion tokens and springs`
    - _Requirements: 18.1, 18.2, 18.3, 18.5_

  - [ ] 3.3 Page transition
    - Add the page entrance (fade and 16 px rise, 300 ms, on route mount only) as a `PageTransitionsBuilder` used for every platform. With `reduceMotion` it becomes a 150 to 200 ms crossfade with no travel.
    - Test (widget): normal motion shows an offset at the start of the transition; reduced motion shows none.
    - Acceptance: tests pass.
    - Commit: `feat(theme): add page entrance transition with reduced motion`
    - _Requirements: 18.4, 18.6_

  - [ ] 3.4 Typography and Inter registration
    - Register `assets/fonts/Inter-Medium.ttf` in `pubspec.yaml` (not the other two faces). Create `lib/core/theme/tactile/typography.dart` with the `AppTypography` ThemeExtension: roles `display, figure, section, title, body, description, meta, label, field, badge` with sizes, line heights, tracking, and ink steps from `04` §6.1. One weight from the tokens file. Flutter `height = lineHeight / fontSize` with `leadingDistribution: even`. Tabular figures on `figure` and amount roles. Mobile sizes for `mobile`, desktop sizes otherwise. `field` is 16/24 on touch. With `typography.heading` null, every role uses the sans face.
    - Test (`test/core/theme/typography_test.dart`): table of every role for mobile and desktop; all roles share one weight; `height` equals lineHeight over size; tabular figures present on `figure`; `field` on touch is 16/24.
    - Acceptance: tests pass.
    - Commit: `feat(theme): add AppTypography and register Inter Medium`
    - _Requirements: 17.1, 17.2, 17.3, 17.4, 17.5, 17.6, 17.7, 17.8_

  - [ ] 3.5 Surface kinds and SurfaceScope
    - Create `lib/core/theme/tactile/surface.dart` with `SurfaceKind` (`ground, rail, panel, raised, overlay, sheet, well`) and `SurfaceScope`: working ink steps 1 to 7 per the light remap and dark step-up rules of `04` §5, `line`, `hoverFill` (local ground + 1), `selectedFill` (local ground + 2), and the shadow accessors `button`, `primary`, `toggle`, `badge(hue)`. Steps 8 to 12 are identical everywhere. `SurfaceScope.of` with no ancestor returns the `panel` scope of the current brightness and does not throw.
    - Test (`test/core/theme/surface_scope_test.dart`): for every kind and both brightnesses, steps 8 to 12 equal the ground steps (property 15); `hoverFill != selectedFill` (property 16); the light remap table values for `rail`, `panel`, `overlay`, `sheet`; a widget without an ancestor reads the `panel` scope.
    - Acceptance: tests pass.
    - Commit: `feat(theme): add surface kinds and SurfaceScope`
    - _Requirements: 15.1, 15.3, 15.4, 15.5, 15.6, 15.9_
    - _Properties: 15, 16_

  - [ ] 3.6 Shadow selection per surface
    - Create `lib/core/theme/tactile/shadows.dart` with `ShadowRecipe` (using `cssBlurToFlutter`) and the per-surface, per-brightness selection of `List<BoxShadow>` from `AppShadows`. Wire `SurfaceScope` accessors to it. Dark surfaces use one solid 0.5 px outline plus a tight drop as in `04` §5.
    - Test: each recipe resolves to the same list as the generated `AppShadows` for the matching kind and brightness (table); `ShadowRecipe.toBoxShadow` converts blur with the shared function.
    - Acceptance: tests pass.
    - Commit: `feat(theme): resolve shadow recipes per surface and brightness`
    - _Requirements: 15.8_

  - [ ] 3.7 TactileSurface widget
    - Add `TactileSurface` to `surface.dart`. It paints fill, edge, and drop relative to the parent `SurfaceScope` and provides a new scope to its children. Radius and padding are optional. No raw colour or size literals.
    - Test (widget): nested `TactileSurface(raised)` inside `panel` gives its child a `raised` scope; the decoration colour equals the scope fill; light and dark both build.
    - Acceptance: tests pass.
    - Commit: `feat(theme): add TactileSurface widget`
    - _Requirements: 15.2_

  - [ ] 3.8 Pressable: press, hover, semantics
    - Create `lib/core/theme/tactile/pressable.dart`. `pressedScale` is a required parameter with no default. Press scales to it and release returns to 1. Hover shows `SurfaceScope.hoverFill`; on `touch` the hover fill shows while pressed. Button semantics with a label and the enabled state; `onPressed: null` disables it.
    - Test (widget): press and release scale values; hover on a mouse pointer shows the fill; touch press shows the fill; semantics label and enabled flag; disabled ignores taps.
    - Acceptance: tests pass.
    - Commit: `feat(theme): add Pressable with press scale, hover fill, semantics`
    - _Requirements: 16.1, 16.2, 16.5_

  - [ ] 3.9 Pressable: focus ring, hit area, reduced motion
    - Add the 2 px focus ring with 2 px offset for keyboard focus only. On `touch`, extend the hit area to at least 48 × 48 with a `MinHitArea` render object that pads layout to 48 without changing the visual size. With `reduceMotion`, the widget still works and does not animate travel or blur.
    - Test (widget): ring appears on keyboard focus and not on pointer press; on touch, tapping 4 px outside a 40 px visual still hits; the visual size is unchanged; reduced motion produces no scale animation frames beyond the end state.
    - Acceptance: tests pass.
    - Commit: `feat(theme): add Pressable focus ring, 48 px hit area, reduced motion`
    - _Requirements: 16.3, 16.4, 16.6_

- [ ] 4. Theme mapping

  - [ ] 4.1 `buildTheme`
    - Create `lib/core/theme/app_theme.dart` with `buildTheme(Brightness, WindowClass, InputMode)` returning `ThemeData` with the mapping of `04` §9: `NoSplash.splashFactory` and transparent highlight, `ColorScheme` (`primary` ink-12, `onPrimary` ink-1, `surface` panel colour, `error` danger-9), `TextTheme`, `InputDecorationTheme`, `TooltipTheme`, `ScrollbarTheme`, `DividerTheme`, `TextSelectionTheme`, `PageTransitionsTheme` (from 3.3, all platforms), `ProgressIndicatorTheme`, and the `AppTypography` extension. No raw colour, size, or duration literals.
    - Test (`test/core/theme/app_theme_test.dart`): the `ColorScheme` mapping for both brightnesses; `splashFactory` is `NoSplash.splashFactory`; the typography extension is present.
    - Acceptance: tests pass.
    - Commit: `feat(theme): add buildTheme mapping tactile tokens to Material`
    - _Requirements: 19.1, 19.2, 19.6, 16.7_

  - [ ] 4.2 Theme context extensions
    - Create `lib/core/theme/theme_x.dart` with `context.surface`, `context.text`, `context.sizes`, `context.hue(role)`, and `context.reduceMotion` (re-exported from 3.2).
    - Test (widget): each accessor returns the expected object under a `TactileSurface` and under a bare `MaterialApp`.
    - Acceptance: tests pass.
    - Commit: `feat(theme): add context extensions for tokens`
    - _Requirements: 19.3_

  - [ ] 4.3 Theme invariants across brightness
    - Add a test that builds the theme for light and dark for every `(WindowClass, InputMode)` pair and compares sizes, padding, radii, stroke widths, and text metrics (not colours). Rebuilding for a new window class keeps the same brightness.
    - Acceptance: test passes (property 14).
    - Commit: `test(theme): verify light and dark themes differ only in colour`
    - _Requirements: 15.7, 19.4, 19.5_
    - _Properties: 14_

- [ ] 5. Core infrastructure

  - [ ] 5.1 Failure and exceptions
    - Create `lib/core/error/failure.dart` (sealed, `freezed`: `network`, `unauthorized`, `notFound`, `validation`, `server(statusCode)`, `cache`, `unexpected(message)`) and `lib/core/error/exceptions.dart` (`AppException`, `CacheException`, others used by the design).
    - Test: constructing each case, equality, and `switch` exhaustiveness (compiles without default).
    - Acceptance: build_runner and tests pass.
    - Commit: `feat(core): add Failure and exception types`
    - _Requirements: 8.1_

  - [ ] 5.2 UseCase contract
    - Create `lib/core/usecase/usecase.dart` with `UseCase<Type, Params>` returning `Future<Either<Failure, Type>>` (fpdart) and `NoParams`.
    - Test: a fake use case returns `Right` and `Left`.
    - Acceptance: tests pass.
    - Commit: `feat(core): add UseCase contract`
    - _Requirements: 8.2_

  - [ ] 5.3 Logger with redaction
    - Create `lib/core/log/logger.dart` (`@lazySingleton`) with `logError`, `logFlutterError`, `logInfo`, and a pure `redact(String)` that masks `Authorization` header values, bearer tokens, and `password` and `token` fields. Output uses `debugPrint`.
    - Test (`test/core/log/logger_test.dart`): table of inputs for `redact` (header, bearer, JSON password, token query value, plain text untouched). Logging an error whose message holds a bearer token prints the masked text.
    - Acceptance: tests pass.
    - Commit: `feat(core): add Logger with redaction`
    - _Requirements: 6.6_

  - [ ] 5.4 KeyValueStore
    - Create `lib/core/storage/key_value_store.dart`: `KeyValueStore` interface (`getString`, `setString`, `remove`) and a `shared_preferences` implementation. No `shared_preferences` type in the interface. A failed write throws `CacheException`. Add an in-memory fake in `test/support/in_memory_key_value_store.dart` for tests.
    - Test (`SharedPreferences.setMockInitialValues`): read, write, remove; a write that returns false throws `CacheException`.
    - Acceptance: tests pass.
    - Commit: `feat(core): add KeyValueStore over shared_preferences`
    - _Requirements: 9.1, 9.2_

  - [ ] 5.5 LinkLauncher and ClipboardService
    - Create `lib/core/services/link_launcher.dart` (`canLaunchUrl` then `launchUrl`, returns false when it cannot launch) and `clipboard_service.dart`.
    - Test: `ClipboardService.copy` through the mocked platform channel; `LinkLauncher.open` with a mocked `UrlLauncherPlatform` for true and false.
    - Acceptance: tests pass.
    - Commit: `feat(core): add LinkLauncher and ClipboardService`
    - _Requirements: 9.3, 9.4_

  - [ ] 5.6 ApiClient and auth interceptor
    - Create `lib/core/network/api_client.dart` (single `Dio`, `get`/`post`/`put`/`delete`, accepts absolute URLs) and `interceptors/auth_interceptor.dart` (no-op, documented extension point). `domain/` does not import `dio` (checked in 8.1).
    - Test (a fake `HttpClientAdapter` written with `mocktail`, no new package): a request passes through the no-op interceptor unchanged; an absolute URL overrides `baseUrl`.
    - Acceptance: tests pass.
    - Commit: `feat(core): add ApiClient and no-op auth interceptor`
    - _Requirements: 8.3_

  - [ ] 5.7 `guardRepository` and Dio error mapping
    - Create `lib/core/network/dio_error_mapper.dart` with `guardRepository`, `mapDioException`, `mapAppException`, and `_mapStatus` exposed for tests via `@visibleForTesting` (401 and 403 unauthorized, 404 notFound, 422 validation, others server with status; 4xx and 5xx give different subtypes).
    - Test (`test/core/network/dio_error_mapper_test.dart`) with `kiri_check`: property 5 (never throws for any thrown object), property 6 (status mapping for every integer 100 to 599), property 7 (the four connectivity `DioExceptionType`s give `network`). Add a table for `badResponse` without a status and `cancel`.
    - Acceptance: tests pass.
    - Commit: `feat(core): add guardRepository and Dio error mapper`
    - _Requirements: 8.4, 8.5, 8.6, 8.7_
    - _Properties: 5, 6, 7_

  - [ ] 5.8 AppSettings model
    - Create `lib/core/settings/app_settings.dart` (`freezed`; `AppThemeMode` system, light, dark; `AppLocale` system, en, id; defaults system and system; `flutterThemeMode`; `flutterLocale` returning null for `system`).
    - Test with `kiri_check`: property 4 for every enum value; defaults.
    - Acceptance: build_runner and tests pass.
    - Commit: `feat(settings): add AppSettings model`
    - _Requirements: 10.1, 10.2, 10.3_
    - _Properties: 4_

  - [ ] 5.9 AppSettingsCubit
    - Create `lib/core/settings/app_settings_cubit.dart`. `load()` reads two keys, parses by enum name, and falls back to `system` for unknown or missing. `setThemeMode` and `setLocale` emit first and then save through `KeyValueStore`. A `CacheException` keeps the state and does not crash.
    - Test (`bloc_test` and `kiri_check` over `InMemoryKeyValueStore`): property 1 (empty store gives defaults), property 2 (write, new cubit, load, same values for all 9 combinations), property 3 (any string not an enum name gives `system`), save failure keeps the in-memory value.
    - Acceptance: tests pass.
    - Commit: `feat(settings): add AppSettingsCubit with persistence`
    - _Requirements: 10.5, 10.6, 10.7, 10.8, 10.9_
    - _Properties: 1, 2, 3_

  - [ ] 5.10 Formatters
    - Create `lib/core/utils/formatters.dart` (`AppFormatters(locale)`: `date`, `number`, `money` omitting decimals for whole amounts, `compact` for numbers above six digits, `enDashIfNull`).
    - Test (table, `en` and `id`): money with and without decimals, compact `1,2 jt` and `1.2M`, null gives an en dash, date in both locales.
    - Acceptance: tests pass.
    - Commit: `feat(core): add locale-aware formatters`
    - _Requirements: 11.1, 11.2, 11.3, 11.4_

  - [ ] 5.11 Debouncer and extensions
    - Create `lib/core/utils/debouncer.dart` and `lib/core/utils/extensions.dart` (small non-visual helpers the foundation uses, nothing speculative).
    - Test (`testWidgets` with `tester.pump(duration)`): rapid calls collapse to one; `dispose` cancels.
    - Acceptance: tests pass.
    - Commit: `feat(core): add Debouncer and extensions`
    - _Requirements: 11.5_

  - [ ] 5.12 Localization
    - Add `l10n.yaml`, `lib/core/l10n/app_en.arb` (template) and `app_id.arb` with only the strings the foundation shows (requirement 12.3). Sentence case, no em dashes, loading labels end with "…". Add `context.l10n` extension. Commit the `gen-l10n` output.
    - Test (`test/core/l10n/arb_test.dart`): `en` and `id` have the same keys; no value contains an em dash; every key ending in `Loading` or starting with `loading` ends with "…"; `context.l10n.<key>` resolves in both locales.
    - Acceptance: `flutter gen-l10n` succeeds and tests pass.
    - Commit: `feat(l10n): add English and Indonesian foundation strings`
    - _Requirements: 12.1, 12.2, 12.3, 12.5, 12.6_

- [ ] 6. App wiring

  - [ ] 6.1 Env and `env/example.json`
    - Create `lib/app/env.dart` with `Env.fromDartDefines()` reading `FLAVOR` (default `dev`), `API_BASE_URL` (default empty), `HEALTH_URL` (default `https://example.com`), and `isProd`. Create `env/example.json` listing all three with safe placeholders.
    - Test: defaults when no define is passed (does not throw); `env/example.json` keys equal the keys `Env` reads.
    - Acceptance: tests pass. Run `flutter test --dart-define=HEALTH_URL=https://a.test` once in the task notes to prove the override.
    - Commit: `feat(app): add Env with dart-define configuration`
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 21.10_

  - [ ] 6.2 Dependency injection
    - Create `lib/app/di/injection.dart` (`@InjectableInit`, `configureDependencies()`, `resetDependencies()`) and `register_module.dart` (`SharedPreferences` with `@preResolve`, `Dio`, `Env`). Annotate `Logger`, `ApiClient`, `KeyValueStore` impl, `AppSettingsCubit`, `LinkLauncher`, and `ClipboardService`. Run build_runner and commit `injection.config.dart`.
    - Test (`test/app/di/injection_test.dart`): after `SharedPreferences.setMockInitialValues`, `configureDependencies()` resolves the seven registrations; after `resetDependencies()` a second call succeeds.
    - Acceptance: tests pass and `build_runner build -d` is clean.
    - Commit: `feat(app): add dependency injection root`
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

  - [ ] 6.3 Bloc observer and bootstrap
    - Create `lib/app/app_bloc_observer.dart` and `lib/app/bootstrap.dart`: bindings, `Env`, `Logger`, `FlutterError.onError`, `PlatformDispatcher.instance.onError` (returns `true`), `Bloc.observer`, then `configureDependencies()`, then `runApp`. Keep the handlers as small testable functions.
    - Test: invoking the installed `FlutterError.onError` and `PlatformDispatcher` handlers calls the logger and does not throw; the observer's `onError` calls the logger; the platform handler returns `true`.
    - Acceptance: tests pass.
    - Commit: `feat(app): add bootstrap, error handlers, and bloc observer`
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

  - [ ] 6.4 Routes and thin shell
    - Create `lib/app/router/route_names.dart`, `routes.dart` (the only `GoRoute`, a `ShellRoute` with a root route that builds `PlaceholderPage`; use a temporary `SizedBox` here and replace in 6.6) and `app_shell.dart` (a thin `Scaffold` with `SafeArea`, no rail, tab bar, or panel, with the `TODO(core-widgets-and-templates)` seam).
    - Test (widget): the root route renders inside `AppShell`; `AppShell` source has no `NavigationRail`, `NavigationBar`, or `BottomNavigationBar` (string check).
    - Acceptance: tests pass.
    - Commit: `feat(app): add router and thin app shell`
    - _Requirements: 21.1, 21.2, 21.3, 21.4, 21.6_

  - [ ] 6.5 ConnectionCheckCubit
    - Create `lib/app/placeholder/connection_check_cubit.dart` and `connection_check_state.dart` (`idle`, `loading`, `success`, `failure(Failure)`). `check()` ignores calls while `loading`; otherwise emits `loading`, calls `guardRepository(() => apiClient.get(env.healthUrl))`, logs failures through `Logger`, and emits `success` or `failure`. Register it with `@injectable`.
    - Test (`bloc_test`, mock `ApiClient`): success; each `Failure` subtype; two `check()` calls in a row send one request.
    - Acceptance: tests pass.
    - Commit: `feat(app): add connection check cubit`
    - _Requirements: 21.8, 21.9, 3.5_

  - [ ] 6.6 Placeholder page
    - Create `lib/app/placeholder/placeholder_page.dart` with a title, the theme group (System, Light, Dark), the locale group (System, English, Indonesia), and the "Check connection" button. Each control is a `Pressable` over a `TactileSurface` (no Material buttons), calls `AppSettingsCubit`, and shows `selectedFill` when selected. Each group has the `SEAM(core-widgets-and-templates): replace with ThemeModeSwitch` comment. The check button is disabled and shows the loading label while the cubit is `loading`, and shows the success message or the localized `Failure` message after. Replace the temporary widget in `routes.dart`.
    - Test (widget, mock cubits, both locales, light and dark): tapping each theme button calls the cubit; the selected control differs from the others; while `loading` the button has `onPressed == null` and shows the loading label; success and failure messages show; the page source contains no `SegmentedButton`, `ElevatedButton`, `TextButton`, or `OutlinedButton`.
    - Acceptance: tests pass.
    - Commit: `feat(app): add placeholder page with theme, locale, and connection controls`
    - _Requirements: 21.3, 21.7, 21.8, 21.9_

  - [ ] 6.7 `App` and `main.dart`
    - Create `lib/app/app.dart` (`MaterialApp.router`, `themeMode` and `locale` from `AppSettingsCubit`, theme from `buildTheme` rebuilt in `builder:` when `WindowClass` or `InputMode` changes, resolving brightness from `settings.themeMode` and the platform brightness). Unsupported device locales fall back to `en`. `main.dart` calls only `bootstrap()`. Delete the template `test/widget_test.dart` (replaced by this task's test).
    - Test (widget, `test/app/app_test.dart`): defaults follow device brightness and change when the platform brightness changes; selecting Dark then rebuilding `App` over the same store starts in Dark and the same locale (restart survival); device locale `fr` resolves to `en`; resizing the surface across 768 and 1200 rebuilds the theme and keeps the chosen mode; `main.dart` has one statement.
    - Acceptance: tests pass.
    - Commit: `feat(app): wire App, theme, and locale from settings`
    - _Requirements: 6.1, 10.3, 10.4, 10.6, 12.4, 19.4, 21.5_
    - _Properties: 4_

- [ ] 7. Branding, splash, and web

  - [ ] 7.1 Placeholder branding assets
    - Add `assets/branding/icon.png` (1024 × 1024), `icon_foreground.png`, `splash.png`, and `og.png` (1200 × 630). They are plain neutral placeholders, generated by a script or tool of your choice with no new dependency in the repo. Register nothing else in `pubspec.yaml`.
    - Acceptance: a test (`test/platform/branding_assets_test.dart`) reads the PNG headers and asserts the four files exist with the expected sizes.
    - Commit: `chore(skeleton): add placeholder branding assets`
    - _Requirements: 4.1_

  - [ ] 7.2 Launcher icons
    - Configure `flutter_launcher_icons` (in `pubspec.yaml` or `flutter_launcher_icons.yaml`) for Android (adaptive), iOS, web, macOS, Windows. Run `dart run flutter_launcher_icons` and commit the generated platform files.
    - Acceptance: the generated icons exist under `android/app/src/main/res`, `ios/Runner/Assets.xcassets`, `web/icons`, and `macos`. `flutter analyze` is clean.
    - Commit: `chore(skeleton): generate launcher icons from branding assets`
    - _Requirements: 4.2_

  - [ ] 7.3 Native splash and web loading screen
    - Configure `flutter_native_splash` for Android, iOS, and web. Run `dart run flutter_native_splash:create` and commit the generated files.
    - Acceptance: `web/index.html` contains the splash markup and style; Android and iOS splash resources exist.
    - Commit: `chore(skeleton): generate native splash and web loading screen`
    - _Requirements: 4.2, 4.4_

  - [ ] 7.4 Web metadata
    - In `web/index.html` set the title, description meta, favicon link, and Open Graph tags (`og:title`, `og:description`, `og:image` pointing to `og.png`). Confirm `web/manifest.json` name and short name are "Skeleton" (1.2).
    - Test (`test/platform/web_index_test.dart`): the file has each tag, and `og:image` ends with `og.png`.
    - Acceptance: test passes.
    - Commit: `feat(web): add page metadata and Open Graph tags`
    - _Requirements: 4.3, 4.5_

- [ ] 8. Architecture rules and quality gates

  - [ ] 8.1 Architecture check test
    - Add `test/architecture/architecture_test.dart` that scans `lib/`: no `features/` import from `core/` (property 19); `GoRoute(` only in `lib/app/router/routes.dart` (property 20); `domain/` imports only the allowed packages (22.2); no `import 'package:dio` in `domain/`; one public class per file; file names are snake_case of the class; no `kIsWeb` or `Platform.` outside `core/layout/` and `app/bootstrap.dart`; no `Color(0x`, `Colors.`, `fontSize:`, `FontWeight.`, `Curves.`, or `Duration(` outside `core/theme/` and `tokens.g.dart`; no `Curves.easeIn`; no `FontWeight.w600` or heavier outside `core/theme/`; `lib/features/` does not exist; the Material button widgets named in 6.6 are absent from `lib/app/`; none of `AdaptiveScaffold`, `AdaptiveBuilder`, `PageColumn`, `AdaptiveGrid`, `ActionGroup` is declared in `lib/`.
    - Acceptance: the test passes on the current tree. A temporary violation in a scratch copy makes it fail (note the check in the commit body).
    - Commit: `test(architecture): enforce layer and token rules in lib`
    - _Requirements: 22.1, 22.2, 22.3, 22.4, 22.6, 17.9, 18.7, 20.5, 20.6_
    - _Properties: 19, 20_

  - [ ] 8.2 Quality gates in one script
    - Add `tool/check.dart` (or `tool/check.sh`) that runs, in order: `dart format --set-exit-if-changed .`, `dart run build_runner build -d`, `flutter analyze`, `flutter test`, and fails on the first failure. Run it and record the output summary.
    - Acceptance: the script exits 0. `flutter analyze` reports zero issues and `flutter test` passes. No golden or stress test exists (`find test -name '*golden*'` is empty). A checklist in the commit body maps each test file to requirement 23.4 (AppSettingsCubit 5.9, guardRepository and mapper 5.7, formatters 5.10, window class and input mode 3.1, blur 2.3, generator gate failure 2.9) and 23.5 (properties 1 to 10, 17, 18 as `kiri_check` tests in 2.3, 3.1, 5.7, 5.8, 5.9).
    - Commit: `chore(skeleton): add quality gate script`
    - _Requirements: 23.1, 23.2, 23.3, 23.4, 23.5, 23.6_

- [ ] 9. Documentation

  - [ ] 9.1 Skeleton README
    - Write `skeleton/README.md`: pinned Flutter 3.44.8 and Dart 3.12.2 with the reason for the difference from the brief's "3.50"; a table of exact package versions (from 1.4); `minSdk` and iOS deployment target of the template; how to run (`fvm`, `build_runner`, `gen-l10n`, `dart run tool/generate_tokens.dart`, `--dart-define-from-file=env/example.json`); the generated-file policy (what is committed, what is ignored); `json_serializable` deferred; only Inter registered; deviations from `03` §4 (Logger in `core/log/`, the placeholder folder `app/placeholder/`, `blur_conversion.dart`, `tool/src/`); the placeholder page and its seams.
    - Acceptance: a test (`test/docs/readme_test.dart`) asserts the README mentions `3.44.8`, `3.12.2`, and every package name in `pubspec.yaml` `dependencies` and `dev_dependencies`, with the version string from `pubspec.yaml`.
    - Commit: `docs(skeleton): add README with pinned versions and policies`
    - _Requirements: 1.5, 2.5, 7.5, 22.5_

- [ ] 10. Manual verification (no code changes)

  Run these after sections 1 to 9 are merged to the working branch. Record each result (date, device, pass or fail, notes) in the checklist in 10.12. A failed check opens a fix task and reruns the check.

  - [ ] 10.1 **[USER ACTION]** Accept the Android SDK licences
    - The user runs `flutter doctor --android-licenses` and accepts them. This changes the user's SDK outside the repository, so an agent must not do it. Confirm with `flutter doctor -v` that Android toolchain has no licence warning.
    - Acceptance: `flutter doctor -v` shows "All Android licenses accepted". Tasks 10.4 and 10.9 are blocked until this is done.
    - Commit: none.
    - _Requirements: 24.9, 3.5_

  - [ ] 10.2 Web: `flutter run -d chrome`
    - Check: starts without an uncaught error in the console, shows the placeholder page inside the shell, loading screen shows before the first frame (4.4), the page title and favicon are set, System, Light, and Dark switch immediately, no theme chosen follows the browser or OS brightness, "Check connection" shows a result. Browsers enforce CORS and `https://example.com` sends no CORS headers, so on web the expected result is the localized network `Failure` message (this still proves the Failure path). For a success on web, run with `--dart-define=HEALTH_URL=<a CORS-enabled URL>`.
    - Acceptance: all items pass on Chrome.
    - Commit: none.
    - _Requirements: 24.1, 24.5, 24.6, 4.4_

  - [ ] 10.3 iOS simulator
    - Check: `flutter run -d <simulator>` starts without an uncaught error and shows the placeholder page inside the shell; theme and locale switch immediately; default follows the simulator appearance; "Check connection" succeeds.
    - Acceptance: all items pass on one iPhone simulator.
    - Commit: none.
    - _Requirements: 24.2, 24.5, 24.6_

  - [ ] 10.4 Android emulator or device (debug)
    - Check: starts without an uncaught error and shows the placeholder page inside the shell; theme and locale switch immediately; default follows the device; "Check connection" succeeds in debug.
    - Acceptance: all items pass.
    - Commit: none.
    - _Requirements: 24.3, 24.5, 24.6_

  - [ ] 10.5 macOS
    - Check: `flutter run -d macos` starts without an uncaught error and shows the placeholder page inside the shell; theme and locale switch immediately; default follows the system appearance; "Check connection" succeeds in a **release** run (`flutter run -d macos --release`), which proves the network entitlement.
    - Acceptance: all items pass.
    - Commit: none.
    - _Requirements: 24.4, 24.5, 24.6, 3.3_

  - [ ] 10.6 Window class crossing on web and macOS
    - Resize the window across 768 and 1200 px. The theme rebuilds for the new class (type sizes change, tablet to desktop uses desktop sizes) and the chosen theme mode stays. No rail or tab bar appears.
    - Acceptance: observed on web and on macOS.
    - Commit: none.
    - _Requirements: 24.8, 21.6, 19.4_

  - [ ] 10.7 Theme and locale survive a restart on every platform
    - On web, iOS simulator, Android, and macOS: choose Dark and Indonesia, fully stop the app, start it again. It starts in Dark and Indonesia. Then choose System and System and restart, and confirm it follows the device again.
    - Acceptance: passes on all four platforms.
    - Commit: none.
    - _Requirements: 24.7, 10.6_

  - [ ] 10.8 Blur versus the browser (spike S16)
    - Render one shadow recipe (for example `card` in light and dark) in the app and in a browser from the same CSS values, take screenshots at the same scale, and compare the edge softness by eye and with a pixel difference. Record the result and the screenshot paths. If they differ visibly, record the difference and propose a change to the 0.57735 factor instead of changing it in this task.
    - Acceptance: the result is in `skeleton/README.md` under "Blur check (S16)", with screenshots in `spikes/` or `docs/` referenced from it.
    - Commit: `docs(theme): record blur comparison against the browser`
    - _Requirements: 14.8_

  - [ ] 10.9 Release APK reaches the network
    - Needs 10.1. Run `flutter build apk --release --dart-define-from-file=env/example.json`, install it on an emulator or device, open the app, and press "Check connection".
    - Acceptance: the success message shows. If it shows a connectivity failure, check the `INTERNET` permission in the merged release manifest with `aapt dump permissions`.
    - Commit: none.
    - _Requirements: 24.9, 3.5, 3.1_

  - [ ] 10.10 Windows and Linux folders
    - Confirm `windows/` and `linux/` exist and carry the display name "Skeleton". Running them is not part of the acceptance.
    - Acceptance: both folders exist; the names match 1.2.
    - Commit: none.
    - _Requirements: 24.10, 1.3_

  - [ ] 10.11 Final gate on a clean clone
    - Clone the repository to a temp folder, run `fvm install`, `flutter pub get`, `dart run build_runner build -d`, `dart run tool/check.dart`.
    - Acceptance: exits 0 with no manual step beyond the commands listed in the README.
    - Commit: none.
    - _Requirements: 23.1, 23.2, 23.3, 7.5_

  - [ ] 10.12 Record verification results
    - Add a "Phase 1 verification" table to `skeleton/README.md` with the results of 10.2 to 10.11 (date, platform or device, result).
    - Acceptance: every row in 10.2 to 10.11 has a result. Rows that failed link to their fix commit.
    - Commit: `docs(skeleton): record Phase 1 verification results`
    - _Requirements: 24.1, 24.2, 24.3, 24.4, 24.5, 24.6, 24.7, 24.8, 24.9, 24.10_

## Notes

- Section order follows the design's build order: 1 (steps 1), 2 (steps 2 and 3), 3 and 4 (steps 4 and 5), 5 (step 6), 6 (steps 7 and 8), 7 (step 9), 8 and 9 (step 10 and gates), 10 (acceptance).
- Tasks 2.x do not depend on Flutter widgets, so the generator can be developed with `dart test`-style runs through `flutter test test/tool`.
- Tasks 5.x do not depend on the theme and can run in parallel with sections 3 and 4 if two agents work on separate branches. The default plan is sequential.
- The only task that needs the user is 10.1. Section 10 also needs devices (iOS simulator, Android emulator, macOS).
