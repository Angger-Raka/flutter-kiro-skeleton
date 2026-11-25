# Requirements Document

## Introduction

This spec builds the foundation of the `skeleton/` Flutter project for the flutter-kiro-skeleton repository: the
Clean Architecture + BLoC, feature-first base that every generated app starts from. It covers the `flutter create`
scaffold for all platforms with pinned packages, the platform setup that lets release builds reach the network,
`lib/app/` (bootstrap, env, DI, router, shell), `lib/core/` infrastructure (error, usecase, network, storage,
services, settings, utils, l10n), `design/tokens.yaml` with a first token generator, the tactile foundation
(surfaces, shadows, pressable, typography, motion, theme mapping), `core/layout` window-class plumbing, and
branding placeholders with the native splash and web loading screen.

Sources: `docs/brief/03-architecture.md` §1–§5, `docs/brief/04-design-system.md` §1–§10,
`docs/brief/02-repository-structure.md`, `docs/brief/11-roadmap.md` (Phase 1, `skeleton-foundation`).

Decisions already approved by the user and applied here:
- Organisation `dev.angga`, display name "Skeleton".
- Flutter 3.44.8 / Dart 3.12.2 pinned in `.fvmrc`. The brief says "3.50 at the time of writing"; the brief is not
  changed, and `skeleton/README.md` records the actual pin.
- Fonts Inter, Space Grotesk, and Plus Jakarta Sans (static Medium, OFL) already exist in `skeleton/assets/fonts/`.

Out of scope for this spec: core widgets other than the tactile primitives (`TactileSurface`, `Pressable`), the
stress-test harness and goldens, Mason bricks, `tool/create_app.dart`, `tool/sync_core.dart`, the `kit` CLI, hooks,
skills, steering, agents, and the `home` example feature. Where a later spec owns a piece, this spec leaves a
minimal seam and does not build the piece.

Further decisions (from the review in `spikes/crew-run/S1-requirements-review.md`, all answered):
- The App_Shell is thin. "Adaptive" means theme and size follow the Window_Class. There is no rail or tab bar in this spec (Q1).
- A placeholder page hosts temporary theme and locale controls built from `Pressable` and `TactileSurface`, and a "Check connection" button that calls `ApiClient` (Q2, Q4).
- Tests are unit and bloc tests plus property-based tests with `kiri_check` 1.4.0 for the logic-only properties (Q13).
- Android SDK licences must be accepted by the user before the Release_APK task (Q18). This is a user action.

No requirement depends on an undecided item.

## Glossary

- **Skeleton**: the Flutter project in `skeleton/`, the product template from which apps are generated.
- **Foundation**: everything this spec delivers, as listed in the Introduction.
- **Token_Generator**: the first Dart script that reads `design/tokens.yaml` and writes
  `lib/core/theme/tokens.g.dart`. It is replaced by `kit tokens` in Phase 2.
- **Tokens_File**: `design/tokens.yaml`, the brand knobs (`04` §4.1).
- **Tokens_Output**: `lib/core/theme/tokens.g.dart`, the generated file.
- **Radix_Scales**: the checked-in colour data for sand, slate, blue, green, red, and amber.
- **AppSettings**: the user settings model holding theme mode (`system | light | dark`) and locale (`system | en | id`).
- **AppSettingsCubit**: the cubit that exposes and updates AppSettings and saves it through KeyValueStore.
- **KeyValueStore**: the core interface for key-value persistence, backed by `shared_preferences`.
- **Failure**: the sealed error type returned in `Either<Failure, T>` from repositories.
- **guardRepository**: the helper that runs a repository call and maps exceptions to Failure.
- **Window_Class**: `mobile` (< 768), `tablet` (768–1199), or `desktop` (≥ 1200), derived from width.
- **Input_Mode**: `touch` when the platform is iOS or Android (also on web), otherwise `pointer`.
- **Surface_Kind**: one of `ground, rail, panel, raised, overlay, sheet, well`.
- **TactileSurface**: the widget that paints a surface and provides a SurfaceScope.
- **SurfaceScope**: the inherited widget that exposes working ink steps, line colour, hover and selected fills, and
  shadow lists for the current surface.
- **Pressable**: the press primitive (scale, hover fill, focus ring, semantics, hit area).
- **App_Shell**: the minimal shell widget in `app/router/app_shell.dart` that hosts routed content.
- **Release_APK**: an Android APK built with `flutter build apk --release`.
- **Target_Platforms**: web, iOS simulator, Android, and macOS.
- **Contrast_Gate**: a minimum WCAG contrast ratio for a colour pair (`04` §4.6).
- **Env**: the class that reads build-time configuration from `--dart-define` values.
- **Placeholder_Page**: the temporary root page in the App_Shell with the theme and locale controls and the "Check connection" button.
- **Health_URL**: the URL that "Check connection" requests, read from the `HEALTH_URL` define of Env.

## Requirements

### Requirement 1: Project scaffold and toolchain pin

**User Story:** As a developer starting an app from the skeleton, I want a project scaffolded for every platform on a
pinned toolchain, so that every machine builds the same thing.

#### Acceptance Criteria

1. THE Skeleton SHALL be created in `skeleton/` with `flutter create` for Android, iOS, web, macOS, Windows, and Linux, with project name `skeleton`.
2. THE Skeleton SHALL use organisation `dev.angga`, so the Android `applicationId` and `namespace` and the iOS and macOS `PRODUCT_BUNDLE_IDENTIFIER` start with `dev.angga.skeleton`.
3. THE Skeleton SHALL show the display name "Skeleton" on Android, iOS, macOS, web, Windows, and Linux.
4. THE Skeleton SHALL contain `skeleton/.fvmrc` that pins Flutter 3.44.8 (not at the repository root), and THE `pubspec.yaml` SHALL constrain the Dart SDK to a range that includes Dart 3.12.2.
5. THE Skeleton SHALL contain a `README.md` that records the pinned Flutter and Dart versions, the reason for the difference from the brief's "3.50", the exact package versions chosen, the Android `minSdk` and iOS deployment target (the defaults of the pinned Flutter template), and every deviation from `03` §4.
6. WHEN `flutter create` generates files that the brief treats as owned by this repo (for example `.gitignore` rules), THE Skeleton SHALL NOT ignore `.kiro/`, `lib/core/theme/tokens.g.dart`, or `docs/` generated files listed in `02` ("`.gitignore` rules").
7. THE Skeleton SHALL keep the existing `assets/fonts/` files and `THIRD_PARTY_NOTICES.md` unchanged.

### Requirement 2: Pinned dependencies and lints

**User Story:** As a developer, I want the foundation packages pinned and the lints strict, so that builds are
reproducible and the code stays consistent.

#### Acceptance Criteria

1. THE `pubspec.yaml` SHALL declare the foundation packages of `03` §2 at exact or tightly constrained versions: `flutter_bloc`, `bloc_concurrency`, `freezed_annotation`, `get_it`, `injectable`, `fpdart`, `dio`, `go_router`, `shared_preferences`, `intl`, `flutter_localizations`, `url_launcher`, `lucide_icons_flutter`.
2. THE `pubspec.yaml` SHALL declare the dev packages `freezed`, `injectable_generator`, `build_runner`, `very_good_analysis`, `flutter_launcher_icons`, `flutter_native_splash`, `yaml`, `bloc_test`, `mocktail`, and `kiri_check` 1.4.0.
3. THE `pubspec.yaml` SHALL NOT declare app-only packages (`drift`, `drift_flutter`, `sqlite3_flutter_libs`), the `kit` dependencies, or `cached_network_image`.
4. THE `analysis_options.yaml` SHALL include `very_good_analysis`.
5. THE `pubspec.yaml` SHALL NOT declare `json_serializable` or `json_annotation`, because the Foundation has no DTO, and THE `README.md` SHALL state that they arrive with the first feature that needs them.
6. THE Skeleton SHALL commit `pubspec.lock` for the skeleton itself.

### Requirement 3: Platform network setup

**User Story:** As a developer, I want release builds to reach the network on every platform, so that a
release APK or macOS app does not fail on its first request.

#### Acceptance Criteria

1. THE `android/app/src/main/AndroidManifest.xml` SHALL contain `<uses-permission android:name="android.permission.INTERNET"/>` in the main manifest.
2. THE `AndroidManifest.xml` SHALL contain the url_launcher `<queries>` entry for `https` links, because `LinkLauncher` uses `canLaunchUrl`.
3. THE `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements` SHALL each set `com.apple.security.network.client` to `true`.
4. THE iOS project SHALL NOT add network configuration beyond the Flutter template.
5. WHEN a Release_APK is installed on an Android device or emulator, THE Skeleton SHALL complete an HTTPS request through the core `ApiClient`, WHEN the user presses "Check connection" on the Placeholder_Page.

### Requirement 4: Branding, native splash, and web shell

**User Story:** As a developer, I want placeholder branding and a loading screen from day one, so that every
generated app has a complete first-run experience that it can replace later.

#### Acceptance Criteria

1. THE Skeleton SHALL ship placeholder `assets/branding/icon.png` (1024 px), `icon_foreground.png`, `splash.png`, and `og.png`.
2. THE `pubspec.yaml` (or dedicated config files) SHALL configure `flutter_launcher_icons` and `flutter_native_splash` to generate icons, the native splash, and the web loading screen from `assets/branding/`.
3. THE `web/index.html` SHALL set the page title, a description meta tag, a favicon, and Open Graph tags that point to `og.png`.
4. WHEN the web app is opened, THE Skeleton SHALL show the loading screen produced by `flutter_native_splash` until Flutter renders its first frame.
5. THE `web/manifest.json` SHALL use the display name "Skeleton" for `name` and `short_name`.

### Requirement 5: Environment configuration

**User Story:** As a developer, I want build-time configuration read from a defines file, so that no secret or
URL is hardcoded.

#### Acceptance Criteria

1. THE Env class SHALL read its values from `--dart-define` constants through `Env.fromDartDefines()`.
2. THE Skeleton SHALL commit `env/example.json` listing every supported define with a safe placeholder value.
3. WHEN a define is not supplied, THE Env class SHALL use a documented default and SHALL NOT throw.
4. THE Skeleton SHALL NOT contain secrets in code, steering, or committed env files other than `env/example.json`.

### Requirement 6: Bootstrap, logging, and global error handling

**User Story:** As a developer, I want startup and uncaught errors handled in one place, so that failures are
logged and the app keeps running.

#### Acceptance Criteria

1. THE `main.dart` SHALL call only `bootstrap()`.
2. WHEN the app starts, THE bootstrap SHALL initialise Flutter bindings, call `configureDependencies()`, set `Bloc.observer`, and install error handlers before running the app.
3. WHEN `FlutterError.onError` fires, THE bootstrap SHALL pass the error to the core Logger and SHALL keep the app running.
4. WHEN `PlatformDispatcher.instance.onError` fires, THE bootstrap SHALL pass the error to the core Logger and return `true`.
5. WHEN a Bloc or Cubit throws, THE Bloc observer SHALL pass the error to the core Logger.
6. THE core Logger SHALL NOT write tokens, passwords, or `Authorization` header values to its output.

### Requirement 7: Dependency injection

**User Story:** As a developer, I want one DI root with generated registration, so that dependencies are wired the
same way in every feature.

#### Acceptance Criteria

1. THE `app/di/injection.dart` SHALL declare `@InjectableInit` and THE `injection.config.dart` SHALL be generated by `build_runner` and never edited by hand.
2. THE DI module SHALL register the clients, data sources, and repositories of the Foundation with `@lazySingleton`, and use cases and blocs with `@injectable`.
3. THE DI module SHALL register the `Dio` instance, the `KeyValueStore`, the `AppSettingsCubit`, the `LinkLauncher`, and the `ClipboardService`.
4. WHEN `configureDependencies()` is called twice in a test, THE DI root SHALL provide a way to reset so that tests can re-register.
5. THE Skeleton SHALL commit `injection.config.dart`, `tokens.g.dart`, and the `gen-l10n` output, SHALL NOT commit `*.freezed.dart` files, and SHALL state this policy in `README.md`.

### Requirement 8: Core error, usecase, and network

**User Story:** As a developer, I want a single error model and a single HTTP client, so that every repository
returns the same shape of failure.

#### Acceptance Criteria

1. THE core SHALL define a sealed `Failure` type in `core/error/failure.dart` and the exception classes in `core/error/exceptions.dart`.
2. THE core SHALL define the base `UseCase` contract in `core/usecase/usecase.dart` that returns `Either<Failure, T>` using `fpdart`.
3. THE `core/network/api_client.dart` SHALL provide the single `Dio` client, with interceptors in `core/network/interceptors/`, including an authentication interceptor that does nothing by default (an extension point).
4. WHEN a repository wraps a call with `guardRepository`, THE guardRepository SHALL return `Right(value)` if the call completes and `Left(Failure)` if the call throws any exception or error.
5. WHEN `dio_error_mapper` receives a `DioException` with an HTTP status code, THE mapper SHALL map 401 and 403, 404, and 422 each to a specific Failure subtype, and SHALL map every other status to `server(statusCode)`.
6. WHEN `dio_error_mapper` receives a `DioException` caused by a timeout or no connection, THE mapper SHALL return a connectivity Failure.
7. THE domain layer SHALL NOT import `dio`.

### Requirement 9: Storage and services

**User Story:** As a developer, I want key-value storage and platform services behind interfaces, so that tests
and platforms can swap them.

#### Acceptance Criteria

1. THE `core/storage/key_value_store.dart` SHALL define the `KeyValueStore` interface and a `shared_preferences` implementation, and SHALL NOT expose `shared_preferences` types to callers.
2. WHEN a `KeyValueStore` write fails, THE implementation SHALL throw a `CacheException`.
3. THE `core/services/link_launcher.dart` SHALL wrap `url_launcher` behind a `LinkLauncher` interface.
4. THE `core/services/clipboard_service.dart` SHALL wrap the clipboard behind a `ClipboardService` interface.

### Requirement 10: AppSettings and persistence

**User Story:** As a user, I want my theme and language choice to be remembered, so that the app looks the way I
left it after a restart.

#### Acceptance Criteria

1. THE AppSettings SHALL contain a theme mode of `system`, `light`, or `dark`, and a locale of `system`, `en`, or `id`.
2. WHEN no value has been saved, THE AppSettings SHALL have theme mode `system` and locale `system`.
3. WHEN the theme mode is `system`, THE app SHALL follow the device brightness, and WHEN the device brightness changes, THE app SHALL update without restart.
4. WHEN the locale is `system`, THE app SHALL use the device locale if it is `en` or `id`, and SHALL use `en` for any other device locale.
5. WHEN the user changes the theme mode or locale through AppSettingsCubit, THE AppSettingsCubit SHALL emit the new settings and SHALL save them through KeyValueStore.
6. WHEN the app restarts, THE AppSettingsCubit SHALL load the saved theme mode and locale, and THE app SHALL start with them.
7. IF a stored value is not a known enum name, THEN THE AppSettingsCubit SHALL use `system` for that field and SHALL NOT crash.
8. IF saving a value fails, THEN THE AppSettingsCubit SHALL keep the new value in memory for the session and SHALL NOT crash.
9. WHEN the settings are saved and loaded again, THE loaded AppSettings SHALL equal the saved AppSettings for every combination of theme mode and locale.

### Requirement 11: Formatting utilities

**User Story:** As a developer, I want one set of formatters for dates, numbers, money, and compact numbers, so
that every screen shows values the same way in both locales.

#### Acceptance Criteria

1. THE `core/utils/` SHALL provide formatters for date, number, money, and compact number, built on `intl` and aware of the active locale.
2. WHEN a money amount has no fractional part, THE money formatter SHALL omit the decimals.
3. WHEN a number has more than six digits, THE compact formatter SHALL use compact notation (for example `1,2 jt` for `id` and `1.2M` for `en`).
4. WHEN a value is null, THE formatters SHALL return an en dash.
5. THE `core/utils/` SHALL provide a debouncer and the extension helpers required by the Foundation.

### Requirement 12: Localization

**User Story:** As a user, I want the app in English or Indonesian, so that I can read it in my language.

#### Acceptance Criteria

1. THE Skeleton SHALL generate localizations with `gen-l10n` from ARB files for `en` and `id` in `core/l10n/`, with `en` as the template.
2. THE Skeleton SHALL expose localized strings through `context.l10n.<key>`.
3. THE ARB files SHALL contain only the strings the Foundation shows: the Placeholder_Page labels, the theme and locale control labels (System, Light, Dark, English, Indonesia), the "Check connection" label with its success and failure messages, and the two-line messages for each Failure subtype.
4. WHEN the user changes the locale in AppSettings, THE app SHALL rebuild with the new locale.
5. THE `en` and `id` ARB files SHALL contain the same keys.
6. THE ARB strings SHALL follow the copy rules of `04` §10 (sentence case, no em dashes, loading labels end with "…").

### Requirement 13: Design tokens and the token generator

**User Story:** As a developer, I want brand decisions in one YAML file turned into typed Dart tokens, so that no
colour or size is typed by hand.

#### Acceptance Criteria

1. THE Skeleton SHALL contain `design/tokens.yaml` with the knobs of `04` §4.1, defaulting to neutral `sand`, accent `blue`, success `green`, danger `red`, warning `amber`, info `blue`, Inter as the sans face, and `primary: neutral`, and an empty `identity` list (`identity: []`) because the Radix_Scales hold only six scales.
2. THE Skeleton SHALL contain the Radix_Scales as a checked-in Dart file generated from data of `radix-ui/colors` and SHALL NOT contain colour values typed by hand. THE Skeleton SHALL contain the one-time fetch script `tool/radix/fetch_scales.dart` that reads `light.ts` and `dark.ts` of `radix-ui/colors` at commit `dbdb854` for the six scales and writes the Radix_Scales, without a new dependency, and THE `THIRD_PARTY_NOTICES.md` SHALL credit Radix Colors (MIT) with the commit.
3. WHEN the Token_Generator runs with a valid Tokens_File, THE Token_Generator SHALL write the Tokens_Output with `AppPalette` (light and dark), shadows, `AppSpace`, `AppRadius`, `AppStroke`, size sets for desktop and mobile, `AppLayout`, hue scales, and primary colours, and SHALL mark the file as generated.
4. THE Tokens_Output SHALL be committed to the repository.
5. WHEN the Token_Generator runs twice with the same inputs, THE Token_Generator SHALL write byte-identical output.
6. IF the Tokens_File names a neutral or hue that is not in the Radix_Scales, THEN THE Token_Generator SHALL exit with a non-zero code, print a message, and leave the Tokens_Output unchanged.
7. WHEN `tune_faint_text` is true, THE Token_Generator SHALL adjust only the OKLCH lightness of ink-9 and ink-10 until their gates pass, and SHALL print each adjustment.
8. THE Token_Generator SHALL print every applied `overrides` entry to stdout.
9. THE Token_Generator SHALL NOT write `docs/DESIGN_TOKENS.md`, since that belongs to `kit tokens`.
10. THE Token_Generator output contract (file name, class names, shape) SHALL stay compatible with `04` §4.2 so that `kit tokens` can replace it.

### Requirement 14: Blur conversion and contrast gates

**User Story:** As a developer, I want CSS shadow recipes converted correctly and contrast verified at generation
time, so that shadows look right and text stays readable.

#### Acceptance Criteria

1. THE Token_Generator SHALL convert CSS shadow blur to Flutter `blurRadius` with `max(0, (cssBlur / 2 − 0.5) / 0.57735)` and SHALL keep offsets and spread unchanged.
2. WHEN `cssBlur` is 0, THE converted `blurRadius` SHALL be 0.
3. WHEN `cssBlur` increases, THE converted `blurRadius` SHALL NOT decrease.
4. THE Token_Generator SHALL generate rings as zero-blur spread shadows.
5. THE Token_Generator SHALL check every Contrast_Gate of `04` §4.6 for both themes, with the minimums given there.
6. IF a Contrast_Gate fails after tuning, THEN THE Token_Generator SHALL print the failing pair and its ratio, exit with a non-zero code, and leave the Tokens_Output unchanged.
7. WHEN all gates pass, THE Token_Generator SHALL exit with code 0.
8. THE Skeleton SHALL record the result of the blur comparison against the browser screenshot of the same recipe (spike S16) in `README.md` or a doc referenced from it.

### Requirement 15: Tactile surfaces

**User Story:** As a developer, I want every surface to derive its fill, edge, and shadow from the surface under
it, so that one control looks right on any surface in both themes.

#### Acceptance Criteria

1. THE `core/theme/tactile/surface.dart` SHALL define the Surface_Kind enum with the values `ground, rail, panel, raised, overlay, sheet, well`.
2. WHEN a TactileSurface is built, THE TactileSurface SHALL paint its fill, edge, and drop relative to the parent SurfaceScope and SHALL provide a new SurfaceScope to its descendants.
3. THE SurfaceScope SHALL expose working ink steps 1–7, the line colour, hover and selected fills, and resolved shadow lists for `button`, `primary`, `toggle`, and `badge(hue)`.
4. THE SurfaceScope SHALL apply the light-mode remap table of `04` §5 and the dark-mode step-up rules of `04` §5.
5. THE ink steps 8–12 SHALL be identical on every surface.
6. THE hover fill SHALL be local ground + 1 step and the selected fill SHALL be local ground + 2 steps, so hover never equals selected.
7. WHEN the theme brightness changes, THE theme SHALL change only colours and shadows, and SHALL NOT change sizes, padding, radii, or stroke widths.
8. THE `core/theme/tactile/shadows.dart` SHALL resolve each recipe to a `List<BoxShadow>` per surface and theme using the Tokens_Output.
9. IF a descendant reads the SurfaceScope without an ancestor TactileSurface, THEN THE lookup SHALL return the `panel` scope of the current theme and SHALL NOT throw.

### Requirement 16: Pressable primitive

**User Story:** As a developer, I want one press primitive with hover, focus, and semantics, so that every
interactive element behaves consistently.

#### Acceptance Criteria

1. WHEN the user presses a Pressable, THE Pressable SHALL scale to a value passed as a required parameter (Pressable has no default scale), and WHEN the user releases it, THE Pressable SHALL return to scale 1.
2. WHEN a pointer hovers a Pressable, THE Pressable SHALL show the hover fill of its SurfaceScope, and WHEN the input mode is `touch`, THE Pressable SHALL show the hover fill while pressed.
3. WHEN a Pressable has keyboard focus from keyboard navigation, THE Pressable SHALL draw a 2 px focus ring with a 2 px offset.
4. WHEN the input mode is `touch`, THE Pressable SHALL extend its hit area to at least 48 × 48 without changing its visual size.
5. THE Pressable SHALL expose button semantics with a label and an enabled state.
6. WHEN the user has reduced motion enabled, THE Pressable SHALL still work and SHALL NOT animate travel or blur.
7. THE Foundation SHALL disable Material ink splash and ripple app-wide.

### Requirement 17: Typography

**User Story:** As a developer, I want type roles with one weight and absolute line heights, so that hierarchy
comes from size and ink step only.

#### Acceptance Criteria

1. THE `AppTypography` ThemeExtension SHALL define the roles `display, figure, section, title, body, description, meta, label, field, badge` with the sizes, line heights, tracking, and ink steps of `04` §6.1.
2. THE AppTypography SHALL use one font weight for all roles, taken from `typography.sans.weight` in the Tokens_File.
3. THE AppTypography SHALL set each role's Flutter `height` to `lineHeight / fontSize` with `leadingDistribution: TextLeadingDistribution.even`.
4. THE roles `figure`, and any role used for amounts, SHALL enable tabular figures.
5. WHEN the Window_Class is `mobile`, THE AppTypography SHALL use the mobile sizes, and WHEN the Window_Class is `tablet` or `desktop`, THE AppTypography SHALL use the desktop sizes.
6. WHEN the Input_Mode is `touch`, THE `field` role SHALL be 16/24.
7. THE `pubspec.yaml` SHALL register the Inter Medium font from `assets/fonts/` and SHALL NOT register Space Grotesk or Plus Jakarta Sans, whose files stay in `assets/fonts/` for apps that set `typography.heading`.
8. THE `typography.heading` knob SHALL default to null, and WHEN it is null THE AppTypography SHALL use the sans face for all roles.
9. THE Skeleton SHALL NOT use a font weight of `w600` or heavier outside `core/theme/`.

### Requirement 18: Motion

**User Story:** As a developer, I want motion tokens, springs, and a page transition defined once, so that every
animation uses the same curves and honours reduced motion.

#### Acceptance Criteria

1. THE `AppMotion` SHALL define the curves `easeOut, easeMove, easeDrawer, easeInOut` and the durations 80, 120, 150, 200, 240, 300, and 320 ms with the values of `04` §8.
2. THE `AppSprings` SHALL define `toggle` (bounce 0.12, 0.4 s), `knob` (bounce 0.2, 0.45 s), and `reveal` (bounce 0.2, 0.35 s).
3. IF the pinned Flutter provides `SpringDescription.withDurationAndBounce`, THEN THE AppSprings SHALL use it, and OTHERWISE THE AppSprings SHALL use `mass 1, stiffness (2π / d)², damping 4π(1 − bounce) / d` (spike S15).
4. THE `PageTransitionsTheme` SHALL apply the page entrance (fade and 16 px rise, 300 ms, on route mount only) on every platform.
5. THE `context.reduceMotion` SHALL return `MediaQuery.disableAnimationsOf(context)`.
6. WHEN `context.reduceMotion` is true, THE page entrance SHALL become a crossfade of 150–200 ms with no travel.
7. THE Foundation SHALL NOT use `Curves.easeIn*` and SHALL NOT use literal `Duration(...)` values in widget code outside `core/theme/`.

### Requirement 19: Theme mapping

**User Story:** As a developer, I want a single theme builder that maps tactile tokens onto Material theme parts,
so that the remaining Material widgets look tactile.

#### Acceptance Criteria

1. THE `buildTheme(brightness, windowClass, inputMode)` SHALL return a `ThemeData` with the mapping of `04` §9: splash factory, `ColorScheme`, `TextTheme`, `InputDecorationTheme`, `TooltipTheme`, `ScrollbarTheme`, `DividerTheme`, `TextSelectionTheme`, `PageTransitionsTheme`, and `ProgressIndicatorTheme`.
2. THE `ThemeData` SHALL include the `AppTypography` extension and the data needed by `theme_x.dart`.
3. THE `theme_x.dart` SHALL expose `context.surface`, `context.text`, `context.sizes`, `context.hue(...)`, and `context.reduceMotion`.
4. WHEN the Window_Class or Input_Mode changes, THE app SHALL rebuild the theme with the new values and SHALL keep the user's theme mode.
5. WHEN `buildTheme` is called with `light` and with `dark` for the same Window_Class and Input_Mode, THE two results SHALL have the same sizes, paddings, radii, and stroke widths.
6. THE `ColorScheme` SHALL map `primary` to ink-12, `onPrimary` to ink-1, `surface` to the panel colour, and `error` to danger-9, as in `04` §9.

### Requirement 20: Layout plumbing

**User Story:** As a developer, I want window class and input mode available on every context, so that features
never branch on the platform themselves.

#### Acceptance Criteria

1. THE `core/layout/window_class.dart` SHALL define `WindowClass` and `InputMode` and context extensions `context.windowClass` and `context.inputMode`.
2. WHEN the width is less than 768, THE WindowClass SHALL be `mobile`, WHEN the width is 768 to 1199, THE WindowClass SHALL be `tablet`, and WHEN the width is 1200 or more, THE WindowClass SHALL be `desktop`.
3. WHEN `defaultTargetPlatform` is iOS or Android, THE InputMode SHALL be `touch`, including on web, and OTHERWISE THE InputMode SHALL be `pointer`.
4. THE `AppLayout` tokens SHALL define breakpoints 768 and 1200, page columns 800, 1200, and 440, rail widths 256 and 72, top strip 52, mobile top bar 56, and panel float 8.
5. THE Skeleton SHALL NOT use `kIsWeb` or `Platform` checks in feature or presentation code to select layouts.
6. THE adaptive layout widgets (`AdaptiveScaffold`, `AdaptiveBuilder`, `PageColumn`, `AdaptiveGrid`, `ActionGroup`) are out of scope. The adaptive behaviour of this spec is limited to the Window_Class and Input_Mode plumbing and the App_Shell.

### Requirement 21: Router and shell

**User Story:** As a developer, I want all routes in one file and a shell that hosts routed content, so that
the app boots and later specs can add features and the adaptive shell.

#### Acceptance Criteria

1. THE `app/router/routes.dart` SHALL be the only file in the Skeleton that declares `GoRoute`.
2. THE `app/router/route_names.dart` SHALL define the route names used for navigation, and cross-feature navigation SHALL use these names and not imports.
3. THE router SHALL provide a root route that renders a placeholder page inside the App_Shell.
4. THE App_Shell SHALL host the routed child and SHALL leave a marked seam for the `AdaptiveScaffold` that `core-widgets-and-templates` provides.
5. THE `MaterialApp.router` in `app/app.dart` SHALL take `themeMode` and `locale` from AppSettingsCubit and SHALL use the theme from `buildTheme`.
6. WHEN the Window_Class changes, THE App_Shell SHALL rebuild with the theme for the new Window_Class, and THE App_Shell SHALL NOT show a navigation rail, tab bar, or floating panel.
7. THE Placeholder_Page SHALL provide controls to switch the theme mode between System, Light, and Dark and the locale between System, English, and Indonesia. THE controls SHALL be built only from `Pressable` and `TactileSurface`, and SHALL be marked with a seam comment naming `ThemeModeSwitch` as their replacement.
8. THE Placeholder_Page SHALL provide a "Check connection" button that requests the Health_URL through `ApiClient` and shows a success message or the message of the returned Failure.
9. WHILE a connection check is running, THE "Check connection" button SHALL be disabled and SHALL show a loading label, and THE button SHALL NOT start a second request.
10. THE Env class SHALL read `HEALTH_URL` and SHALL default it to `https://example.com`, and THE `env/example.json` SHALL list `HEALTH_URL`.

### Requirement 22: Architecture rules

**User Story:** As a maintainer, I want the layer rules of `03` §3 true from the first commit, so that generated
apps inherit a clean base.

#### Acceptance Criteria

1. THE Foundation SHALL NOT import any `features/*` path from `core/`.
2. THE `domain/` layers SHALL import only `core/error`, `core/usecase`, `fpdart`, `freezed_annotation`, and `meta`.
3. THE Foundation SHALL use one public class per file with file names in snake_case of the class name.
4. THE Foundation SHALL contain no raw colour literals, font sizes, font weights, curves, or durations in widget code outside `core/theme/` and the generated Tokens_Output.
5. THE Foundation SHALL use the `lib/` layout of `03` §4 and SHALL record any deviation (for example the Logger path) in `README.md` (the Logger lives in `core/log/`).
6. THE Foundation SHALL NOT create `lib/features/home/` or any feature folder.

### Requirement 23: Quality gates

**User Story:** As a maintainer, I want the foundation analysed and tested, so that later specs build on
something known good.

#### Acceptance Criteria

1. WHEN `flutter analyze` runs in `skeleton/`, THE Skeleton SHALL report zero issues.
2. WHEN `dart run build_runner build -d` runs, THE Skeleton SHALL finish without error and produce the generated files.
3. WHEN `flutter test` runs, THE Skeleton SHALL pass all tests.
4. THE Skeleton SHALL include unit or bloc tests for AppSettingsCubit, `guardRepository`, `dio_error_mapper`, the formatters, the window-class and input-mode mappings, the blur conversion, and the token generator's gate failure path. THE remaining behaviour SHALL be covered by table-driven tests.
5. THE Skeleton SHALL include property-based tests with `kiri_check` for the design properties 1 to 10, 17, and 18 (settings, status and connectivity mapping, blur conversion, window class, input mode), and SHALL cover the other design properties with table-driven tests or review.
6. THE Skeleton SHALL NOT include the stress harness or golden tests.

### Requirement 24: Phase 1 acceptance on the target platforms

**User Story:** As the project owner, I want proof that the skeleton runs on the platforms the hackathon demo
needs, so that later phases can depend on it.

#### Acceptance Criteria

1. WHEN `flutter run -d chrome` is used, THE Skeleton SHALL start on web and show the placeholder page inside the App_Shell with no uncaught error.
2. WHEN the app runs on an iOS simulator, THE Skeleton SHALL start and show the placeholder page inside the App_Shell with no uncaught error.
3. WHEN the app runs on an Android device or emulator, THE Skeleton SHALL start and show the placeholder page inside the App_Shell with no uncaught error.
4. WHEN the app runs on macOS, THE Skeleton SHALL start and show the placeholder page inside the App_Shell with no uncaught error.
5. WHEN the user selects System, Light, or Dark on the placeholder page, THE app SHALL switch to that theme immediately on every Target_Platform.
6. WHEN no theme has been chosen, THE app SHALL follow the device brightness.
7. WHEN the user selects a theme and a locale and restarts the app, THE app SHALL start with the same theme and locale on every Target_Platform.
8. WHEN the window width or device class crosses 768 or 1200, THE App_Shell SHALL react to the new Window_Class on web and macOS, by rebuilding the theme without changing the user's theme mode.
9. WHEN a Release_APK is installed, the app is opened, and the user presses "Check connection", THE Placeholder_Page SHALL show the success message. This requires that the user has accepted the Android SDK licences (`flutter doctor --android-licenses`), which is a user action outside the repository.
10. THE Skeleton SHALL build for Windows and Linux only to the extent that the platform folders exist; running them is not part of the acceptance.
