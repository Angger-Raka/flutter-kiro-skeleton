# Implementation Plan: core-widgets-and-templates

## Overview

This plan implements `requirements.md` (19 requirements, 153 acceptance criteria) and `design.md`. Paths are relative to
`skeleton/` unless they start with `tool/`, `.github/`, `spikes/`, or `.kiro/`, which are relative to the repository root.
There are 61 tasks: 57 `[kode]` or `[dok]` tasks and 4 `[manual]` tasks for the user (M1 to M4). Task A8 (compile check of the public API) was added after review R4.

How to read a task:

- Each leaf task is one small change with **one Conventional Commit**. The commit line is given in the task. Agents do not
  push. The user pushes.
- Tests live inside the task that adds the logic. A task is not done until its tests pass.
- **[kode]** changes code or tests. **[dok]** changes documentation only. **[manual]** is done by the user and changes no code
  (it may add a note under `spikes/crew-run/`).
- `Depends:` lists tasks that must be merged first. `Owns:` lists the files the task may create or edit. A task must not edit a file
  owned by another task (see "Shared files" below). `_Requirements_` and `_Design_` give the traceability.
- Every task ends with the gate **G**: `dart format --set-exit-if-changed .`, `flutter analyze` with zero issues, and
  `flutter test --exclude-tags golden` green. Tasks that change annotated code run `dart run build_runner build -d` first.
  Tasks that add goldens also run `flutter test --tags golden --update-goldens <file>` on this Mac, then `flutter test --tags golden <file>`.
  G is not repeated in each task.
- **Widget task template (W)** for tasks B1 to G2. Every widget task creates: the widget file (one public class per file, `{@catalog}` block,
  tokens only), `test/core/.../<snake>_test.dart` (behaviour group, `stressTest`, accessibility run when interactive, reduced-motion
  case when it animates, touch hit-area case when interactive, keyboard focus ring and hover fill cases when interactive, a semantics label and role check when interactive, and a theme invariance case
  that compares widget size and padding in light and dark), and `test/core/.../<snake>_golden_test.dart` with its
  `goldens/<snake>_light.png` and `<snake>_dark.png` (one gallery image per theme). The acceptance of each task lists only what is specific to it.
  Widgets use `Pressable` for interaction and either `TactileSurface` or a `DecoratedBox` with palette fill and `SurfaceScope` shadow recipes (design D3). They do not change `TactileSurface` or `Pressable`.
- Rules for every task: do not touch `docs/brief/`, `.github/workflows/spike-pages.yml`, or `permissions.yaml`. Add no dependency that is
  not already in `pubspec.yaml` (only lane A may edit `pubspec.yaml`). Preserve the behaviour of existing files except where a task names the change.

Commit style: `type(scope): imperative subject`, at most 72 characters. Scopes: `core`, `widgets`, `layout`, `theme`, `test`, `home`,
`app`, `bricks`, `tool`, `ci`, `docs`, `l10n`.

## Parallel lanes and file boundaries

After the prerequisites (P1, A1 to A6) the lanes below run in parallel. Each lane owns different files.

| Lane | Tasks | Owns | Starts when |
|---|---|---|---|
| P prerequisites | P1, A1 to A8 | `test/helpers/*`, `dart_test.yaml`, `.gitignore`, `pubspec.yaml`, `tool/src/ladders.dart`, `tool/src/palette.dart`, `tokens.g.dart`, `motion.dart`, `tool/check.dart`, `test/architecture/*` (A4), ARB core block (P1), inventory and scanner tests | first |
| B action | B1 to B4 | `lib/core/widgets/app_button*.dart`, `app_icon_button.dart`, `app_pill.dart`, tactile tests, their tests and goldens | P1, A1 to A6, A8 |
| C layout | C1 to C5 | `lib/core/layout/{adaptive_builder,page_column,adaptive_grid,action_group,action_group_gap,adaptive_scaffold,adaptive_destination}.dart`, their tests and goldens | P1, A1 to A6, A8 (C4 also needs B2) |
| D input | D1 to D4 | `app_text_field.dart`, `search_field.dart`, `app_segmented.dart`, `app_segment.dart`, `theme_mode_switch.dart`, their tests and goldens | P1, A1 to A6, A8 (D2 also needs D1, B3) |
| E content | E1 to E4 | `app_card.dart`, `app_row.dart`, `section_header.dart`, `app_badge.dart`, their tests and goldens | P1, A1 to A6, A8 |
| F feedback | F1 to F4 | `empty_state.dart`, `error_view.dart`, `loading_view.dart`, `skeleton_block.dart`, `feedback_cell.dart`, `app_toast.dart`, `toast_controller.dart`, `toast_request.dart`, their tests and goldens, `test/app/di/injection_test.dart` (F4) | P1, A1 to A6, A8 (F2 also needs B2) |
| G overlay | G1, G2 | `app_sheet.dart`, `show_app_sheet.dart`, `app_dialog.dart`, `show_app_dialog.dart`, `show_confirm.dart`, their tests and goldens | P1, A1 to A6, A8 (G2 also needs G1, B2, B3, C4, D1) |
| H home | H1 to H7 | `lib/features/home/**`, `lib/app/**`, `test/features/home/**`, `test/app/**`, `test/core/l10n/arb_test.dart` (H6), home ARB block, `test/architecture/*` (H1) | all of B to G that H4 and H5 name |
| I bricks | I1 to I6 | `bricks/**`, `mason.yaml`, `mason-lock.json`, `analysis_options.yaml`, `test/repo_tools/bricks_test.dart` | H7 |
| J create_app | J1 to J5 | `tool/create_app.dart`, `tool/src/create_app_*.dart`, `tool/src/process_runner.dart`, `tool/src/templates.dart`, `test/repo_tools/create_app_test.dart` | J1 can start with P1. J4 and J5 need H7 |
| S sync_core | S1, S2 | `tool/sync_core.dart`, `tool/src/sync_core_*.dart`, `test/repo_tools/sync_core_test.dart` | S1 after A1 to A3. S2 also needs J1 (it uses J1's `process_runner.dart`) |
| K CI | K1, K2 | `.github/workflows/ci.yml`, `test/repo_tools/ci_workflow_test.dart`, `spikes/crew-run/S5-ci-local.md` | I6, J5, S2 |
| Z final | Z1 to Z3 | `README.md`, `test/docs/readme_test.dart`, inventory strict flip, `spikes/crew-run/S5-final.md` | everything |
| M manual | M1 to M4 | none | M1 after Z2. M2 after J5. M3 after Z3. M4 after M3 |

### Shared files (single owner, others read only)

| File | Owner | Rule |
|---|---|---|
| `pubspec.yaml`, `pubspec.lock`, `dart_test.yaml`, `.gitignore`, `tool/src/ladders.dart`, `tool/src/palette.dart`, `lib/core/theme/tokens.g.dart`, `lib/core/theme/tactile/motion.dart` | lane P (A1, A2, A5) | A lane that needs a change asks lane P through its report. `design/tokens.yaml` is not changed by any task. |
| `test/helpers/*` | lane P | read only for others. |
| `test/architecture/architecture_test.dart` | A4, then H1, then Z2 | no one else. |
| `lib/core/l10n/app_en.arb`, `app_id.arb` | P1 (core block), H3 (home block), H6 (removal and rename) | a lane that needs a new string reports it to lane P; no lane appends keys to a file it does not own. After a merge `flutter gen-l10n` runs. |
| `lib/app/di/injection.config.dart`, `*.freezed.dart`, `*.g.dart` | generated | regenerate after each merge, never hand edit. Tasks that regenerate it (F4, H2, H3, H5) are merged one at a time. |
| `lib/app/**` | lane H | read only for others. `ToastController` wiring into `App` is done in H5. |
| `README.md` | Z1 | lanes leave notes in `spikes/crew-run/S5-<task>.md`. |
| `test/core/catalog_blocks_test.dart`, `test/core/core_widget_coverage_test.dart` | A3, strict flip in Z2 | read only for others. |
| `tool/src/process_runner.dart` | J1 | S2 uses it (S2 depends on J1). No second copy. |

### Dependency order

```
P1 ─ A1 ─ A2 ─ A3 ─ A4 ─ A5 ─ A6 ─ A8 ─ (A7 optional)
                           │
      ┌──────┬──────┬──────┼──────┬──────┬──────┐
      B1..B4  C1..C5 D1..D4 E1..E4 F1..F4 G1..G2    S1..S2     J1..J3
      (B2→C4→G2, B2→F2, B3→D2, B3→G2, D1→D2, D1→G2, D3→D4, G1→G2, C1→C5, J1→S2)
      └──────┴──────┴──────┼──────┴──────┴──────┘
                           H1 ─ H2 ─ H3 ─ H4 ─ H5 ─ H6 ─ H7
                           ├─ I1..I6 ─────────┐
                           ├─ J4, J5 ─────────┼─ K1 ─ K2 ─ Z1 ─ Z2 ─ Z3 ─ M1 ─ M2 ─ M3 ─ M4
                           └──────────────────┘
```

## Tasks

- [x] P1. Core strings **[kode]**
  - Depends: none. Owns: `lib/core/l10n/app_en.arb`, `app_id.arb`, generated `app_localizations*.dart`.
  - Add only the keys that do not exist: `clear`, `close`, `dismiss`, `themeModeLabel`, `copied`, `tryAgain`. Do not add `themeSystem`, `themeLight`, `themeDark`, or any `failure<Name>Title`/`Body`
    (all seven pairs and the three theme keys already exist; a duplicate key breaks `flutter gen-l10n`). No new key may end in `Loading` or start with `loading` (`arb_test.dart` demands "…" for those).
    English and Indonesian follow the copy rules of `04` §10 (sentence case, what happened and what to do, no "Oops").
  - Acceptance: `flutter gen-l10n` runs, `arb_test.dart` passes (both files have the same keys), every new key has a non-empty value in both languages, and `grep -c '"themeDark"' lib/core/l10n/app_en.arb` prints 1.
  - Commit: `feat(l10n): add core widget strings in English and Indonesian`
  - _Requirements: 2.4, 6.2_ _Design: Strings, D4_

- [x] A1. Stress harness core **[kode]**
  - Depends: P1. Owns: `test/helpers/surface_host.dart`, `test/helpers/fonts.dart`, `test/helpers/stress.dart`, `test/helpers/stress_test.dart`, `.gitignore` (add `test/**/failures/`).
  - Implement `StressFixture`, `StressData`, `StressProfile` (`quick`, `full`, from `--dart-define=STRESS`), `runStressCase`, `stressTest` (without a11y yet), the case labels,
    `SurfaceHost` (root `SurfaceScope`, real `buildTheme`, localization delegates, bounded constraints), `FlutterError` capture, failure image under `failures/`, and `loadInterFont()` in `fonts.dart`
    (FontLoader `Inter` from `assets/fonts/Inter-Medium.ttf`), called in `setUpAll` by `stressTest` so metrics are those of Inter and not Ahem. The `full` profile groups eight fixtures per (size, input, scale, theme) in one `testWidgets`
    and pumps `SizedBox.shrink()` between fixtures.
  - Tests (`stress_test.dart`): an overflowing widget fails and its message contains size, scale, theme, input mode, and fixture. A flexible `Text` passes. `quick` yields 17 labels, `full` yields exactly 48 groups and 384 labels
    (4 touch sizes + 4 pointer sizes) × 3 scales × 2 themes × 8 fixtures; a stateful probe widget shows no state leaks from one fixture to the next. Default profile is `quick`. The fixture table has the exact `long` (60 words), `longWord` (80 characters), and `bigNumber` (9 digits) values.
    A text widget measured under the harness uses Inter metrics (its `TextPainter` width differs from Ahem's).
  - Acceptance: `flutter test test/helpers` is green. `git check-ignore test/core/widgets/failures/x.png` reports the rule.
  - Commit: `test(helpers): add stress harness with fixtures and quick and full profiles`
  - _Requirements: 9.1–9.7, 9.9, 9.10_ _Design: Stress harness_

- [x] A2. Golden setup, tag, and gate flags **[kode]**
  - Depends: A1. Owns: `dart_test.yaml`, `test/helpers/golden.dart`, `test/helpers/golden_test.dart`, `tool/check.dart`.
  - `dart_test.yaml` declares tags `golden`, `e2e`, and `slow`. `golden.dart`: `loadGoldenFonts` (calls `loadInterFont()` of A1), `goldenTest`/`goldenGallery` (DPR 2, `ThemeData.platform` and `debugDefaultTargetPlatformOverride` macOS, files in `goldens/` next to the test, tag `golden`),
    the non-macOS `fail` with a clear message. `tool/check.dart` passes `--exclude-tags golden,e2e` to `flutter test` and runs `dart format --set-exit-if-changed lib test tool` (not `.`, so `bricks/` templates do not break it).
  - No `app_root_test.dart` is made here: `test/app/app_test.dart` already pumps `App()` with the real router and is the evidence for Req 11.6 until H5 adds the `AdaptiveScaffold` case.
  - Tests (`golden_test.dart`): a tiny gallery with a `Text` creates a golden with `--update-goldens`, compares equal on the next run, and the rendered family is `Inter`, not `Ahem`. Run `flutter test --tags golden` twice
    and compare file hashes of the produced PNGs (Req 11.7). Write the result in `spikes/crew-run/S5-A2.md`. A difference is reported there and in the task report, not hidden by tolerance.
  - Acceptance: `flutter test --tags golden --update-goldens test/helpers/golden_test.dart` writes images, a second `flutter test --tags golden` passes, hashes are equal across two runs, `dart run tool/check.dart` still passes.
  - Commit: `test(helpers): add golden setup, tags, and check.dart flags`
  - _Requirements: 11.1–11.7_ _Design: Golden setup, D12_

- [x] A3. Core widget inventory, catalog scanner, coverage test **[kode]**
  - Depends: A2. Owns: `test/helpers/core_widget_inventory.dart`, `test/core/catalog_blocks_test.dart`, `test/core/core_widget_coverage_test.dart`, and the doc comments (catalog blocks only, no behaviour change) of `lib/core/theme/tactile/surface.dart` and `pressable.dart`.
  - The inventory lists the 25 widgets of Req 1.1 with category, lib path, stress test path, golden paths. The primitives map to `test/core/theme/tactile_surface_stress_test.dart` and `pressable_stress_test.dart` (and their golden tests). `LoadingView` and `SkeletonBlock` both map to `test/core/widgets/loading_view_test.dart` and `loading_view_golden_test.dart` (F3, one gallery). The scanner checks only the inventory's classes (and `State` subclasses are ignored), not every public type in the folder: helper enums and data types (`AppButtonSize`, `ActionGroupGap`, `AppSegment`, `AdaptiveDestination`, `ToastRequest`) and `MinHitArea` and `PressFill` need no block. It checks the inventory classes for one `{@catalog}` block with five non-empty fields and a valid category, and fails if `lib/core/widgets/CATALOG.md` exists. The coverage test checks every inventory widget that already has a stress test file or a golden file: it must have both
    (the stress file contains `stressTest(`, and both light and dark goldens exist). A flag `strict` (false for now) makes both tests also fail when a listed widget file or its tests are missing. Z2 sets `strict` to true. The inventory has no `pending` list: before Z2 the widgets that do not exist yet are skipped by the non-strict flag.
    The two primitives get their `{@catalog}` blocks (category `primitive`) in this task so the scanner passes on the real tree.
  - Tests: the scanners run against string fixtures (missing field, unknown category, no block, CATALOG.md present, partial coverage) and against the real tree.
  - Acceptance: tests green. Removing a field from a fixture block fails the scanner test.
  - Commit: `test(core): add catalog block scanner and widget coverage test`
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 12.5_ _Design: D6, D15, Catalog block format_

- [x] A4. Architecture test: Material ban and reserved names **[kode]**
  - Depends: A3. Owns: `test/architecture/architecture_test.dart`.
  - Remove `_reservedNames` and its check (the five layout names are now allowed). Extend the Material rule: `_noMaterialButtonsInApp` becomes a check that scans `app`, `core/widgets`, `core/layout`, and `features`, with the list extended by `Card`, `ListTile`,
    `AlertDialog`, `Dialog`, `SnackBar`, `PopupMenuButton`, `DropdownButton`, `showDialog`, `showModalBottomSheet` (`Tooltip` stays allowed). Add a `Scaffold` rule: allowed in `core/layout/adaptive_scaffold.dart`, and, as a dated exception that Z2 removes,
    in `app/router/app_shell.dart` (it still holds a `Scaffold` until H5, so the test would be red on the current tree without it). Rewrite the existing test `'Material buttons and reserved names'` (it calls `_noReservedDeclarations`) as `'Material controls'`. Keep every existing rule and
    add a fixture test for each new pattern, including the exception file.
  - Acceptance: the architecture test passes on the current tree (with the exception). A fixture with `showDialog(` in `core/widgets/x.dart` fails. A fixture with `Scaffold(` in `core/widgets/x.dart` fails.
  - Commit: `test(architecture): ban Material visuals in core and allow layout names`
  - _Requirements: 2.1, 2.2, 2.3, 2.10, 7.7_ _Design: Why the Pressable and Material boundary is one rule_

- [x] A5. Missing size, motion, and scrim tokens **[kode]**
  - Depends: A4. Owns: `tool/src/ladders.dart`, `tool/src/palette.dart`, `tool/generate_tokens.dart` (only if the generator needs a call), `lib/core/theme/tokens.g.dart`, `lib/core/theme/tactile/motion.dart`, `test/core/theme/motion_test.dart`, `test/tool/generate_tokens_ladders_test.dart`, `test/tool/generate_tokens_palette_test.dart`.
    Not owned: `design/tokens.yaml` (fixed key set; unknown keys throw `KnobsException`).
  - `ladders.dart` gets a new map `overlayTokens` rendered as a new class `AppOverlay` after `AppLayout` (so `layoutTokens` and the test "AppLayout matches requirement 20.4 exactly" stay unchanged): `dialogDefault` 620, `dialogConfirm` 460, `dialogInfo` 440, `toastHeight` 48,
    `sheetHandleWidth` 36, `sheetHandleHeight` 5, `sheetHandleHitWidth` 88, `sheetHandleHitHeight` 44, `emptyPadding` 44, `dialogRise` 16, `dialogBlur` 4, `backdropBlur` 2 (every value one `double`). `palette.dart` gets a field `scrim` in `AppPalette`
    (light black at 30 % alpha, dark black at 90 %, as an alpha colour literal like `alphaA3`). `motion.dart` (hand written, not generated) gets `d0`, `d400`, `d1000`, `d1200`, `d1500`, `d6000`. Regenerate with `dart run tool/generate_tokens.dart`.
  - Tests updated explicitly: `generate_tokens_ladders_test.dart` gets a new case for `AppOverlay` (the old `AppLayout` case is untouched and still green), `generate_tokens_palette_test.dart` asserts `scrim` in both palettes, `motion_test.dart` asserts the new durations.
    `theme_invariants_test` stays green.
  - Acceptance: `dart run tool/generate_tokens.dart` is deterministic (no diff on a second run, `generate_tokens_determinism_test` green). The listed names exist in `tokens.g.dart` and `motion.dart` with the stated values.
    A grep for `Duration(` in `lib/core/widgets lib/core/layout` finds nothing after the widget tasks.
  - Commit: `feat(theme): add overlay, scrim, and motion tokens`
  - _Requirements: 2.1, 3.8, 6.6, 7.1, 7.2, 7.5_ _Design: D13_

- [x] A6. Accessibility checks in the harness **[kode]**
  - Depends: A5. Owns: `test/helpers/stress.dart`, `test/helpers/stress_test.dart` (lane P only).
  - Add `interactive` and `skipContrastReason` to `stressTest`. For interactive tests the quick profile adds the light 375×812 case and runs `androidTapTargetGuideline`, `labeledTapTargetGuideline`, and `textContrastGuideline` in light and dark with `ensureSemantics`.
    An empty `skipContrastReason` throws at registration.
  - Tests: a button with a 20 px target fails `androidTapTargetGuideline`; an unlabeled tappable fails `labeledTapTargetGuideline`; low contrast text fails `textContrastGuideline`; the same low contrast text passes when `skipContrastReason: 'decorative'`;
    `skipContrastReason: ''` fails.
  - Acceptance: the helper tests are green. Existing `stressTest` call sites need no change.
  - Commit: `test(helpers): add accessibility guideline checks to the stress harness`
  - _Requirements: 10.1, 10.2, 10.3 (harness part)_ _Design: Accessibility checks_

- [x] A8. Compile check of the public API **[kode]**
  - Depends: A5, A6. Owns: `lib/core/_api_stubs.dart` (scratch, deleted before the commit), `spikes/crew-run/S5-A8.md`, and corrections to the signatures in `.kiro/specs/core-widgets-and-templates/design.md`.
  - Write stubs of every public signature in design "Components and interfaces" (classes with `throw UnimplementedError()` bodies, the helper enums, `HueRole` access through `context.hue`, `AppOverlay`, `palette.scrim`, `AppMotion` constants) into the scratch file, run `flutter analyze`,
    and fix every error in the design (a wrong name, type, or missing token) and, if the error is a missing token, in A5's list. Repeat until zero issues. Delete the scratch file.
  - Acceptance: `S5-A8.md` lists the analyzer output before and after, the design edits made, and states that the scratch file is deleted (`git status` shows no `lib/core/_api_stubs.dart`). No widget task starts before this one is merged.
  - Commit: `docs(spikes): record compile check of the core widget API`
  - _Requirements: 2.1 (all later tasks rely on the API)_ _Design: API compile check_

- [x] A7. `stressProperty` with kiri_check **[kode]**
  - Depends: A6. Not blocking any other task. Owns: `test/helpers/stress_property.dart` (exported from `stress.dart`), its test.
  - Spike first (30 minutes at most): can a `kiri_check` `forAll` block drive the same render as `stressTest` through the test binding? Record the answer in `spikes/crew-run/S5-A7.md`. Implement the preferred path if yes, the fallback of the
    design if no, and the seeded `Random` fallback only if both fail. The seed is fixed (`20260126`).
  - Tests: `stressProperty` renders a `Text` widget for 20 generated strings and numbers and passes; a known-overflowing widget makes it fail; the seed makes two runs generate the same first value.
  - Acceptance: the notes file states which path was taken. The README deviation list gets one line in Z1 if a fallback was used.
  - Commit: `test(helpers): add stressProperty on kiri_check with a fixed seed`
  - _Requirements: 9.8_ _Design: stressProperty and kiri_check_

- [ ] B1. Primitives: stress tests and goldens **[kode]**
  - Depends: A6, A8. Owns: `test/core/theme/tactile_surface_stress_test.dart`, `pressable_stress_test.dart`, and their golden tests and goldens. The catalog blocks were added in A3.
  - Stress tests for both (`Pressable` is `interactive: true`). Goldens show every `SurfaceKind` and the pressable states (idle, hover, pressed, focus ring, disabled).
  - Acceptance: existing tactile tests are unchanged and green. Both widgets pass the scanner.
  - Commit: `test(theme): add stress tests and goldens for tactile primitives`
  - _Requirements: 12.1, 12.2, 12.4_ _Design: Primitives_

- [ ] B2. `AppButton` **[kode]** (template W)
  - Depends: A6, A8. Owns: `lib/core/widgets/app_button.dart`, `app_button_size.dart`, tests and goldens.
  - Roles as named constructors, sizes, 16 px leading icon, loading with in-place label that does not resize the button, disabled 60 %, dark primary disabled solid ink-4 with ink-8 text, `destructive` danger-11 text, `destructiveConfirm` solid danger-9,
    press scale 0.97, one-line label. Fill and shadow by role through a `DecoratedBox` (D3); press, hover, focus ring, disabled opacity from `Pressable`.
    Loading (D16): no-op `onPressed` on `Pressable`, wrapped in `IgnorePointer(ignoring: true)`, no dimming. Disabled: `onPressed: null`, `Pressable` applies the 0.6 `Opacity`; the dark primary paints its own solid ink-4 fill and ink-8 text under that opacity.
    `Pressable` is not changed.
  - Acceptance: tests cover each role in light and dark, loading ignores presses (tap and Enter) and keeps the size (compare `tester.getSize` before and after) and has no `Opacity` ancestor of 0.6, disabled has the 0.6 `Opacity`, dark primary disabled paints ink-4 fill and ink-8 text (assert the widget's own colours, not the composite), label never wraps (`longWord` fixture clips with ellipsis), 48 × 48 hit area on touch.
    Golden gallery shows five roles × regular and compact × default, disabled, loading.
  - Commit: `feat(widgets): add AppButton with five roles`
  - _Requirements: 3.1–3.5, 2.5–2.9_ _Design: Action_

- [ ] B3. `AppIconButton` **[kode]** (template W)
  - Depends: A6, A8. Owns: `lib/core/widgets/app_icon_button.dart`, tests and goldens.
  - Acceptance: sizes 22, 28, 44 (other values assert), required tooltip with zero wait, scale 0.92 and 0.94 for 44, icon colour ink-10 to ink-12 on hover (pointer gesture in test), 48 hit area on touch for every size.
  - Commit: `feat(widgets): add AppIconButton`
  - _Requirements: 3.6, 2.5–2.9_ _Design: Action_

- [ ] B4. `AppPill` **[kode]** (template W)
  - Depends: A6, A8. Owns: `lib/core/widgets/app_pill.dart`, tests and goldens.
  - Acceptance: 28 px (36 touch) height, 14 px icon, copy mode shows the tick at once on press and holds it `AppMotion.d1500` (`d1000` icon-only) using `tester.pump(duration)`, reverts at once when `onCopy` returns `false` or throws, never shows a toast
    (`ToastController` is not read), timer cancelled on dispose (no pending timers at test end).
  - Commit: `feat(widgets): add AppPill with copy feedback`
  - _Requirements: 3.7, 3.8, 6.7_ _Design: Action_

- [ ] C1. `AdaptiveBuilder` **[kode]** (template W)
  - Depends: A6, A8. Owns: `lib/core/layout/adaptive_builder.dart`, tests, goldens.
  - Acceptance: the correct builder is chosen at 375, 768, 1200 widths; omitting `tablet` falls back to `mobile`; omitting `desktop` falls back to `tablet ?? mobile`. Golden shows the three builders as three labelled panels.
  - Commit: `feat(layout): add AdaptiveBuilder`
  - _Requirements: 8.7_ _Design: Layout_

- [ ] C2. `PageColumn` **[kode]** (template W)
  - Depends: A6, A8. Owns: `lib/core/layout/page_column.dart`, tests, goldens.
  - Acceptance: `.reading` is 800 wide, `.data` 1200, `.form` 440 (read `AppLayout`), 48 above the first child and 64 below the last, prose capped at about 70 characters in `.reading`, scrolls when taller than the viewport, `SafeArea` on mobile.
  - Commit: `feat(layout): add PageColumn`
  - _Requirements: 8.6, 8.8_ _Design: Layout_

- [ ] C3. `AdaptiveGrid` **[kode]** (template W)
  - Depends: A6, A8. Owns: `lib/core/layout/adaptive_grid.dart`, tests, goldens.
  - Acceptance: columns 1, 2, 3 by window class by default and overridable; no fixed row height (a tall child grows its row); the last row with fewer children keeps column width.
  - Commit: `feat(layout): add AdaptiveGrid`
  - _Requirements: 8.7, 5.7_ _Design: Layout_

- [ ] C4. `ActionGroup` **[kode]** (template W)
  - Depends: B2. Owns: `lib/core/layout/action_group.dart`, `action_group_gap.dart`, tests, goldens.
  - Acceptance: desktop and tablet put the secondary first and the primary at the far right, buttons hug labels; mobile stacks full width with the primary on top; gaps 12 (`page`) and 8 (`overlay`).
  - Commit: `feat(layout): add ActionGroup`
  - _Requirements: 3.9_ _Design: Action_

- [ ] C5. `AdaptiveScaffold` **[kode]** (template W)
  - Depends: C1, A6. Owns: `lib/core/layout/adaptive_scaffold.dart`, `adaptive_destination.dart`, tests, goldens.
  - Desktop rail + floating panel + 52 px strip (title centred, breadcrumbs left, actions right). Tablet collapsed rail. Mobile 56 px top bar and bottom tab bar (active ink-12 on ink-3, inactive ink-10, labels always shown, hairline above). Sticky hairline only after scroll.
  - Acceptance: tests at 390, 834, and 1440 widths find the right regions. Resizing across 768 and 1200 keeps the state of a `StatefulWidget` in the body. The current destination is marked in semantics. The hairline appears only after a scroll notification with
    `pixels > 0`. Goldens at the three sizes in light and dark go in `adaptive_scaffold_golden_test.dart`.
  - Commit: `feat(layout): add AdaptiveScaffold with rail, strip, and tab bar`
  - _Requirements: 8.1–8.4, 8.8_ _Design: Layout_

- [ ] D1. `AppTextField` **[kode]** (template W)
  - Depends: A6, A8. Owns: `lib/core/widgets/app_text_field.dart`, tests, goldens.
  - `label` is optional (`String?`, with `semanticLabel` required when it is null, asserted) and the field has optional `leading` and `trailing` slots in the well, so `SearchField` can compose it (design D1 note, SF9).
  - Acceptance: well style, label above, help text, error with 1 px danger-11 ring and message, focus deepens to ink-4 with the 2 px ring, validation on blur and on submit only (not per key; test types and checks no error appears), field text role
    13/20 pointer and 16/24 touch, visible inside a scrolling parent when `viewInsets` are set (`tester.view.viewInsets`), semantics label and error announced, no label drawn when `label` is null, `leading` and `trailing` rendered.
  - Commit: `feat(widgets): add AppTextField`
  - _Requirements: 4.1–4.3_ _Design: Input_

- [ ] D2. `SearchField` **[kode]** (template W)
  - Depends: D1, B3. Owns: `lib/core/widgets/search_field.dart`, tests, goldens.
  - Composes `AppTextField` (leading search icon, trailing clear `AppIconButton`, no label, semantic label from `hint`).
  - Acceptance: clear button only while text is present; `onChanged` goes through `Debouncer` with 400 ms default (typing three characters within 400 ms calls once, using `tester.pump(Duration)`); raised on mobile light, well elsewhere; pending debounce cancelled on dispose.
  - Commit: `feat(widgets): add SearchField with debounced callback`
  - _Requirements: 4.4_ _Design: Input_

- [ ] D3. `AppSegmented` **[kode]** (template W)
  - Depends: A6, A8. Owns: `lib/core/widgets/app_segmented.dart`, `app_segment.dart`, tests, goldens.
  - Acceptance: one sliding pill with `AppSprings.toggle`, no animation on first build (pill offset equals the selected option at frame 0), instant move under reduced motion, hugs its content, `pageLevel` shows 14 px icons and on mobile 34 px options in a 42 px track,
    selected semantics, each option has a 48 px hit area on touch.
  - Commit: `feat(widgets): add AppSegmented with sliding pill`
  - _Requirements: 4.5, 4.6_ _Design: Input_

- [ ] D4. `ThemeModeSwitch` **[kode]** (template W)
  - Depends: D3. Owns: `lib/core/widgets/theme_mode_switch.dart`, tests, goldens.
  - Acceptance: shows the current `AppSettings.themeMode` as selected, pressing an option calls `AppSettingsCubit.setThemeMode`, the saved mode survives a restart (test: a second cubit on the same `InMemoryKeyValueStore` loads the saved mode, and the switch built on it shows it), labels from `context.l10n`.
  - Commit: `feat(widgets): add ThemeModeSwitch`
  - _Requirements: 4.7, 4.8_ _Design: Input_

- [ ] E1. `AppCard` **[kode]** (template W)
  - Depends: A6, A8. Owns: `lib/core/widgets/app_card.dart`, tests, goldens.
  - Acceptance: `.data` and `.clickable`, padding 24 (20 mobile), radius container, card shadow, children get a new `SurfaceScope` (a descendant reads `SurfaceKind.raised`), `.clickable` scale 0.99 and ink-2 hover fill, semantics label required for `.clickable`.
  - Commit: `feat(widgets): add AppCard`
  - _Requirements: 5.1, 5.2, 5.6, 5.7_ _Design: Content_

- [ ] E2. `AppRow` **[kode]** (template W)
  - Depends: A6, A8. Owns: `lib/core/widgets/app_row.dart`, tests, goldens.
  - Acceptance: no box, min height 38 (44 touch, read from `context.sizes.row`), title ink-12, description ink-11, trailing right-aligned with tabular figures, fill only on hover or press (and only when tappable), title and description clamp at two lines, no fixed height on text.
  - Commit: `feat(widgets): add AppRow`
  - _Requirements: 5.3, 5.6, 5.7_ _Design: Content_

- [ ] E3. `SectionHeader` **[kode]** (template W)
  - Depends: A6, A8. Owns: `lib/core/widgets/section_header.dart`, tests, goldens.
  - Acceptance: title 20/28, 6 px gap, optional description ink-11, actions right on tablet and desktop and under the description at full width on mobile, clamps at two lines.
  - Commit: `feat(widgets): add SectionHeader`
  - _Requirements: 5.4, 5.6, 5.7_ _Design: Content_

- [ ] E4. `AppBadge` **[kode]** (template W)
  - Depends: A6, A8. Owns: `lib/core/widgets/app_badge.dart`, tests, goldens.
  - Acceptance: `.tone(hue)` `context.hue(role).s3` fill with `.s11` text, `.neutral`, 20 px tall (22 touch), one line with ellipsis, no fixed height on the text container beyond the badge token, contrast passes for every `HueRole` in light and dark.
  - Commit: `feat(widgets): add AppBadge`
  - _Requirements: 5.5, 5.6, 5.7_ _Design: Content_

- [ ] F1. `EmptyState` **[kode]** (template W)
  - Depends: A6, A8. Owns: `lib/core/widgets/empty_state.dart`, tests, goldens.
  - Acceptance: bare centred ink-2 panel, 44 px padding, 18 px icon (24 mobile), two caller text lines, long and RTL fixtures do not overflow.
  - Commit: `feat(widgets): add EmptyState`
  - _Requirements: 6.1_ _Design: Feedback_

- [ ] F2. `ErrorView` **[kode]** (template W)
  - Depends: B2. Owns: `lib/core/widgets/error_view.dart`, tests, goldens.
  - Acceptance: one test per `Failure` subtype checks the localized title and body in English and Indonesian; a `Failure` carrying `message: 'SocketException: secret'` never shows that text or a stack trace; one secondary "Try again" button calls the callback.
  - Commit: `feat(widgets): add ErrorView`
  - _Requirements: 6.2, 6.3_ _Design: Feedback_

- [ ] F3. `LoadingView`, `SkeletonBlock`, `feedbackCell` **[kode]** (template W)
  - Depends: A6, A8. Owns: `lib/core/widgets/loading_view.dart`, `skeleton_block.dart`, `feedback_cell.dart`, tests, goldens (one gallery for `LoadingView` and `SkeletonBlock`, the `feedbackCell` test is a behaviour test with no golden of its own).
  - Acceptance: `SkeletonBlock` pulses between a3 and a4 alpha and does not animate under reduced motion (no scheduled frames after the first); `LoadingView` keeps the placeholder's size; with `feedbackCell` three states of different heights share one cell sized to the largest and switching the index does not change the cell size; a hidden `SkeletonBlock` (inactive child) schedules no frames (`TickerMode` per child, D14: `tester.binding.hasScheduledFrame` is false after the first pump when index points to another state), and `pumpAndSettle` completes on a `feedbackCell` whose active child is not `LoadingView`.
  - Commit: `feat(widgets): add LoadingView, SkeletonBlock, and feedbackCell`
  - _Requirements: 6.4, 6.5_ _Design: Feedback, D14_

- [ ] F4. `ToastController` and `AppToast` **[kode]** (template W)
  - Depends: A6, A8. Owns: `lib/core/widgets/app_toast.dart`, `toast_controller.dart`, `toast_request.dart`, tests, goldens, `test/app/di/injection_test.dart` (one added case; H lanes read only after F4). The controller gets `@lazySingleton`. Regenerate DI with `build_runner`. Merge F4 before H2, H3, and H5 (they regenerate the same file).
  - `AppToast({required ToastController controller, required Widget child})`. The host has no `Overlay`: the toast contains no `Tooltip` or `AppIconButton`, and the action is a `Pressable`. Durations from `AppMotion.d6000`.
  - Acceptance: one toast at a time, a new `show` replaces the current one, bottom centre, `AppOverlay.toastHeight` tall, one optional action, dismissed after 6 s (`tester.pump(AppMotion.d6000)`), the timer restarts on replace and is cancelled on dispose, the host renders in a tree with no `Navigator` (no "No Overlay widget found"), the DI test resolves a `ToastController` from `getIt`. The architecture test stays green (one public type per file: `ToastRequest` lives in `toast_request.dart`).
  - Commit: `feat(widgets): add AppToast and ToastController`
  - _Requirements: 6.6, 6.7_ _Design: Feedback_

- [ ] G1. `AppSheet` **[kode]** (template W)
  - Depends: A6, A8. Owns: `lib/core/widgets/app_sheet.dart`, `show_app_sheet.dart`, tests, goldens (mobile sizes only).
  - Acceptance: mobile only, sheet surface top fill (ink-2 in dark), 14 px top radius, 36 × 5 handle with an 88 × 44 hit area, title on the sheet with no header band, buttons under content, rises in 320 ms and sinks in 200 ms, dismisses by dragging down
    (past one third or a fling), reduced motion uses a 150–200 ms crossfade, no Material sheet or dialog API used (architecture test).
  - Commit: `feat(widgets): add AppSheet`
  - _Requirements: 7.5, 7.6, 7.7_ _Design: Overlay_

- [ ] G2. `AppDialog` and `showConfirm` **[kode]** (template W)
  - Depends: G1, B2, B3, C4, D1. Owns: `lib/core/widgets/app_dialog.dart`, `show_app_dialog.dart`, `show_confirm.dart`, tests, goldens.
  - Acceptance: widths 620, 460, 440 (`AppOverlay`); hairlines between header, body, footer; Cancel left, confirm right; no "×" when there is a footer; backdrop `palette.scrim` (black 30 % light and 90 % dark) with 2 px blur; no `barrierColor` literal; first field focused on open; enter 240 ms, exit 200 ms; reduced motion crossfade;
    `showConfirm` returns `true` only on confirm and `false` on cancel or barrier tap; on a mobile window `AppDialog` and `showConfirm` show an `AppSheet`.
  - Commit: `feat(widgets): add AppDialog and showConfirm`
  - _Requirements: 7.1–7.4, 7.6, 7.7_ _Design: Overlay_

- [ ] H1. Home domain layer and architecture test update **[kode]**
  - Depends: A4 (no widget task is needed). Owns: `lib/features/home/domain/**`, `test/features/home/domain/**`, `test/architecture/architecture_test.dart` (the "lib/features does not exist" case).
  - `HomeItem` (freezed), `HomeRepository`, `GetHomeItemsUseCase` returning `Either<Failure, List<HomeItem>>`, with unit tests (mocktail repository, success and failure). The architecture test now asserts that `lib/features/home` has `domain` (and `data`, `presentation` are checked in Z2 when they all exist) and the layer rules apply to `features/`. The domain imports only allowed packages.
  - Acceptance: architecture test green, use case tests green.
  - Commit: `feat(home): add domain layer and let the architecture test cover features`
  - _Requirements: 13.1, 13.2, 13.11, 14.1_ _Design: Home feature_

- [ ] H2. Home data layer and mapper property test **[kode]**
  - Depends: H1. Owns: `lib/features/home/data/**`, `test/features/home/data/**`.
  - Model, local data source (static list), mapper as extension methods, repository implementation using `guardRepository`.
  - Tests: mapper example, repository success and thrown-exception paths with a `mocktail` data source, and one `kiri_check` property that the mapper preserves `id`, `title`, `subtitle`, and `value` for any generated model.
  - Acceptance: tests green. Registration annotations present (`@lazySingleton`).
  - Commit: `feat(home): add data layer with local data source and mapper`
  - _Requirements: 13.3, 14.1, 14.6_ _Design: Home feature, Home tests_

- [ ] H3. Home strings and cubit **[kode]**
  - Depends: H2, P1. Owns: home block in `app_en.arb` and `app_id.arb`, `lib/features/home/presentation/bloc/**`, `test/features/home/presentation/home_cubit_test.dart`.
  - Strings: `homeTitle`, `homeSectionTitle`, `homeSectionDescription`, `homeEmptyTitle`, `homeEmptyBody`, `homePrimaryAction`, `homeSecondaryAction`, `homeItem*` from the static data, English and Indonesian, `04` §10 copy rules.
    `HomeState` union `initial | loading | success | empty | failure`, `HomeCubit.load()`.
  - Tests: `bloc_test` for `initial → loading → success`, `loading → empty`, `loading → failure`.
  - Acceptance: `arb_test.dart` green, bloc tests green.
  - Commit: `feat(home): add home cubit and strings`
  - _Requirements: 13.4, 13.8, 14.2_ _Design: Home feature_

- [ ] H4. Home view, page, feature widget **[kode]**
  - Depends: H3, B2, C2, C4, C5, D3, D4, E2, E3, E4, F1, F2, F3. Owns: `lib/features/home/presentation/pages/**`, `widgets/**`, `test/features/home/presentation/home_view_test.dart`, `home_view_stress_test.dart`.
  - `HomePage` provides the cubit and carries `{@screen summary: ...}`. `HomeView` renders `PageColumn.data` with `SectionHeader`, `AppRow` list, `ActionGroup` with `AppButton.secondary` and `AppButton.primary`, `ThemeModeSwitch`, `LanguageSwitch`, and the four states through `feedbackCell`.
    Feature widgets: `HomeSummaryTile` (uses `AppBadge`) and `LanguageSwitch` (an `AppSegmented<AppLocale>` over `AppSettingsCubit.setLocale`, strings `localeTitle`, `localeSystem`, `localeEnglish`, `localeIndonesian`; the language picker of the placeholder is kept). No Material visual widgets, no business logic in widgets.
  - Tests: widget test with a mock cubit renders all four non-initial states; "Try again" calls `load`; tapping an option of `LanguageSwitch` calls `setLocale`; `stressTest` with `interactive: true`; `pumpAndSettle` completes in every non-loading state.
  - Acceptance: tests green, architecture test green.
  - Commit: `feat(home): add home page and view`
  - _Requirements: 13.5, 13.6, 13.8, 13.9, 14.3, 14.4_ _Design: Home feature_

- [ ] H5. Route, DI, shell, toast host, FEATURE.md **[kode]**
  - Depends: H4, F4, C5. Owns: `lib/app/router/{app_shell,routes,route_names}.dart`, `lib/app/app.dart`, `lib/features/home/FEATURE.md`, `test/app/**` except placeholder tests, `test/features/home/home_route_test.dart`.
  - `AppShell` uses `AdaptiveScaffold` with the Home destination and the `TODO(core-widgets-and-templates)` is removed. `routes.dart` points the root route to `HomePage`. DI registrations regenerated. `App` wraps the router child in `AppToast(controller: getIt<ToastController>(), ...)` through `MaterialApp.router(builder:)`.
    `FEATURE.md` states `source: local` and lists files.
  - Tests: route test (the route builds `HomePage`, the shell shows the destination), `app_test.dart` updated (it finds `PlaceholderPage` today: it now finds `HomePage`; the case "a saved Dark and Indonesia survive a restart" is kept and taps `localeIndonesian` on the home page; one new case finds exactly one `AdaptiveScaffold` in `App()` at 390×844, which is the Req 11.6 root test), and a toast shown through `ToastController` appears.
  - Acceptance: `flutter test` green. `grep -rn "TODO(core-widgets-and-templates)" lib` prints nothing.
  - Commit: `feat(app): route home through AdaptiveScaffold and register DI`
  - _Requirements: 8.5, 13.1, 13.7_ _Design: Home feature_

- [ ] H6. Remove the placeholder and the connection check **[kode]**
  - Depends: H5. Owns: deletion of `lib/app/placeholder/`, `test/app/placeholder/`, `checkConnection*` ARB keys, `Env.connectionCheckUrl`, `test/app/env_test.dart` (the `connectionCheckUrl` line), `test/core/l10n/arb_test.dart` (replace the `checkConnection` / `Check connection` / `Periksa koneksi` cases with `themeDark` ("Dark", "Gelap") and `tryAgain`), `placeholderTitle` renamed `appTitle` in ARB and `app.dart`, `SEAM(core-widgets-and-templates)` markers. The `locale*` keys stay.
  - Acceptance: `grep -rniE "PlaceholderPage|ConnectionCheck|checkConnection|connectionCheckUrl|SEAM\(core-widgets" lib test` prints nothing. `grep -n localeIndonesian lib/core/l10n/app_en.arb` still finds the key and the restart test still passes. `dart run build_runner build -d` regenerates DI without the cubit. `find . -name integration_test` prints nothing. Tests green.
  - Commit: `refactor(app): remove placeholder page and connection check`
  - _Requirements: 13.10, 14.7_ _Design: D9, D10_

- [ ] H7. Home and shell goldens **[kode]**
  - Depends: H6. Owns: `test/features/home/presentation/home_view_golden_test.dart`, `test/app/shell_golden_test.dart`, their `goldens/`.
  - `pumpInShell` test helper (inside the test file, not in `test/helpers`) wraps `HomeView` in the same `AdaptiveScaffold`. Goldens: `HomeView` at 390×844, 834×1194, 1440×900 in light and dark (6 images); the shell with `Home` at the same three sizes in light and dark (6 images).
  - Acceptance: `flutter test --tags golden` passes twice with equal hashes.
  - Commit: `test(home): add home view and shell goldens`
  - _Requirements: 12.3, 14.5_ _Design: Home tests_

- [ ] I1. `mason.yaml` and the `feature` brick **[kode]**
  - Depends: H7. Owns: `mason.yaml`, `mason-lock.json`, `bricks/feature/**`, `analysis_options.yaml` (add `bricks/**` to `analyzer: exclude:`), `test/repo_tools/bricks_test.dart` (created here with the harness and the first case, `@Timeout(Duration(minutes: 10))` and `@Tags(['slow'])`).
  - `bricks_test.dart` makes one shared temp copy of the skeleton, runs `mason get`, and runs a `makeBrick(name, vars)` helper. Skips with a message when `mason` is missing or when the temporary `flutter pub get` fails for lack of network. The `feature` brick is derived from `lib/features/home` with the `03` §5 file names. Template files end in `.dart` and hold mustache, so they are excluded from analysis here and from `dart format` by A2's `lib test tool` arguments.
  - Acceptance: `dart run tool/check.dart` (format, analyze) is green with `bricks/feature/**` present. `mason make feature --name sample_thing` into the temp copy, then `build_runner`, `flutter analyze` (zero issues), and the generated tests pass.
  - Commit: `feat(bricks): add mason setup and the feature brick`
  - _Requirements: 15.1, 15.2, 15.5, 15.6_ _Design: Bricks_

- [ ] I2. `page` brick **[kode]**
  - Depends: I1. Owns: `bricks/page/**`, a case in `bricks_test.dart`.
  - Acceptance: generates `*_page.dart` and `*_view.dart` with a `{@screen summary: ...}` block and a widget test; analysis and the generated test pass.
  - Commit: `feat(bricks): add the page brick`
  - _Requirements: 15.3, 15.5, 15.6_ _Design: Bricks_

- [ ] I3. `bloc` brick **[kode]**
  - Depends: I2. Owns: `bricks/bloc/**`, a case in `bricks_test.dart`.
  - Acceptance: generates `*_bloc.dart`, `*_event.dart`, `*_state.dart` with the loading union of `03` §5 and a `bloc_test`; analysis and the generated test pass.
  - Commit: `feat(bricks): add the bloc brick`
  - _Requirements: 15.3, 15.5, 15.6_ _Design: Bricks_

- [ ] I4. `usecase` brick **[kode]**
  - Depends: I3. Owns: `bricks/usecase/**`, a case in `bricks_test.dart`.
  - Acceptance: generates `*_usecase.dart` implementing the core `UseCase` and a unit test; analysis and the generated test pass.
  - Commit: `feat(bricks): add the usecase brick`
  - _Requirements: 15.4, 15.5, 15.6_ _Design: Bricks_

- [ ] I5. `core_widget` brick **[kode]**
  - Depends: I4. Owns: `bricks/core_widget/**`, a case in `bricks_test.dart`.
  - Acceptance: generates `lib/core/widgets/<name>.dart` with a Catalog_Block, a test with `stressTest`, and a golden test (golden file created by running `--update-goldens` on the temp copy in the test's second phase, which is tagged `golden` and not part of the default gate). The scanner test passes on the generated widget.
  - Commit: `feat(bricks): add the core_widget brick`
  - _Requirements: 15.4, 15.5, 15.6_ _Design: Bricks_

- [ ] I6. Bricks verification test and pin **[kode]**
  - Depends: I5. Owns: `test/repo_tools/bricks_test.dart` (final shape), `mason-lock.json`.
  - One test runs all five bricks in the temp copy and checks generated file names and the three checks (build_runner, analyze, generated tests). It skips with a clear message only when `mason` is not on `PATH` or the temporary `pub get` fails for lack of network. The pinned `mason_cli` version is read from one constant used by the README and CI.
  - Acceptance: test passes on this Mac with `mason` 0.1.4; `dart run tool/check.dart` stays green.
  - Commit: `test(bricks): verify all five bricks with mason make`
  - _Requirements: 15.6, 15.7_ _Design: Bricks_

- [ ] J1. `create_app` core: validation, copy filter, text replacement **[kode]**
  - Depends: A1. Owns: `tool/src/create_app_core.dart`, `tool/src/process_runner.dart`, `test/repo_tools/create_app_test.dart`.
  - Pure functions `validateName`, `shouldCopy`, `replaceInText`. Tests (no Flutter needed): valid and invalid names (`Bad-Name`, `1app`, `class`, empty), the copy exclusion list (`build/`, `.dart_tool/`, `*.iml`, `.idea/`, `pubspec.lock`, `test/repo_tools/`), `package:skeleton/` replacement, permission strings untouched.
  - Acceptance: `flutter test test/repo_tools/create_app_test.dart` green.
  - Commit: `feat(tool): add create_app core functions with tests`
  - _Requirements: 16.2, 16.3, 16.12_ _Design: create_app_

- [ ] J2. `create_app` copy and platform identifiers **[kode]**
  - Depends: J1. Owns: `tool/create_app.dart`, `tool/src/create_app_platform.dart`, cases in `create_app_test.dart`.
  - CLI parsing for all flags, copy to `<out>/<dir>` as real files, platform id replacement (Android `applicationId` and `namespace`, iOS and macOS `PRODUCT_BUNDLE_IDENTIFIER`, Linux `APPLICATION_ID`, Windows `BINARY_NAME`, web manifest and title), display name, `package: skeleton` in each `bricks/*/brick.yaml`, and a rewrite of `test/platform/web_index_test.dart` literals (`<title>`, `"name"`, `"short_name"`) to the display name so the copied test passes.
  - Acceptance: run into a temp folder from this repo. `grep` of the result shows no `skeleton` in the replaced fields (including `brick.yaml`), `INTERNET`, the `https` queries entry, and `com.apple.security.network.client` are present, `flutter test test/platform/web_index_test.dart` passes in the copy, and an existing target makes the script exit 64 with no file written.
  - Commit: `feat(tool): copy skeleton and set platform identifiers in create_app`
  - _Requirements: 16.1, 16.2, 16.3, 16.4, 16.5_ _Design: create_app_

- [ ] J3. `create_app` fallback and template reset **[kode]**
  - Depends: J2. Owns: `tool/src/templates.dart`, `tool/src/create_app_platform.dart` (fallback part), cases in `create_app_test.dart`.
  - `flutter create` fallback through the injected runner when a pattern is missing, then permission and entitlement re-application. Reset of `api/openapi.yaml`, `api/api_map.yaml`, `api/CHANGELOG.md`, `.kiro/steering/product.md` when they exist and skip when not.
  - Acceptance: unit tests with a fixture missing the pattern call the runner with the right `flutter create` arguments and keep the permissions; absent files are skipped without error, present ones are reset.
  - Commit: `feat(tool): add flutter create fallback and template reset to create_app`
  - _Requirements: 16.5, 16.6, 16.7_ _Design: create_app_

- [ ] J4. `create_app --clean` **[kode]**
  - Depends: J3, H7. Owns: `tool/src/create_app_clean.dart`, cases in `create_app_test.dart`, an `e2e` test in `test/repo_tools/create_app_e2e_test.dart` (`@Timeout(Duration(minutes: 10))`).
  - Removes the Home_Feature, its tests, goldens, route, route name, DI registrations, and `home*` strings, and generates the minimal `EmptyState` page (`lib/app/home_placeholder_page.dart`, strings `appHomeEmptyTitle` and `appHomeEmptyBody` in both ARB files, with a test) so the app still has a route.
    It also handles every other test that names home, one explicit step and one test each: delete `test/features/home/**` and `test/app/shell_golden_test.dart` with its goldens; rewrite `test/app/router/routes_test.dart` and `test/app/app_test.dart` for the minimal page (the persistence case drives `AppSettingsCubit` directly, because `LanguageSwitch` is gone);
    delete the `home` destination label key use in `app_shell.dart` (a single destination built from the minimal page title). The Z2 rule "home has three layers" is conditional on `lib/features/home` existing, so it holds in the clean app.
  - Acceptance: `dart run tool/create_app.dart clean_app --out /tmp/x --clean` then `flutter analyze` (zero issues) and `flutter test --exclude-tags golden` pass in `/tmp/x/clean_app`, and `grep -rn "features/home\|PlaceholderPage\|homeTitle" /tmp/x/clean_app/lib /tmp/x/clean_app/test` prints nothing. The e2e test runs this with `--tags e2e`.
  - Commit: `feat(tool): add --clean to create_app`
  - _Requirements: 16.8, 16.11_ _Design: create_app_

- [ ] J5. `create_app` git, pub get, build_runner, next steps **[kode]**
  - Depends: J4. Owns: `tool/create_app.dart` (final steps), `create_app_e2e_test.dart` (`@Timeout(Duration(minutes: 10))`, tag `e2e`), a case in `create_app_test.dart`, and the copy-time rewrite of `test/docs/readme_test.dart` in the generated app.
  - `git init` and a first commit with `git -c user.name=... -c user.email=... commit` (fixed values) when outside a work tree, `flutter pub get`, `dart run build_runner build -d`, token generation, printed next steps with no `kit` mention.
  - Acceptance: the e2e test runs the script without `--clean` into a temp folder and the app passes `flutter analyze` and `flutter test --exclude-tags golden` (including `web_index_test` and `readme_test`). The printed next steps contain no `kit `. In an existing git work tree no new repository is created. A unit test with a fake runner asserts the commit arguments carry the identity (so a machine with no git identity works).
  - Commit: `feat(tool): finish create_app with git init, pub get, and next steps`
  - _Requirements: 16.9, 16.10, 16.11_ _Design: create_app_

- [ ] S1. `sync_core` plan and conflicts **[kode]**
  - Depends: A1 to A3 (S1 only; S2 below also needs J1). Owns: `tool/src/sync_core_core.dart`, `test/repo_tools/sync_core_test.dart`.
  - Pure `plan(from, to)`: files of `lib/core/widgets/**` and `lib/core/layout/**` missing in `to`, with their tests and goldens, conflict detection (both exist, different bytes), import rewrite, package detection, and a diff printer.
  - Acceptance: tests on two temp fixture projects cover copy list, import rewrite, packages to add, identical-file skip, and a conflict that makes the plan fail before anything is written.
  - Commit: `feat(tool): add sync_core planning with conflict detection`
  - _Requirements: 17.2, 17.3, 17.5_ _Design: sync_core_

- [ ] S2. `sync_core` execution, dry run, tests **[kode]**
  - Depends: S1, J1. Owns: `tool/sync_core.dart`, cases in `sync_core_test.dart`. Uses `tool/src/process_runner.dart` of J1 (no copy).
  - CLI, `--dry-run`, writing files, adding packages to `pubspec.yaml` and running `flutter pub get` through the injected runner, running the copied tests, and `kit` only when it exists in `--to`.
    `shortcut:` the inventory file of the target is not updated (comment in the code and a README line in Z1), upgrade when `kit` exists.
  - Acceptance: tests cover `--dry-run` (nothing written, output lists files and packages), the real copy, the added package line, the conflict stop (exit 1, nothing written), and the `kit` skip message.
  - Commit: `feat(tool): add sync_core command with dry run`
  - _Requirements: 17.1, 17.4, 17.5, 17.6, 17.7, 17.8_ _Design: sync_core_

- [ ] K1. CI workflow and its test **[kode]**
  - Depends: I6, J5, S2. Owns: `.github/workflows/ci.yml`, `test/repo_tools/ci_workflow_test.dart`.
  - `ci.yml` as in the design: triggers with path filters, `skeleton` job (Flutter version from `skeleton/.fvmrc` through `jq`, pub cache, `pub get`, `build_runner`, `dart run tool/generate_tokens.dart`, `git diff --exit-code`, `analyze --fatal-infos`, `test --exclude-tags golden --dart-define=STRESS=full`, artifact on failure,
    `flutter build web --release`), `mason_cli` install at the pinned version, and the `template` job. No `kit` steps, no golden comparison. The file `spike-pages.yml` is not touched.
  - Tests: parse with the `yaml` package and assert the jobs, triggers, path filters, the version source, the pinned mason version, the absence of `kit`, the generator step before `git diff`, and that `.github/workflows/spike-pages.yml` has the SHA-256 `ca14a184c8ff110b4e6d41d3554c97d074fa536a4010c1d84aafbeaa5d3a46d5` (constant in the test).
  - Acceptance: test green. `actionlint .github/workflows/ci.yml` passes when `actionlint` is installed (the report says whether it was).
  - Commit: `ci: add skeleton and template workflow`
  - _Requirements: 18.1–18.8_ _Design: CI_

- [ ] K2. Run every CI step locally in a clean clone **[kode]**
  - Depends: K1. Owns: `spikes/crew-run/S5-ci-local.md`.
  - Clone the repository to a temp folder (`git clone` of the working tree state through a copy of the tracked and new files), run each `run` step of `ci.yml` in order (replace `ubuntu` specifics with the Mac equivalents and say so), including `create_app ci_app --out /tmp` and the template job steps.
  - Acceptance: the report lists each command, its exit code, and its duration, states "no hosted run" and that Linux-only differences were not exercised. Any failure is fixed in K1 and K2 is rerun.
  - Commit: `docs(spikes): record local run of every CI step`
  - _Requirements: 18.9_ _Design: CI, D11_

- [ ] Z1. README and documentation **[dok]**
  - Depends: K2, H7, J5, S2, I6. Owns: `README.md`, `test/docs/readme_test.dart`.
  - Document: core widgets by category with path and one line each; stress profiles and commands (`flutter test`, `flutter test --dart-define=STRESS=full`); golden commands; Brick commands and the pinned `mason_cli` version; `create_app` and `sync_core` usage;
    the replaced sentence "There is no golden test and no stress harness"; "all test types" definition and the absence of `integration_test/`; the removal of "Check connection" with the note that the Release_APK network proof (skeleton-foundation 3.5 and 24.9) was obtained before; deviations from `03`, `04`, `02`, `10`
    (including the `stressProperty` path taken in A7, the `home` shell split of design R5, the goldens-only-on-this-Mac rule, the `LanguageSwitch` kept on home, the toast host taking the controller, the stress `full` profile numbers 48 and 384, and that `sync_core` does not update the target's inventory). Update `test/docs/readme_test.dart` for the new content.
    The "every path named in the README exists" rule checks only paths inside `skeleton/`; `tool/create_app.dart` and `tool/sync_core.dart` are at the repository root and are checked by a separate assertion that runs only when `../tool` exists (so the rule also holds in a generated app).
  - Acceptance: readme test green. Every path named in the README that is inside `skeleton/` exists.
  - Commit: `docs(skeleton): document core widgets, tests, bricks, and tools`
  - _Requirements: 1.6, 11.8, 14.7, 15.8, 19.5_ _Design: all_

- [ ] Z2. Strict inventory and final architecture checks **[kode]**
  - Depends: Z1. Owns: `test/helpers/core_widget_inventory.dart` (strict flag), `test/core/catalog_blocks_test.dart`, `test/core/core_widget_coverage_test.dart`, `test/architecture/architecture_test.dart`.
  - Turn on `strict`, assert all 25 widgets exist with a catalog block, a stress test, and light and dark goldens, remove the dated `Scaffold` exception for `app/router/app_shell.dart` (and assert that no exception entry is left), and assert `lib/features/home` has the three layers when it exists (`if (Directory('lib/features/home').existsSync())`, so the rule also holds in a `--clean` app).
  - Acceptance: tests green. Removing one golden file makes the coverage test fail (checked once by hand and noted in the commit body).
  - Commit: `test(core): make widget inventory and coverage checks strict`
  - _Requirements: 1.3, 1.4, 12.5, 13.11_ _Design: D6_

- [ ] Z3. Final gate and report **[kode]**
  - Depends: Z2. Owns: `spikes/crew-run/S5-final.md`.
  - Run: `dart run tool/check.dart`; `flutter test --tags golden` (twice, hashes equal); `flutter test --dart-define=STRESS=full --exclude-tags golden` (record the run time); `flutter test --tags e2e`; the create_app output with and without `--clean` analysed and tested; the bricks test. Run `git diff --stat origin/main -- docs/brief` and record that it is empty (Req 19.6). Write the report with evidence for each item of Req 19.7 and list what is
    not verified (Android and iOS builds, hosted CI).
  - Acceptance: every command exits 0 and the report lists exit codes and times. Anything not run is named with the reason.
  - Commit: `docs(spikes): add final verification report for core widgets and templates`
  - _Requirements: 16.11, 19.1, 19.2, 19.3, 19.4, 19.6, 19.7_ _Design: Testing strategy_

- [ ] M1. Review goldens in light and dark at 2× **[manual]**
  - Depends: Z2. For the user.
  - Open each `goldens/*_light.png` and `*_dark.png` (25 widgets, 6 `HomeView`, 6 shell) at 2× zoom. Check fonts (Inter, not a fallback), 0.5 px hairlines, shadows, and every variant and state in the gallery. Write the findings in `spikes/crew-run/S5-golden-review.md`. Findings become
    follow-up tasks and do not reopen finished ones.
  - Acceptance: the user states "goldens approved" or lists defects. Includes the shell and each widget in light and dark.
  - _Requirements: 12.6_

- [ ] M2. Run `create_app` and the app on web and macOS **[manual]**
  - Depends: J5. For the user.
  - Run `dart run tool/create_app.dart my_app --out /tmp` (and once with `--clean`), then in the result `flutter run -d chrome` and `flutter run -d macos`. Check theme switching, the list, the dialog and sheet path (resize below 768), and the shell at the three window classes. Android and iOS: try `flutter build apk --debug` and an iOS simulator
    run and note the cause if a toolchain is missing (Android SDK licences are a user action).
  - Acceptance: a note under `spikes/crew-run/S5-manual-run.md` with what ran on web and macOS and the cause of anything that did not run.
  - _Requirements: 16.13, 19.7_

- [ ] M3. Push **[manual]**
  - Depends: Z3, M1. For the user.
  - Review `git status` (no lock or setting files from `.kiro/settings`), then push the branch. The agents never push.
  - Acceptance: the commits are on GitHub.

- [ ] M4. Check the first hosted CI run **[manual]**
  - Depends: M3. For the user. Billing for GitHub Actions is fixed.
  - Open the Actions tab and read the `ci` run: `skeleton` job and `template` job. Record the result (green or the failing step and log excerpt) in `spikes/crew-run/S5-hosted-ci.md`. A failure opens a follow-up fix task. It does not reopen finished tasks.
  - Acceptance: the note exists with the run URL and result.
  - _Requirements: 18.10_
