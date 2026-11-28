# Requirements Document

## Introduction

This spec completes the Phase 1 skeleton after `skeleton-foundation`. It delivers the core widgets listed in
`03` §6.1 (each with a `{@catalog}` doc block), the stress-test harness and accessibility checks, the golden setup,
a stress test and goldens for every core widget, the `home` example feature with every test type, the Mason bricks,
`tool/create_app.dart` and `tool/sync_core.dart`, and the CI workflow for the skeleton with the template job.

Sources: `docs/brief/03-architecture.md` §6–§7, `docs/brief/04-design-system.md` §7, §11, §12,
`docs/brief/02-repository-structure.md` (`create_app`, `sync_core`), `docs/brief/10-quality-ci-deploy.md`.

What already exists in `skeleton/` (built by `skeleton-foundation`, and this spec builds on it without rewriting it):
- Tactile primitives `TactileSurface` and `Pressable` (with `MinHitArea` and `PressFill`) in `lib/core/theme/tactile/`.
- `AppSettingsCubit`, `KeyValueStore`, `ApiClient`, `Failure`, the formatters, `WindowClass` and `InputMode`, `AppMotion`
  and `AppSprings`, `context.text`, `context.surface`, `context.reduceMotion`, the generated tokens, and the
  English and Indonesian ARB files.
- `AppShell` (a thin `Scaffold`, marked `TODO(core-widgets-and-templates)`) and `PlaceholderPage` (temporary theme and
  locale controls marked `SEAM(core-widgets-and-templates)`, and a "Check connection" button).
- `test/architecture/architecture_test.dart` (layer and token rules, currently asserting that `lib/features/` does not
  exist), `tool/check.dart`, and `kiri_check` 1.4.0 for property-based tests.
- Flutter 3.44.8 and Dart 3.12.2, `lucide_icons_flutter` (`LucideIcons300`), and Inter Medium as the only registered font.

Decisions applied here without a user question (all recorded in `spikes/crew-run/S3-requirements-review.md`):
- `kit` is out of scope and does not exist until Phase 2. This spec writes the `{@catalog}` blocks and tests
  for their presence, and does not generate `CATALOG.md` or run `kit check`.
- Layout widgets live in `lib/core/layout/`, all other widgets in `lib/core/widgets/` (`03` §4). `TactileSurface` and
  `Pressable` stay in `lib/core/theme/tactile/` and get a `{@catalog}` block, a stress test, and goldens there.
- Goldens are generated and compared only on this Mac. CI runs `--exclude-tags golden` (`04` §12).
- Mason is installed on this machine (`mason_cli` 0.1.4 on `PATH`), so bricks are verified by running `mason make`.
- The `home` feature replaces `PlaceholderPage` as the root route. The "Check connection" button goes with it.

Decisions the user answered (all recorded in `spikes/crew-run/S3-requirements-review.md` and `S4-spec-check.md`):
- CI is verified locally (YAML parse, every `run` step in a clean copy) and the first hosted run is a manual user step
  that is not a gate for code. Billing for GitHub Actions is fixed.
- The Skeleton has no `integration_test/`. "All test types" means unit, bloc, widget, stress, accessibility, golden,
  and property-based tests.
- "Check connection" is removed with `PlaceholderPage`. The network proof for the Release_APK (Requirements 3.5 and
  24.9 of `skeleton-foundation`) is already recorded as proven, so it is not needed in the skeleton any more.
- The language picker (System, English, Indonesia) of `PlaceholderPage` is kept (conductor decision S5, preserve existing
  behaviour). Home shows it next to `ThemeModeSwitch`, built with `AppSegmented`. The `locale*` strings and the persistence
  test stay. Only "Check connection" is removed.

Corrections after the independent spec review `spikes/crew-run/R4-spec-review.md` are listed in
`spikes/crew-run/S5-spec-fixes.md`. The requirement and criterion numbers below did not change (still 19 and 153).

Out of scope: `kit` (check, tokens, catalog, screens, api), `CATALOG.md` and `SCREENS.md` generation, hooks, skills,
steering, agents, `deploy-pages.yml`, the app-only widgets of `03` §6.2, and the stretch widgets (`AppSwitch`,
`AppMenu`, `AppSelect`, `StatusDot`, `AppTable`).

## Glossary

- **Skeleton**: the Flutter project in `skeleton/`.
- **Core_Widget**: any public widget class in `lib/core/widgets/`, `lib/core/layout/`, or the two primitives
  `TactileSurface` and `Pressable` in `lib/core/theme/tactile/`. The 25 names of `03` §6.1 are listed in Requirement 1.
- **Catalog_Block**: the `{@catalog} … {@endcatalog}` doc block on a Core_Widget with the fields `category`,
  `use_when`, `avoid_when`, `variants`, and `tags` (`05` §5).
- **Stress_Harness**: `test/helpers/stress.dart`, which exposes `stressTest` and `stressProperty`.
- **Stress_Profile**: `quick` (default) or `full`, selected with `--dart-define=STRESS=full`.
- **Fixture**: one of `normal`, `long`, `longWord`, `empty`, `emoji`, `rtl`, `bigNumber`, `nullValue` (`04` §12).
- **Accessibility_Checks**: the `flutter_test` guideline matchers `androidTapTargetGuideline`,
  `labeledTapTargetGuideline`, and `textContrastGuideline`.
- **Golden_Setup**: `test/helpers/golden.dart` and the font loading, device pixel ratio, platform, and tag it applies.
- **Golden_Test**: a test tagged `golden` that compares a rendered widget with a committed PNG.
- **Window_Class**: `mobile` (< 768), `tablet` (768–1199), or `desktop` (≥ 1200).
- **Home_Feature**: the example feature in `lib/features/home/`.
- **Home_View**: `HomeView`, the widget that renders the Home_Feature states; `HomePage` provides the bloc.
- **Brick**: a Mason template in `skeleton/bricks/<name>/`. The five bricks are `feature`, `page`, `bloc`, `usecase`,
  and `core_widget`.
- **Create_App**: `tool/create_app.dart` at the repository root.
- **Sync_Core**: `tool/sync_core.dart` at the repository root.
- **Template_Job**: the CI job that runs Create_App into a temporary folder and then analyses and tests the result.
- **CI_Workflow**: `.github/workflows/ci.yml`.
- **Quality_Gate**: `dart run tool/check.dart` in `skeleton/` (format, build_runner, analyze, test).
- **Reduced_Motion**: `MediaQuery.disableAnimationsOf(context)`, exposed as `context.reduceMotion`.

## Requirements

### Requirement 1: Core widget inventory and catalog blocks

**User Story:** As a developer or an agent, I want every core widget to describe when to use it, so that the
widget is found and reused instead of duplicated.

#### Acceptance Criteria

1. THE Skeleton SHALL provide these Core_Widgets: `TactileSurface`, `Pressable`, `AppButton`, `AppIconButton`, `AppPill`, `AppTextField`, `SearchField`, `AppSegmented`, `ThemeModeSwitch`, `AppCard`, `AppRow`, `SectionHeader`, `AppBadge`, `EmptyState`, `ErrorView`, `LoadingView`, `SkeletonBlock`, `AppToast` with `ToastController`, `AppDialog` with `showConfirm`, `AppSheet`, `AdaptiveScaffold`, `PageColumn`, `AdaptiveGrid`, `AdaptiveBuilder`, and `ActionGroup` (`03` §6.1).
2. THE Skeleton SHALL place `AdaptiveScaffold`, `PageColumn`, `AdaptiveGrid`, `AdaptiveBuilder`, and `ActionGroup` in `lib/core/layout/`, and every other new Core_Widget in `lib/core/widgets/`, with one public class per file named in snake_case after the class.
3. THE Skeleton SHALL give every Core_Widget a Catalog_Block whose `category` is one of `primitive`, `action`, `input`, `content`, `feedback`, `overlay`, or `layout`, and whose `use_when`, `avoid_when`, `variants`, and `tags` fields are non-empty, using the categories of `03` §6.1. Helper enums and data types of a Core_Widget (for example `AppButtonSize`, `ActionGroupGap`, `AppSegment`, `AdaptiveDestination`, `ToastRequest`) and the helpers `MinHitArea` and `PressFill` are not Core_Widgets and need no Catalog_Block.
4. THE Skeleton SHALL include a test that scans the Core_Widget files and fails WHEN a public Core_Widget has no Catalog_Block or a Catalog_Block with a missing field or an unknown category. This test stands in for `kit check` rule WID002 until Phase 2.
5. THE Skeleton SHALL NOT contain a hand-written or generated `lib/core/widgets/CATALOG.md`, because `kit catalog` produces it in Phase 2.
6. THE `README.md` SHALL list the Core_Widgets by category with a one-line description and the path of each.

### Requirement 2: Rules shared by every core widget

**User Story:** As a maintainer, I want one set of rules that every core widget follows, so that features composed
from them look and behave the same in both themes.

#### Acceptance Criteria

1. THE Core_Widgets SHALL read colours, sizes, radii, shadows, text styles, curves, and durations only from the theme (`context.surface`, `context.text`, `context.sizes`, `AppMotion`, `AppSprings`, tokens), and THE existing architecture test SHALL continue to pass with no new per-file allowlist entry for raw colour, size, weight, curve, or duration literals.
2. THE Core_Widgets SHALL NOT use Material visual widgets (buttons, cards, chips, list tiles, dialogs, sheets, snackbars, switches, segmented buttons, menus), and SHALL use Material only as infrastructure (routes, text editing, semantics, scrolling, tooltips).
3. THE Core_Widgets SHALL use one font weight and SHALL NOT use `FontWeight.w600` or heavier.
4. THE Core_Widgets SHALL take user-facing strings from `context.l10n` or from a caller argument, and SHALL NOT contain hardcoded English text; every new string SHALL exist in `app_en.arb` and `app_id.arb`.
5. WHEN Reduced_Motion is true, EVERY Core_Widget that animates SHALL replace travel, blur, and scale with a crossfade of 150–200 ms, SHALL move the segmented pill and any knob instantly where `04` §8 says so, and MAY keep the press scale.
6. WHEN `InputMode` is `touch`, EVERY interactive Core_Widget SHALL have a hit area of at least 48 × 48 logical pixels, through `Pressable` and `MinHitArea`.
7. THE interactive Core_Widgets SHALL expose a semantics label and role, a visible focus ring for keyboard focus, and a hover or pressed fill from `PressFill`.
8. WHEN the theme switches between light and dark, THE Core_Widgets SHALL change only colours and shadows, and SHALL keep sizes, padding, radii, and stroke widths unchanged.
9. WHERE a Core_Widget shows an icon, THE Core_Widget SHALL use `lucide_icons_flutter` with `LucideIcons300`.
10. THE Core_Widgets SHALL NOT import any `features/` path, and THE Core_Widgets in `core/widgets` and `core/layout` SHALL get press, hover, focus ring, disabled state, and the 48 px hit area from `Pressable` and SHALL NOT build a second press implementation. A Core_Widget MAY paint its own fill and shadow with a `DecoratedBox` WHEN the fill comes from `context.surface` or the palette and the shadow comes from `SurfaceScope` recipes (`button()`, `primary()`, `toggle()`, `badge(hue)`), and MAY use `TactileSurface` where one of its `SurfaceKind`s fits.

### Requirement 3: Action widgets

**User Story:** As a feature developer, I want buttons and pills that carry the design rules, so that I never style a
button by hand.

#### Acceptance Criteria

1. THE `AppButton` SHALL provide the roles `primary`, `secondary`, `ghost`, `destructive`, and `destructiveConfirm` as named constructors, the sizes `regular` and `compact`, an optional 16 px leading icon, and a loading state.
2. WHEN `AppButton` is loading, THE `AppButton` SHALL replace its label in place with the loading label supplied by the caller, SHALL ignore presses, and SHALL keep its size unchanged.
3. WHEN `AppButton` is disabled, THE `AppButton` SHALL render at 60 % opacity (the `Pressable` disabled opacity), and THE dark `primary` SHALL paint a solid ink-4 fill with ink-8 text under that opacity (`04` §7 "disabled .6, dark primary turns solid ink-4/ink-8").
4. THE `AppButton.destructive` SHALL render as a secondary button with danger-11 text, and THE `AppButton.destructiveConfirm` SHALL render solid danger-9.
5. WHEN `AppButton` is pressed, THE `AppButton` SHALL scale to 0.97, and THE `AppButton` SHALL NOT wrap its label.
6. THE `AppIconButton` SHALL provide the sizes 22, 28, and 44, a required tooltip with zero wait, a press scale of 0.92 (0.94 for the 44 size), and an ink-10 to ink-12 colour change on hover.
7. THE `AppPill` SHALL render a round pill 28 px tall (36 px on touch), raised from its surface, with an optional 14 px icon.
8. WHEN the `AppPill` copy mode is used and the user presses it, THE `AppPill` SHALL show a tick on the pill itself, SHALL revert the tick on failure, and SHALL hold the tick for 1.5 s (1.0 s for an icon-only pill), and SHALL NOT show a toast.
9. THE `ActionGroup` SHALL place the secondary action first and the primary at the far right with buttons hugging their labels on desktop and tablet, and SHALL stack the actions full width with the primary on top on mobile, with gaps of 12 for pages and 8 for dialogs and sheets.

### Requirement 4: Input widgets

**User Story:** As a feature developer, I want text fields, search, and segmented toggles that follow the design, so
that forms and filters need no custom styling.

#### Acceptance Criteria

1. THE `AppTextField` SHALL render a well (ink-3, no border) with a label above, optional help text below, and an error state, and SHALL deepen to ink-4 plus the 2 px focus ring on keyboard focus.
2. WHEN `AppTextField` has an error message, THE `AppTextField` SHALL show a 1 px danger-11 ring and the message, and SHALL validate on blur and on submit.
3. THE `AppTextField` SHALL use the `field` text role (13/20 in pointer mode, 16/24 in touch mode) and SHALL respect `MediaQuery.viewInsets` when inside a scrolling form.
4. THE `SearchField` SHALL render the well style with a clear button that appears only while text is present, SHALL render raised instead of well on mobile in light mode, and SHALL call its `onChanged` callback through the core `Debouncer` with a default delay of 400 ms.
5. THE `AppSegmented` SHALL render a track one step darker than its surface (lighter in dark mode), a 4 px inset, and one sliding raised pill that uses `AppSprings.toggle`, SHALL place the pill without animation on its first build, and SHALL hug its content.
6. THE `AppSegmented` SHALL provide a page-level variant with 14 px icons, and on mobile SHALL use 34 px options in a 42 px track.
7. THE `ThemeModeSwitch` SHALL render the page-level `AppSegmented` with the options System, Light, and Dark and icons, SHALL show the current `AppSettings.themeMode` as selected, and SHALL call `AppSettingsCubit.setThemeMode` WHEN an option is pressed.
8. WHEN the theme mode is changed through `ThemeModeSwitch` and the app restarts, THE app SHALL start with the saved theme mode.

### Requirement 5: Content widgets

**User Story:** As a feature developer, I want cards, rows, section headers, and badges, so that pages are composed
without custom boxes.

#### Acceptance Criteria

1. THE `AppCard` SHALL provide `.data` and `.clickable` constructors, SHALL use the radius container and card shadow with padding 24 (20 on mobile), and SHALL provide a new `SurfaceScope` to its children.
2. WHEN `AppCard.clickable` is pressed, THE `AppCard` SHALL scale to 0.99 and SHALL fill ink-2 on hover.
3. THE `AppRow` SHALL render a plain row with no box, a minimum height of 38 (44 on mobile; `AppSizeSet.pointer.row` and `04` §7 agree), a title in ink-12, an optional description in ink-11, and an optional trailing value right-aligned with tabular figures, and SHALL fill only on hover and press.
4. THE `SectionHeader` SHALL render a title at 20/28, a 6 px gap, an optional description in ink-11, and optional actions on the right, and SHALL place the actions under the description at full width on mobile.
5. THE `AppBadge` SHALL provide `.tone(hue)` and `.neutral` constructors, SHALL render a hue-3 fill with hue-11 text for `.tone`, SHALL be 20 px tall (22 on mobile), and SHALL NOT wrap its label.
6. THE `AppCard`, `AppRow`, `SectionHeader`, and `AppBadge` SHALL clamp titles at 2 lines and descriptions at 2 lines, and SHALL truncate one-line free text with "…".
7. THE `AppCard`, `AppRow`, `SectionHeader`, and `AppBadge` SHALL NOT use a fixed height on any container that holds text.

### Requirement 6: Feedback widgets

**User Story:** As a feature developer, I want empty, error, loading, and toast widgets, so that every data page
renders every state the same way.

#### Acceptance Criteria

1. THE `EmptyState` SHALL render a bare centred ink-2 panel with 44 px padding, an 18 px icon (24 px on mobile), and two lines of text (what is missing, what to do), both supplied by the caller.
2. THE `ErrorView` SHALL map each `Failure` subtype to a localized two-line message from the ARB files (the seven `failure<Name>Title` and `failure<Name>Body` pairs already exist, so this spec adds none), and SHALL render one secondary "Try again" button that calls the caller's retry callback.
3. THE `ErrorView` SHALL NOT show raw exception text or a stack trace.
4. THE `LoadingView` SHALL keep the layout of the content it stands for, and THE `SkeletonBlock` SHALL pulse between the a3 and a4 alpha steps, and WHEN Reduced_Motion is true THE `SkeletonBlock` SHALL NOT pulse.
5. WHEN `EmptyState`, `ErrorView`, and `LoadingView` replace each other in one page, THE page SHALL share one cell sized to the larger state so that nothing jumps (`04` §11.11), and THE Skeleton SHALL provide that behaviour through a documented pattern or helper in the Core_Widgets.
6. THE `ToastController` SHALL show one `AppToast` at a time, replacing the current toast when a new one is shown, at the bottom centre, 48 px tall, with an optional single action, dismissed after 6 s. THE `AppToast` host SHALL receive the controller as an argument, and SHALL NOT contain a widget that needs an `Overlay` (such as `Tooltip`), because the host sits above the `Navigator`.
7. THE `AppToast` SHALL NOT be used for a copy confirmation, and THE `ToastController` SHALL be registered in dependency injection.

### Requirement 7: Overlay widgets

**User Story:** As a feature developer, I want dialogs and sheets that adapt to the screen, so that confirmations
work on every window class.

#### Acceptance Criteria

1. THE `AppDialog` SHALL support the widths 620 (default), 460 (confirm), and 440 (info), SHALL split header, body, and footer with hairlines, SHALL place Cancel on the left and the confirm action on the right, and SHALL NOT show a close "×" when it has a footer.
2. THE `AppDialog` SHALL render a backdrop of black at 30 % in light and 90 % in dark with a 2 px blur, SHALL focus its first field on open, and SHALL enter with a 16 px rise, 4 px blur, and fade in 240 ms and exit in 200 ms.
3. THE `showConfirm` function SHALL show an `AppDialog` of width 460 with a cancel action and one confirm action named by the caller, and SHALL return `true` only WHEN the user confirms.
4. WHEN the Window_Class is `mobile`, THE `AppDialog` and `showConfirm` SHALL show an `AppSheet` instead.
5. THE `AppSheet` SHALL render only on mobile, with a surface top fill (ink-2 in dark), a 14 px top radius, a 36 × 5 grab handle with an 88 × 44 hit area, a title on the sheet with no header band, and buttons below its content, SHALL rise in 320 ms and sink in 200 ms, and SHALL dismiss by dragging down.
6. WHEN Reduced_Motion is true, THE `AppDialog` and `AppSheet` SHALL replace the rise and blur with a 150–200 ms crossfade.
7. THE `AppDialog` and `AppSheet` SHALL NOT use `showDialog`, `showModalBottomSheet`, `AlertDialog`, or `Dialog` from Material for their visuals.

### Requirement 8: Layout widgets and shell

**User Story:** As a feature developer, I want one adaptive shell and page-column widgets, so that every page is
correct on mobile, tablet, and desktop.

#### Acceptance Criteria

1. THE `AdaptiveScaffold` SHALL on `desktop` render a rail on the ground, a floating panel (8 px off the window, container radius, panel shadow), and a 52 px top strip with the title centred, breadcrumbs left, and page actions right.
2. THE `AdaptiveScaffold` SHALL on `tablet` render a collapsed rail, and SHALL on `mobile` render a 56 px top bar with the title left and page actions right, and a bottom tab bar on surface top with a hairline above it, the active item in ink-12 over an ink-3 fill, inactive items in ink-10, and labels always shown.
3. THE `AdaptiveScaffold` SHALL take the app's destinations as a list, SHALL mark the current destination, and SHALL show a sticky hairline under the top bar or strip only once content scrolls under it.
4. WHEN the window width crosses 768 or 1200, THE `AdaptiveScaffold` SHALL switch layout without losing the current page's state.
5. THE `app/router/app_shell.dart` SHALL use `AdaptiveScaffold` with the Home_Feature destination, and THE `TODO(core-widgets-and-templates)` marker in that file SHALL be removed.
6. THE `PageColumn` SHALL provide `.reading` (800), `.data` (1200), and `.form` (440) constructors, SHALL cap prose at 70 characters, and SHALL leave 48 above the first title and 64 at the page foot.
7. THE `AdaptiveGrid` SHALL choose its column count from the Window_Class, and THE `AdaptiveBuilder` SHALL take `mobile`, `tablet`, and `desktop` builders and SHALL fall back to the nearest smaller builder WHEN one is omitted.
8. THE layout widgets SHALL provide the `SafeArea` on mobile and SHALL scroll when content exceeds the viewport.

### Requirement 9: Stress harness

**User Story:** As a developer, I want one harness that renders a widget across sizes, text scales, themes, and
hostile data, so that overflow bugs fail a test before a user sees them.

#### Acceptance Criteria

1. THE Skeleton SHALL provide `test/helpers/stress.dart` exposing `stressTest(name, builder, ...)` that renders the widget returned by `builder` for every combination of the active Stress_Profile and every Fixture.
2. THE `quick` Stress_Profile SHALL render at 320×640 at device pixel ratio 2.0 with touch input, and at 1600×900 at 1.0 with pointer input, both in light mode and with all Fixtures, and SHALL also render at 375×812 at 1.0 in dark mode with the `normal` Fixture, for 17 renders per widget.
3. THE `full` Stress_Profile SHALL render the sizes 320×640, 375×812, 768×1024, 1024×768, 1200×800, and 1600×900, the text scales 1.0, 1.5, and 2.0, light and dark, and all Fixtures, with touch input for the sizes up to and including 1024 wide (320, 375, 768, 1024) and pointer input for the sizes from 768 wide up (768, 1024, 1200, 1600). That is 8 (size, input) combinations × 3 scales × 2 themes = 48 groups and 48 × 8 = 384 fixture renders per widget.
4. THE Stress_Harness SHALL select the profile with `--dart-define=STRESS=full` and SHALL default to `quick`.
5. THE Stress_Harness SHALL provide the Fixtures `normal`, `long` (60 words), `longWord` (80 characters without spaces), `empty`, `emoji`, `rtl`, `bigNumber` (9 digits), and `nullValue`.
6. WHEN a `FlutterError`, including `RenderFlex overflowed`, is raised during a render, THE Stress_Harness SHALL fail the test, and the test name SHALL include the size, text scale, theme, input mode, and Fixture of the failing combination.
7. THE Stress_Harness SHALL wrap each widget in the real theme from `buildTheme`, the app's localization delegates, and a `SurfaceScope`, so that the widget renders as it does in the app, and SHALL load the bundled Inter font once per test file so that text metrics match the app (the `full` profile is not run with the Ahem font).
8. THE `stressProperty` function SHALL use `kiri_check` to generate random strings and numbers for the Fixture fields, with a fixed seed in CI. IF the spike of task A7 shows that `kiri_check` cannot drive a widget test, THEN the fallback of the design (a seeded generator) SHALL be used and the README SHALL record the deviation; this is the only case in which this criterion is met without `kiri_check` in `stressProperty`.
9. THE Skeleton SHALL include a test for the Stress_Harness itself that shows a known-overflowing widget fails with the combination in its name and a known-good widget passes.
10. THE `.gitignore` SHALL ignore `test/**/failures/`, and THE Stress_Harness SHALL write failure images there.

### Requirement 10: Accessibility checks

**User Story:** As a developer, I want accessibility guidelines checked automatically, so that tap targets, labels,
and contrast do not regress.

#### Acceptance Criteria

1. WHEN the `quick` Stress_Profile renders a widget at 375×812, THE Stress_Harness SHALL run `androidTapTargetGuideline`, `labeledTapTargetGuideline`, and `textContrastGuideline` in light and dark.
2. THE Stress_Harness SHALL let a test skip `textContrastGuideline` only by passing a non-empty written reason, and SHALL fail the test WHEN the reason is empty.
3. WHEN a Core_Widget is interactive, THE Accessibility_Checks SHALL pass for it in light and dark with the `normal` Fixture.

### Requirement 11: Golden setup

**User Story:** As a developer, I want goldens that show the real fonts and hairlines, so that I can review the
design in light and dark.

#### Acceptance Criteria

1. THE Golden_Setup SHALL load the bundled Inter Medium font with `FontLoader` before a Golden_Test renders, so that the test does not draw with the Ahem font.
2. THE Golden_Setup SHALL set `devicePixelRatio` to 2 and SHALL set both `ThemeData.platform` and `debugDefaultTargetPlatformOverride` to macOS (`context.inputMode` reads `defaultTargetPlatform`, not `Theme.platform`), so that 0.5 px hairlines show and the layout is in pointer mode.
3. THE Golden_Setup SHALL tag every Golden_Test `golden`, SHALL register the tag in `dart_test.yaml`, and `flutter test --tags golden --update-goldens` SHALL create or update the files while `flutter test --tags golden` compares them.
4. THE Golden_Setup SHALL fail with a clear message WHEN the host operating system is not macOS and a Golden_Test runs, instead of writing or comparing goldens.
5. THE Skeleton SHALL commit the goldens, SHALL store them next to the tests in `goldens/` folders, and SHALL generate them on this Mac only.
6. THE Skeleton SHALL include at least one test that pumps the real app root (`App` with the router), not a widget wrapped in a `Scaffold`, so that a missing Material ancestor fails the test. Until the shell uses `AdaptiveScaffold` (task H5), `test/app/app_test.dart` (which already pumps `App()` with the real router) is this test. H5 adds a case that finds `AdaptiveScaffold` in `App()` at 390×844.
7. THE `flutter test --tags golden` run SHALL produce the same pixels on two consecutive runs on this Mac.
8. THE `README.md` SHALL replace the sentence "There is no golden test and no stress harness" with the commands to run the quick and full stress profiles and the golden tests.

### Requirement 12: Stress tests and goldens for every core widget

**User Story:** As a maintainer, I want every core widget stressed and pictured in both themes, so that a visual or
layout regression is caught before it ships.

#### Acceptance Criteria

1. FOR EACH Core_Widget in Requirement 1, THE Skeleton SHALL contain a stress test in `test/core/…` mirroring the widget's path, using the `normal`, `long`, `longWord`, `empty`, `emoji`, `rtl`, `bigNumber`, and `nullValue` Fixtures wherever the widget takes text or a number.
2. FOR EACH Core_Widget in Requirement 1, THE Skeleton SHALL contain a Golden_Test in light and dark at device pixel ratio 2, showing the widget's variants and states (default, hover or pressed where visible, disabled, loading, error, selected) in one image per theme.
3. THE Skeleton SHALL contain a Golden_Test of the shell (`AdaptiveScaffold` with the Home_Feature) at 390×844, 834×1194, and 1440×900 in light and dark.
4. THE `quick` Stress_Profile SHALL pass for every Core_Widget with zero `FlutterError`, and THE Accessibility_Checks SHALL pass for every interactive Core_Widget.
5. THE Skeleton SHALL include a test that fails WHEN a Core_Widget has no stress test file or no golden file in both themes. This test stands in for `kit check` rule UI005 until Phase 2.
6. WHEN the goldens are viewed at 2× zoom, THE goldens of the shell and of every Core_Widget SHALL look correct in light and dark (acceptance, reviewed by the user).

### Requirement 13: The `home` example feature

**User Story:** As a developer or an agent, I want one complete example feature, so that I can copy a known-good
pattern for pages, blocs, and tests.

#### Acceptance Criteria

1. THE Home_Feature SHALL live in `lib/features/home/` with `data/`, `domain/`, and `presentation/` folders and a `FEATURE.md` that states `source: local` and lists its files.
2. THE `domain/` folder SHALL contain an entity, a repository interface, and one use case `GetHomeItems` that returns `Either<Failure, List<HomeItem>>`, and SHALL import only the packages allowed by `03` §3.
3. THE `data/` folder SHALL contain a local data source that returns a static list, a repository implementation that wraps the call with `guardRepository`, and a mapper written as extension methods.
4. THE `presentation/` folder SHALL contain `HomePage` (provides the bloc, referenced by the route), `HomeView` (renders), a `HomeBloc` or `HomeCubit` with the single freezed union `initial | loading | success(data) | empty | failure(Failure)`, and the feature widgets `HomeSummaryTile` and `LanguageSwitch` (the language picker of the placeholder, built with `AppSegmented`, reading `AppSettingsCubit`).
5. THE Home_View SHALL render inside `AdaptiveScaffold` with a `SectionHeader`, a list of `AppRow`s, one secondary action and one primary action built with `AppButton` in an `ActionGroup`, and `ThemeModeSwitch`, and the `LanguageSwitch` (System, English, Indonesia).
6. THE Home_View SHALL render the `LoadingView` for `loading`, the `EmptyState` for `empty`, and the `ErrorView` with "Try again" for `failure`.
7. THE Home_Feature SHALL be registered in dependency injection (`@lazySingleton` for the data source and repository, `@injectable` for the use case and bloc) and SHALL be reachable through a route name in `route_names.dart` and a `GoRoute` in `routes.dart`.
8. THE Home_Feature SHALL NOT import any other feature, SHALL NOT use Material visual widgets, and SHALL use l10n strings in English and Indonesian that follow the copy rules of `04` §10.
9. THE `HomePage` SHALL carry a `{@screen summary: ...}` doc block, and THE Home_Feature SHALL contain no business logic in widgets.
10. WHEN `PlaceholderPage` is replaced by the Home_Feature, THE Skeleton SHALL remove `PlaceholderPage` and the `SEAM(core-widgets-and-templates)` markers, SHALL remove the "Check connection" button, and SHALL remove `ConnectionCheckCubit`, its state, its tests, its DI registration, its `checkConnection*` strings, and `Env.connectionCheckUrl`, because nothing else in the Skeleton uses them. THE language picker SHALL NOT be removed: it moves to the Home_View as `LanguageSwitch`, the `locale*` strings stay, and the test that a saved Dark and Indonesia survive a restart stays (rewritten to find the home page). THE `README.md` SHALL record that the network proof of the Release_APK (Requirements 3.5 and 24.9 of `skeleton-foundation`) was obtained before the button was removed.
11. WHEN the Home_Feature exists, THE architecture test SHALL stop asserting that `lib/features/` does not exist and SHALL instead keep every layer rule applying to `lib/features/home/`, including the rule that `domain/` imports only the allowed packages.

### Requirement 14: Tests for the `home` feature

**User Story:** As a developer, I want the example feature to show every test type, so that I can copy each one.

#### Acceptance Criteria

1. THE Skeleton SHALL contain a unit test for the mapper, the use case, and the repository implementation of the Home_Feature (with a mock data source from `mocktail`), covering the success and the thrown-exception paths.
2. THE Skeleton SHALL contain a `bloc_test` for the Home_Feature's bloc or cubit that covers `initial → loading → success`, `loading → empty`, and `loading → failure`.
3. THE Skeleton SHALL contain a widget test of `HomeView` with a mock bloc that renders each of the four non-initial states and checks that "Try again" calls the retry event.
4. THE Skeleton SHALL contain a `stressTest` of `HomeView` and the Accessibility_Checks for it.
5. THE Skeleton SHALL contain Golden_Tests of `HomeView` at 390×844, 834×1194, and 1440×900 in light and dark (6 images).
6. THE Skeleton SHALL contain at least one property-based test with `kiri_check` for the Home_Feature's mapper or use case.
7. THE Skeleton SHALL NOT contain an `integration_test/` folder. THE `README.md` SHALL state that "all test types" means unit, bloc, widget, stress, accessibility, golden, and property-based tests, and that the integration happy path belongs to each app (`10` §1).

### Requirement 15: Mason bricks

**User Story:** As a developer, I want local Mason bricks, so that a feature, page, bloc, use case, or core widget
starts from a known-good shape.

#### Acceptance Criteria

1. THE Skeleton SHALL contain `mason.yaml` that registers the bricks `feature`, `page`, `bloc`, `usecase`, and `core_widget` with local paths under `bricks/`.
2. THE `feature` Brick SHALL generate `data/`, `domain/`, and `presentation/` folders for a feature name, a `FEATURE.md`, and the files and suffixes of `03` §5 (entity, repository interface and implementation, data source, mapper, use case, bloc with event and state, page, view).
3. THE `page` Brick SHALL generate a `*_page.dart` and a `*_view.dart` pair with a `{@screen summary: ...}` doc block, and THE `bloc` Brick SHALL generate `*_bloc.dart`, `*_event.dart`, and `*_state.dart` with the loading union of `03` §5.
4. THE `usecase` Brick SHALL generate a `*_usecase.dart` class implementing the core `UseCase`, and THE `core_widget` Brick SHALL generate a widget in `lib/core/widgets/` with a Catalog_Block, a stress test, and a golden test.
5. THE Bricks SHALL generate code that uses only core widgets and tokens for UI, uses `context.l10n` strings, and passes `dart format`.
6. WHEN each Brick is run with `mason make` into a temporary copy of the Skeleton, THE result SHALL pass `dart run build_runner build`, `flutter analyze` with zero issues, and the generated tests. THE Brick template files SHALL NOT make the Skeleton's own `dart format` or `flutter analyze` fail (the `bricks/` folder is excluded from both).
7. THE Skeleton SHALL include a test that runs the five Bricks into a temporary folder and checks the generated file names and the output of the checks of criterion 6, and SHALL skip with a clear message only WHEN `mason` is not on `PATH` or the temporary `flutter pub get` cannot reach the network. THE test SHALL carry a timeout of at least 10 minutes and the tag `slow`.
8. THE `README.md` SHALL list the Brick commands and the pinned `mason_cli` version.

### Requirement 16: `create_app`

**User Story:** As a developer, I want one command that turns the skeleton into a new, named app, so that I start
from a clean, runnable project.

#### Acceptance Criteria

1. THE Create_App script SHALL be run as `dart run tool/create_app.dart <package_name> [--dir <folder>] [--org com.example] [--display-name "My App"] [--out .] [--clean]`.
2. WHEN `package_name` is not a valid Dart package name, or the target `<out>/<dir>` exists, THE Create_App SHALL exit non-zero with a clear message and SHALL NOT write any file.
3. THE Create_App SHALL copy `skeleton/` to the target, excluding `build/`, `.dart_tool/`, `*.iml`, `.idea/`, and `pubspec.lock`, as real files with no symlinks.
4. THE Create_App SHALL replace the package name in `pubspec.yaml` and every `package:skeleton/` import, and SHALL set the bundle and application IDs for Android (`applicationId`, `namespace`), iOS and macOS (`PRODUCT_BUNDLE_IDENTIFIER`), Linux (`APPLICATION_ID`), Windows (`BINARY_NAME`), and web (`manifest.json` name and short_name, `index.html` title) from `--org` and the package name.
5. THE Create_App SHALL keep the Android `INTERNET` permission, the `https` `<queries>` entry, and the macOS `com.apple.security.network.client` entitlement (`03` §5).
6. IF replacing text in platform files is fragile, THEN THE Create_App SHALL run `flutter create --org <org> --project-name <name>` into a temporary folder and copy its platform folders, and keep the platform setup of criterion 5.
7. THE Create_App SHALL reset `api/openapi.yaml`, `api/api_map.yaml`, `api/CHANGELOG.md`, and `.kiro/steering/product.md` to templates WHEN those files exist, and SHALL skip them without error WHEN they do not exist yet (they arrive in Phase 2).
8. WHEN `--clean` is given, THE Create_App SHALL remove the Home_Feature, its tests and goldens, its route, its route name, its DI registrations, and its strings, SHALL rewrite or remove every other test that names the Home_Feature (routes, app, shell golden, architecture layer rule), and THE result SHALL still pass `flutter analyze` and `flutter test`.
9. WHEN the target is not inside a git repository, THE Create_App SHALL run `git init` and make a first commit with a fixed author identity passed on the command line, so that it works on a machine with no git identity.
10. THE Create_App SHALL then run `flutter pub get`, `dart run build_runner build -d`, and the token generator, and SHALL print the next steps (open the folder in Kiro, fill `product.md`, adjust `design/tokens.yaml`) without referring to `kit` commands that do not exist yet.
11. WHEN `create_app.dart` runs into a temporary folder, THE generated app SHALL pass `flutter analyze` with zero issues and `flutter test --exclude-tags golden`, with and without `--clean`. THE copied tests that assert the name `Skeleton` (`test/platform/web_index_test.dart`) SHALL be rewritten to the new display name, and `test/docs/readme_test.dart` SHALL only check paths inside the app, so that they pass in the generated app.
12. THE Skeleton SHALL contain a test of the pure parts of the Create_App (name validation, text replacement, copy exclusions) that does not need Flutter to be installed.
13. THE generated app SHALL run on web, Android, iOS, and macOS (success criterion 1 of `00-overview.md`, without `kit check`), verified by `flutter build web` and by running at least on web and macOS on this Mac, with Android and iOS builds attempted and any failure reported with its cause.

### Requirement 17: `sync_core`

**User Story:** As a developer, I want a command that copies new core widgets from an app back into the skeleton,
so that widgets created in an app are reused by the next app.

#### Acceptance Criteria

1. THE Sync_Core script SHALL be run as `dart run tool/sync_core.dart --from <app> --to <target> [--dry-run]`.
2. THE Sync_Core SHALL find the files in `lib/core/widgets/**` and `lib/core/layout/**` of `--from` that are missing in `--to`.
3. THE Sync_Core SHALL copy each such widget together with its stress test and its goldens, and SHALL rewrite `package:<from>/` imports to `package:<to>/`.
4. WHEN a copied file imports a package that the `pubspec.yaml` of `--to` lacks, THE Sync_Core SHALL add that package with the version constraint from `--from` and SHALL run `flutter pub get`.
5. THE Sync_Core SHALL NOT overwrite an existing file, and WHEN a file exists in both with different content THE Sync_Core SHALL print a diff and stop with a non-zero exit code before writing anything.
6. WHEN `--dry-run` is given, THE Sync_Core SHALL print the files it would copy and the packages it would add and SHALL write nothing.
7. AFTER copying, THE Sync_Core SHALL run the copied tests in `--to`, and SHALL run `kit catalog` and `kit check` only WHEN `kit` exists in `--to`.
8. THE Skeleton SHALL contain a test that runs the Sync_Core on two temporary fixture projects and covers the copy, the import rewrite, the added package, the dry run, and the conflict stop.

### Requirement 18: CI workflow

**User Story:** As a maintainer, I want CI to run the same checks as the Quality_Gate, so that a pull request cannot
break the skeleton or the template.

#### Acceptance Criteria

1. THE CI_Workflow SHALL run on push and pull request, with path filters, on Ubuntu, for the project `skeleton` (the matrix keeps room for `app_orbit` and `app_tally`, which do not exist yet).
2. THE CI_Workflow SHALL check out, set up Flutter at the version pinned in `skeleton/README.md` and `skeleton/.fvmrc`, cache pub, run `flutter pub get`, `dart run build_runner build -d`, and `dart run tool/generate_tokens.dart`, and fail WHEN `git diff --exit-code` shows that generated files (`injection.config.dart`, `tokens.g.dart`) are stale.
3. THE CI_Workflow SHALL run `flutter analyze --fatal-infos` and `flutter test --exclude-tags golden --dart-define=STRESS=full`, and SHALL upload `test/**/failures/` as an artifact WHEN a test fails.
4. THE CI_Workflow SHALL run `flutter build web --release` for the skeleton.
5. THE CI_Workflow SHALL NOT run `kit tokens --check`, `kit check`, or the `kit-tests` job, because `kit` does not exist yet.
6. THE CI_Workflow SHALL contain the Template_Job, which runs `dart run tool/create_app.dart ci_app --out /tmp`, then `flutter analyze` and `flutter test --exclude-tags golden` in the result.
7. THE CI_Workflow SHALL NOT compare goldens, and THE CI_Workflow SHALL install `mason_cli` at the pinned version for the Brick test.
8. THE existing `.github/workflows/spike-pages.yml` SHALL NOT be changed or deleted by this spec.
9. THE CI_Workflow SHALL be verified locally: the YAML SHALL parse (and `actionlint` SHALL pass WHEN it is installed), and every `run` step SHALL pass when executed in order on this Mac in a clean copy. THE report SHALL state that the local run is not a hosted run.
10. AFTER the user pushes, THE first hosted run result (all jobs, including the Template_Job) SHALL be checked and recorded in `spikes/crew-run/` as a manual verification step of the user. This step SHALL NOT block the code of this spec, and a failed hosted run SHALL open a follow-up fix instead of reopening finished tasks.

### Requirement 19: Quality gates and documentation

**User Story:** As a maintainer, I want the finished spec proven by one command and documented, so that later phases
build on something known good.

#### Acceptance Criteria

1. WHEN `dart run tool/check.dart` runs in `skeleton/`, THE Skeleton SHALL pass `dart format`, `build_runner`, `flutter analyze` with zero issues, and `flutter test --exclude-tags golden` with the `quick` Stress_Profile.
2. WHEN `flutter test --tags golden` runs on this Mac, THE Skeleton SHALL pass every Golden_Test against the committed goldens.
3. WHEN `flutter test --dart-define=STRESS=full --exclude-tags golden` runs, THE Skeleton SHALL pass and THE report SHALL record its run time.
4. THE Skeleton SHALL keep every `skeleton-foundation` requirement true, except Requirement 22.6 and Requirement 23.6 of that spec, which this spec supersedes (`lib/features/` now exists; the stress harness and goldens now exist), and Requirements 3.5 and 24.9, which this spec retires together with the "Check connection" button (13.10).
5. THE `README.md` SHALL describe the Core_Widgets, the stress profiles, the golden commands, the Brick commands, `create_app`, `sync_core`, and every deviation from `03`, `04`, `02`, and `10`.
6. THE Skeleton SHALL NOT edit `docs/brief/`, and SHALL NOT add `kit`, hooks, skills, steering, or agents.
7. THE final report SHALL list, with evidence, each of: `create_app` output analysed and tested, goldens reviewed in light and dark at 2×, the CI steps run locally, the Bricks run, and anything not verified (for example Android or iOS builds that need a toolchain the Mac lacks).
