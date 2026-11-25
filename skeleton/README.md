# Skeleton

Flutter foundation for the apps generated from this repository: Clean
Architecture layout, Radix-based design tokens, a tactile theme, settings
(theme mode and locale), a Dio client with a failure mapper, dependency
injection, English and Indonesian strings, and a placeholder page that proves
the wiring. It has no features. Feature work starts from here.

Spec: `.kiro/specs/skeleton-foundation/` (requirements, design, tasks).

## Pinned toolchain

| Tool | Version |
| --- | --- |
| Flutter | `3.44.8` (stable), pinned in `.fvmrc` |
| Dart | `3.12.2`, constrained as `sdk: ^3.12.0` in `pubspec.yaml` |
| Android `minSdk` | 24 (the `flutter.minSdkVersion` default of Flutter 3.44.8) |
| iOS deployment target | 13.0 (the template default) |

**Why not Flutter 3.50.** The brief (`docs/brief/`) says "3.50 at the time of
writing". The machine that built this skeleton runs 3.44.8, and that is the
version the whole skeleton was built and tested on. The pin was approved
(spec decision Q16), and the brief was left unchanged. When you move to a newer
Flutter, change `.fvmrc`, rerun the quality gates, and update this section.

## Package versions

All versions are exact and come from `pubspec.yaml`. `pubspec.lock` is committed.

### dependencies

| Package | Version |
| --- | --- |
| `bloc_concurrency` | `0.3.0` |
| `dio` | `5.11.1` |
| `flutter` | SDK |
| `flutter_bloc` | `9.1.1` |
| `flutter_localizations` | SDK |
| `fpdart` | `1.2.0` |
| `freezed_annotation` | `3.1.0` |
| `get_it` | `9.3.0` |
| `go_router` | `18.1.4` |
| `injectable` | `3.0.0` |
| `intl` | `0.20.2` |
| `lucide_icons_flutter` | `4.0.3` |
| `shared_preferences` | `2.5.6` |
| `url_launcher` | `6.3.3` |

`bloc_concurrency` and `lucide_icons_flutter` are required by Req 2.1 but not
used yet: no file in `lib/`, `test/` or `tool/` imports them.

### dev_dependencies

| Package | Version |
| --- | --- |
| `bloc_test` | `10.0.0` |
| `build_runner` | `2.15.1` |
| `flutter_launcher_icons` | `0.14.4` |
| `flutter_native_splash` | `2.4.8` |
| `flutter_test` | SDK |
| `freezed` | `3.2.5` |
| `injectable_generator` | `3.0.2` |
| `kiri_check` | `1.4.0` |
| `mocktail` | `1.0.5` |
| `very_good_analysis` | `10.3.0` |
| `yaml` | `3.1.4` |

`cupertino_icons` and `flutter_lints` were removed from the template pubspec:
neither is a required package, and `very_good_analysis` replaces the lints.

`json_serializable` and `json_annotation` are deferred. The foundation has no
DTO, so they arrive with the first feature that needs one.

Only `Inter-Medium.ttf` is registered as a font (weight 500). The other font
files stay in `assets/fonts/` but are not listed in `pubspec.yaml`.

## Run it

All commands run in `skeleton/`. With FVM, prefix `flutter` and `dart` with
`fvm`.

```sh
fvm use 3.44.8                       # once; .fvmrc already pins it
flutter pub get
dart run build_runner build -d       # injection.config.dart, *.freezed.dart
flutter gen-l10n                     # lib/core/l10n/app_localizations*.dart
dart run tool/generate_tokens.dart   # lib/core/theme/tokens.g.dart
flutter run -d chrome --dart-define-from-file=env/example.json
```

`env/example.json` lists the three `--dart-define` keys that `Env` reads:
`FLAVOR` (default `dev`), `API_BASE_URL` (default empty), `HEALTH_URL`
(default `https://example.com`, the target of the placeholder's connection
check). Other `env/*.json` files are git-ignored, so keep real values there.

### Quality gates

```sh
dart run tool/check.dart
```

Runs `dart format --set-exit-if-changed .`, `dart run build_runner build -d`,
`flutter analyze`, and `flutter test`, and stops at the first failure.
`flutter analyze` must report zero issues. The tests under `test/tool/` start
`dart` as a subprocess, so `dart` must be on `PATH` (CI included).

There is no golden test and no stress harness.

### Architecture test

`test/architecture/architecture_test.dart` scans `lib/` (generated files
excluded) and enforces the layer and token rules: no `features/` import from
`core/`, `GoRoute(` only in `app/router/routes.dart`, `domain/` import limits,
one public type per file, no `kIsWeb` or `Platform.` outside `core/layout/` and
`app/bootstrap.dart`, no raw colour, size, weight, curve or duration outside
`core/theme/`, and no `lib/features/`. Exceptions are per-file allowlists in the
test, each with a reason. Prefer an allowlist entry over renaming a file.

## Generated files policy

| File | Policy |
| --- | --- |
| `lib/core/theme/tokens.g.dart` | Committed. Output of `tool/generate_tokens.dart` from `design/tokens.yaml`. |
| `lib/app/di/injection.config.dart` | Committed. Output of `build_runner`; never edited by hand. |
| `lib/core/l10n/app_localizations*.dart` | Committed. Output of `flutter gen-l10n` from the ARB files. |
| `*.freezed.dart` | Not committed (git-ignored). Run `build_runner` after a clean checkout. |

`*.g.dart`, `*.freezed.dart`, `injection.config.dart` and
`app_localizations*.dart` are excluded from `flutter analyze` and from the
architecture test. `.kiro/` is never git-ignored.

## Layout and deviations from the brief

The `lib/` layout follows `03` §4 except for:

- **Logger lives in `lib/core/log/`**, and `Logger()` takes no `Env`
  (the design had `Logger({Env? env})`, but the field was unused).
- **`lib/app/placeholder/`** holds the placeholder page and its
  `ConnectionCheckCubit`. It is not a feature folder; `lib/features/` does not
  exist.
- **`lib/core/theme/tactile/blur_conversion.dart`** holds `cssBlurToFlutter`.
- **`tool/src/`** holds the token generator's helpers; the entry point is
  `tool/generate_tokens.dart`.
- **`KeyValueStore`** has `getString`, `setString` and `remove` only; the
  design's `getBool` and `setBool` were not built (no requirement uses them).
- **`mapStatus`** in `dio_error_mapper.dart` is public (`@visibleForTesting`)
  so tests can call it.
- **`LinkLauncher` and `ClipboardService`** are concrete classes, not
  interfaces. Make them `abstract interface class` plus an implementation when
  a feature needs a fake.
- **Status mapping (Req 8.5).** 401/403, 404 and 422 have their own `Failure`
  subtypes; every other status is `ServerFailure(statusCode)`. There is no
  separate subtype for 4xx versus 5xx.
- **`DioExceptionType.transformTimeout`** maps to `unexpected`, not `network`.
  Only the four connectivity types map to `network`.
- **Dio timeouts.** `connectTimeout` and `receiveTimeout` are 15 s
  (`app/di/register_module.dart`), so a silent server ends the connection check
  with a network failure instead of a stuck button.
- **Logging redaction** masks the whole value of `Authorization`, `Cookie` and
  `Set-Cookie` headers, bearer tokens, and fields named like `password`,
  `token`, `secret` or `api_key`. `debugPrint` is not stripped from release
  builds, so every message goes through `redact`.

### Design tokens (`design/tokens.yaml`)

- **Hue-11 tuning.** `tune_faint_text` adjusts the OKLCH lightness of ink-9 and
  ink-10 and also of the hue-11 text colours. With
  `tune_faint_text: false`, the Radix defaults fail the hue-11 contrast gate and
  the generator exits non-zero, so a custom palette must bring hues that pass
  by themselves. Req 13.7 states this.
- **Gate failures.** A contrast gate that fails prints the pair and its ratio,
  exits non-zero and leaves `tokens.g.dart` unchanged.

### Theme and typography

- **Typography values are hand-typed (F7).** `AppTypography.build` uses Inter,
  weight 500, its tracking and no heading face as defaults.
  `tokens.g.dart` has no typography group yet, so the `typography.*` knobs in the
  tokens file have no effect. Pass them from `buildTheme` once the generator
  emits them.
- **Not implemented (F8).** Display 24/32 when a heading wraps past two lines
  on mobile; meta 14/20 under a larger lead; meta ink-11 when the ink-10 gate
  fails (the gate passes after tuning, so it is inactive).
- **Divider colour (F9).** `DividerTheme` uses ink-6 on every surface. On dark
  raised, overlay and sheet surfaces the line should be ink-7. Core widgets use
  `context.surface.line`; a Material `Divider` is only correct on `panel`.
- **Material state layers (F10).** `buildTheme` sets `NoSplash`, a transparent
  highlight, and transparent hover and focus colours, and turns off the
  Material overlay colour on buttons, so no state layer is drawn. Material
  widgets still carry their own default colours.
- **`SurfaceScope.brightness`.** `SurfaceScope` has an extra `brightness` field
  and a `withKind` method that the design does not list.
- **`SurfaceScope.of`** without an ancestor returns the `panel` scope of the
  current brightness and does not throw. `well` uses the `panel` remap (the
  brief does not describe it).

### Placeholder page and seams

`lib/app/placeholder/placeholder_page.dart` shows a title, the theme group
(System, Light, Dark), the locale group (System, English, Indonesia), and a
"Check connection" button. Every control is a `Pressable` over a
`TactileSurface`; no Material button is used. The theme and locale groups carry
`SEAM(core-widgets-and-templates): replace with ThemeModeSwitch`, and
`lib/app/router/app_shell.dart` carries the `TODO(core-widgets-and-templates)`
seam: replace the thin `Scaffold` with the real shell there. The button is
disabled and shows the loading label while a check runs.

`App` creates one `AppSettingsCubit`, loads it before `MaterialApp.router`
builds, and shares it with `BlocProvider.value`. `main.dart` is one statement:
`bootstrap(() => const App())`.

### Web and branding

- `assets/branding/` holds placeholder icons, splash and `og.png` (plain
  neutral squares made with a stdlib-only script). Replace them per app.
- `web/og.png` is a copy of `assets/branding/og.png` so that `og:image`
  resolves locally. `og:image` is a relative path; **set an absolute URL at
  deploy time**, since link scanners ignore relative image URLs.
- `flutter_launcher_icons` and `flutter_native_splash` are configured in
  `pubspec.yaml`. After running them, check that they did not alter
  `ios/Runner.xcodeproj/project.pbxproj` (`ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS`)
  or `ios/Runner/Info.plist` (re-indented, extra `UIStatusBarHidden`), and
  revert those two files. The generated `web/manifest.json` colours are
  `#3B4A5C`.

## Not covered here

Manual verification on devices (task 10) is separate: Android licences
(`flutter doctor --android-licenses`, user action), Chrome, iOS simulator and
the release APK. Blur output is not yet compared against a browser (Req 14.8).
