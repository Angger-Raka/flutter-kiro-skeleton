# Design Document: core-widgets-and-templates

## Overview

This spec turns the `skeleton/` foundation into a usable Phase 1 skeleton. It adds the 23 core widgets of `03` §6.1
that do not exist yet (the two primitives `TactileSurface` and `Pressable` already exist and only gain a catalog
block, a stress test, and goldens), the stress and accessibility harness, the golden setup, the `home` example
feature, the five Mason bricks, `tool/create_app.dart`, `tool/sync_core.dart`, and `.github/workflows/ci.yml`.

Everything builds on what `skeleton-foundation` delivered and does not rewrite it: `SurfaceScope`, `TactileSurface`,
`Pressable` (with `MinHitArea` and `PressFill`), `AppMotion`, `AppSprings`, `context.text`, `context.surface`,
`context.sizes`, `context.reduceMotion`, `context.windowClass`, `context.inputMode`, the generated tokens
(`AppSpace`, `AppRadius`, `AppStroke`, `AppSizeSet`, `AppLayout`, `AppPalette`, `HueScale`), `AppSettingsCubit`,
`Failure`, `ApiClient`, `Debouncer`, and the two ARB files. Code is Dart on Flutter 3.44.8 / Dart 3.12.2.

This spec is not a property-based spec. `kiri_check` is used only where requirements name it: `stressProperty`
(9.8), one mapper or use case property of `home` (14.6), and nothing else. Every other test is an example test.

### Out of scope

`kit` and everything it generates (`CATALOG.md`, `SCREENS.md`), hooks, skills, steering, agents, `deploy-pages.yml`,
the app-only widgets of `03` §6.2, the stretch widgets, and `docs/brief/`. The existing `spike-pages.yml` is not
touched.

---

## Decisions

Each decision has an id that tasks and the spec check refer to.

| Id | Decision | Reason |
|---|---|---|
| D1 | Widgets are flat: one public class per file in `lib/core/widgets/` (layout widgets in `lib/core/layout/`), file name is the snake_case class name. A public enum or typedef that a widget needs gets its own file (for example `app_button_size.dart`). | The existing architecture rule 22.3 allows one public type per file. No allowlist entry is added. |
| D2 | Component APIs prefer named constructors for roles and variants (`AppButton.primary`, `AppCard.clickable`, `AppBadge.tone`) and small enums only for sizes. | Matches `03` §6.1 wording and keeps call sites short for agents. |
| D3 | Every widget gets press, hover, focus ring, disabled state, and the 48 px hit area from `Pressable`. A widget uses `TactileSurface` where a `SurfaceKind` fits (card, well, sheet, overlay). Where a role needs a fill or a shadow that no `SurfaceKind` gives (primary, secondary, toggle pill, badge, skeleton), the widget uses a `DecoratedBox` whose fill comes from `context.surface` or the palette and whose shadow comes from `SurfaceScope` recipes (`button()`, `primary()`, `toggle()`, `badge(hue)`). No widget builds its own press, hover, focus ring, or disabled opacity. `TactileSurface` and `Pressable` are not changed. | Req 2.10. R4 BL3: `TactileSurface` takes only `kind`, `radius`, `padding` and cannot give per-role fill or shadow. Option (b) keeps the reviewed foundation code unchanged and keeps one press implementation. |
| D4 | User-visible strings come from the caller, except a short fixed set added to the ARB files (Section "Strings"). | Req 2.4. Widgets stay reusable in any app. |
| D5 | `test/helpers/` holds the shared test code (`stress.dart`, `golden.dart`, `surface_host.dart`, `core_widget_inventory.dart`). Only lane P (tasks P1 and A1 to A7) edits it. Other lanes read it. | Gives parallel lanes a stable base and a single owner. |
| D6 | A test inventory file lists the 25 widgets with category, lib path, stress test path, and golden paths. The catalog scanner (WID002 stand-in) and the coverage test (UI005 stand-in) read it. Both tests check the widgets whose lib file exists. A strict "all 25 exist" test is enabled by the last widget task. | Lets each lane land alone without red tests, and still ends strict. |
| D7 | Tests of `tool/create_app.dart` and `tool/sync_core.dart` live in `skeleton/test/repo_tools/`. They load the pure functions by a relative import of `../../../tool/src/...` and run the scripts as sub-processes for end-to-end checks. `create_app` excludes `test/repo_tools/` from the copy. | The scripts live at the repo root (`02`), the tests must run with the skeleton's `flutter test`, and an app must not carry tests of a tool it does not have. |
| D8 | The root `tool/` scripts use only `dart:` libraries. There is no root `pubspec.yaml`. They edit `pubspec.yaml` of targets as text. | `dart run tool/create_app.dart` must work from a clean clone without `pub get`. |
| D9 | `PlaceholderPage`, `ConnectionCheckCubit`, its state, its tests, its DI registration, the `checkConnection*` strings, and `Env.connectionCheckUrl` are deleted. The `placeholderTitle` ARB key is renamed `appTitle`. | User answer Q6=A. Nothing else uses them. The network proof of the Release_APK is already recorded as proven (`skeleton-foundation` 3.5 and 24.9), and this spec retires those two criteria. |
| D10 | There is no `integration_test/` folder. "All test types" is unit, bloc, widget, stress, a11y, golden, and property-based. | User answer Q5=B. |
| D11 | CI is verified locally and the first hosted run is a manual user step (task `[manual]`). It does not block code tasks. | User answer Q2. |
| D12 | Goldens are made and compared only on this Mac. The tag is `golden`. `dart_test.yaml` declares it. CI excludes it. A non-macOS host fails a golden test with a clear message. | Req 11, `04` §12. |
| D13 | Tokens needed by widgets but missing are added by generator code in `skeleton/tool/src/`, not by `design/tokens.yaml` (the YAML has a fixed key set and `knobs.dart` rejects unknown keys) and not as literals in widgets. Layout-like sizes go into a new map `overlayTokens` in `tool/src/ladders.dart`, rendered as a new class `AppOverlay` (so `layoutTokens` and the test "AppLayout matches requirement 20.4 exactly" stay unchanged). The scrim colour becomes a palette field `scrim` (light: black 30 %, dark: black 90 %) emitted by `tool/src/palette.dart`. Durations `d1000`, `d1500`, `d6000` are added by hand to `lib/core/theme/tactile/motion.dart` (that file is hand written, not generated) together with `d0`, `d400`, `d1200`. Every value is a single `double`; a pair is two names. Lane P owns this in task A5 and updates the generator tests explicitly. If a lane finds a missing token later, it asks lane P. | Architecture rule 22.4 forbids `Duration(`, `Colors.`, `Color(0x`, `Color.fromARGB(`, `Curves.`, `Interval(`, `Cubic(` outside `core/theme`. R4 BL1 and BL2: the AC of B4, F4, G2 need 1.0 s, 1.5 s, 6 s and a scrim colour that no token gave. |
| D14 | The "shared cell" of Req 6.5 is a function `feedbackCell` (an `IndexedStack`), not a widget class. Each child is wrapped in `TickerMode(enabled: i == index)` so a hidden `SkeletonBlock` schedules no frames. | An `IndexedStack` is sized by its largest child, which is the behaviour required, but it does not mute the tickers of hidden children (R4 SF4). A function needs no catalog block and does not add a 26th widget. |
| D15 | Helper types get their own files and need no catalog block: `app_button_size.dart`, `action_group_gap.dart`, `app_segment.dart`, `adaptive_destination.dart`, `toast_request.dart`. The catalog scanner and the coverage test look only at the 25 inventory widgets (`core_widget_inventory.dart`), not at every public type. | Architecture rule 22.3 (one public type per file) and the scanner scope (R4 BL7). |
| D16 | `AppButton` loading does not use the `Pressable` disabled path. It passes a no-op `onPressed` and wraps `Pressable` in `IgnorePointer(ignoring: loading)`; the keyboard handler is the no-op. Disabled (`onPressed: null`) keeps `Pressable`'s 60 % opacity. The dark primary disabled paints solid ink-4 with ink-8 text and is then dimmed by that same 60 % (`04` §7 reads "disabled .6, dark primary turns solid ink-4/ink-8"). Tests assert the widget's own fill and text colour and the 0.6 `Opacity`, not the composite. `Pressable` is not changed. | R4 BL4. Smallest change that keeps old behaviour: no new parameter on foundation code. |

### Why the `Pressable` and Material boundary is one rule

Material is allowed as infrastructure (routes, `EditableText`, semantics, scrolling, tooltips) and banned for visuals.
The architecture test already bans Material controls in `lib/app`. Task A4 extends the same rule to `lib/core/widgets`,
`lib/core/layout`, and `lib/features`, and adds `Card`, `ListTile`, `AlertDialog`, `Dialog`, `SnackBar`,
`showDialog`, `showModalBottomSheet`, `PopupMenuButton`, `DropdownButton`, and `Scaffold` (only `AdaptiveScaffold`
may use `Scaffold`, as infrastructure under the shell). `Tooltip` stays allowed. Until task H5 replaces it,
`app/router/app_shell.dart` is a dated exception for `Scaffold` only; Z2 removes the exception and asserts that none is left.

---

## Architecture

### File map

```
skeleton/
  dart_test.yaml                         tags: golden            (A2)
  bricks/{feature,page,bloc,usecase,core_widget}/                (I)
  mason.yaml, mason-lock.json                                    (I1)
  design/tokens.yaml                     unchanged (fixed key set)
  tool/src/ladders.dart, palette.dart    + overlayTokens, + palette scrim   (A5, generator code)
  analysis_options.yaml                  + exclude bricks/**                (I1)
  lib/core/
    layout/   adaptive_scaffold, adaptive_destination, page_column, adaptive_grid, adaptive_builder, action_group, action_group_gap (+ window_class existing)
    widgets/  app_button, app_button_size, app_icon_button, app_pill, app_text_field, search_field, app_segmented, app_segment,
              theme_mode_switch, app_card, app_row, section_header, app_badge, empty_state, error_view,
              loading_view, skeleton_block, app_toast, toast_controller, toast_request, app_dialog, show_app_dialog,
              show_confirm, app_sheet, show_app_sheet, feedback_cell (function)
    theme/tactile/  surface.dart, pressable.dart   (existing, catalog block added)
  lib/features/home/{data,domain,presentation}/ + FEATURE.md      (H)
  lib/app/router/{app_shell,routes,route_names}.dart              (H)
  test/helpers/   stress.dart, golden.dart, surface_host.dart, core_widget_inventory.dart  (A)
  test/core/widgets, test/core/layout, test/core/theme (stress + behaviour + golden tests, goldens/ folders)
  test/features/home/...
  test/repo_tools/  create_app_test, sync_core_test, bricks_test, ci_workflow_test
tool/               create_app.dart, sync_core.dart, src/*.dart       (J, repo root; `process_runner.dart` is made by J1 and used by S2)
.github/workflows/  ci.yml                                             (K)
```

### Layering

Core widgets import only `package:flutter`, `lucide_icons_flutter`, and `core/` (theme, layout, l10n, error,
settings, utils). They never import `app/` or `features/` (Req 2.10, existing rule 19). `ThemeModeSwitch` and
`ErrorView` are the only widgets that touch more than `theme` and `layout`: `ThemeModeSwitch` reads
`AppSettingsCubit` from the tree, and `ErrorView` reads `Failure` and `context.l10n`.

### Component dependency graph

```
Pressable, TactileSurface (existing)
   ├─ AppButton ── ActionGroup ── showConfirm / AppDialog
   │      └─ ErrorView
   ├─ AppIconButton, AppPill
   ├─ AppSegmented ── ThemeModeSwitch
   ├─ AppTextField ── SearchField
   ├─ AppCard, AppRow, SectionHeader, AppBadge
   ├─ EmptyState, LoadingView/SkeletonBlock, feedbackCell
   ├─ AppToast + ToastController
   ├─ AppSheet ── (AppDialog on mobile → AppSheet)
   └─ AdaptiveBuilder → AdaptiveGrid, PageColumn → AdaptiveScaffold
```

### Rules every widget follows (Req 2)

A small private mixin is not introduced. Each widget does the same five things, and the tests of Req 12 enforce them:

1. Read `context.surface`, `context.text`, `context.sizes`, `AppMotion`, `AppSprings`, and tokens (including `AppOverlay` and
   `palette.scrim`, D13). No colour, weight, curve, or duration literal (architecture rule 22.4 stays green with no
   allowlist entry).
2. Wrap tappable parts in `Pressable(pressedScale: …, semanticLabel: …)`. `Pressable` already provides the 48 px hit
   area on touch, the hover and press fill, the focus ring, and the disabled opacity.
3. Wrap content that needs a standard surface in `TactileSurface(kind: …)`; this gives the children a new `SurfaceScope`
   (Req 5.1). Where a role needs another fill or shadow, use a `DecoratedBox` as D3 says.
4. When `context.reduceMotion` is true, use `Duration.zero` for travel, scale, and blur, and a 150 ms crossfade
   (`AppMotion.d150`) where content appears or leaves. The press scale is kept.
5. Use `Icon(LucideIcons300.xxx)` (import `package:lucide_icons_flutter/lucide_icons_300.dart`) for icons, sized from a token.

Text uses `context.text.body`, `.label`, `.meta`, `.field`, `.section`, `.title` as the existing `AppTypography`
exposes them, with `maxLines`, `overflow: TextOverflow.ellipsis`, and no fixed height on text containers (Req 5.6,
5.7). Free text that must wrap uses `softWrap: true` with a line clamp. Single-line labels (`AppButton`, `AppBadge`)
use `softWrap: false` and ellipsis.

### Strings

Widgets take text from callers. The fixed strings added to `app_en.arb` and `app_id.arb` in task P1 are only the ones
that do not exist yet: `clear` (search clear tooltip), `close` (dialog and sheet), `dismiss` (toast), `themeModeLabel`,
`copied` (semantics of the copy tick), and `tryAgain`. The keys `themeSystem`, `themeLight`, `themeDark`, `localeTitle`,
`localeSystem`, `localeEnglish`, `localeIndonesian`, and the seven `failure<Name>Title` and `failure<Name>Body` pairs
(`Network, Unauthorized, NotFound, Validation, Server, Cache, Unexpected`) already exist and are reused, not added again
(a duplicate key breaks `flutter gen-l10n`). `arb_test.dart` demands that a key ending in `Loading` or starting with
`loading` ends with "…", so none of the new keys uses those names. Home strings are added by task H3 in a separate
block. The key `placeholderTitle` becomes `appTitle` in task H6. `arb_test.dart` keeps the two files aligned.

---

## Components and interfaces

Signatures show the public API. Defaults follow `04` §7. `Key? key` and `const` are omitted for brevity.

### Primitives (existing)

`TactileSurface` and `Pressable` keep their API. They get a `{@catalog}` block (category `primitive`), a stress test,
and goldens. Their tests live in `test/core/theme/` next to the existing ones (`tactile_surface_stress_test.dart`
and so on), and the inventory maps to those paths.

### Action

```dart
enum AppButtonSize { regular, compact }                // app_button_size.dart

class AppButton extends StatelessWidget {
  AppButton.primary({required String label, VoidCallback? onPressed, IconData? icon,
      bool loading = false, String? loadingLabel, AppButtonSize size = regular});
  AppButton.secondary(...); AppButton.ghost(...); AppButton.destructive(...); AppButton.destructiveConfirm(...);
}
```

- Built on `Pressable(pressedScale: 0.97)` over a `DecoratedBox` (D3) whose fill is chosen by role. Primary uses
  `palette.primaryBg` and `primaryFg` with `surface.primary()` shadow. Secondary uses `surface.button()`.
  `destructive` is secondary with `danger.s11` text (`context.hue(HueRole.danger).s11`). `destructiveConfirm` is solid
  `danger.s9` with its contrast colour. Hover and press fill come from `Pressable` (its `PressFill`), not from
  `palette.primaryHover`.
- Height from `context.sizes.control` (regular) or `.compact`. Width hugs the label.
- Loading (D16): the label text is replaced in place by `loadingLabel` (required when `loading`, asserted), the
  `Pressable` gets a no-op `onPressed` and is wrapped in `IgnorePointer(ignoring: true)`, and the size is fixed by
  laying out the longer of the two labels invisibly (a `Stack` with the hidden label) so the button does not resize.
  Loading is not dimmed. Disabled (`onPressed: null`) uses `Pressable`'s 60 % opacity. Dark primary disabled paints
  solid `ink(4)` with `ink(8)` text under that 60 % (D16).
- A leading icon is 16 px, with `AppSpace.s8` gap.

```dart
class AppIconButton extends StatelessWidget {
  AppIconButton({required IconData icon, required String tooltip, VoidCallback? onPressed, int size = 28});
}
```
`size` is 22, 28, or 44 (asserted). Tooltip uses Material `Tooltip` as infrastructure with `waitDuration: AppMotion.d0`
(`d0` is added to `motion.dart` in A5). `AppIconButton` is never placed inside `AppToast` (no `Overlay` there, SF3);
the toast action is a `Pressable`. Press scale is 0.92, and 0.94 for 44. Icon colour animates `ink(10)` to `ink(12)` on hover.

```dart
class AppPill extends StatefulWidget {
  AppPill({required String label, IconData? icon, VoidCallback? onPressed});
  AppPill.copy({required String label, IconData? icon, required Future<bool> Function() onCopy});
}
```
28 px tall (36 on touch, `sizes.pill`), `SurfaceKind.raised`, icon 14 px. `.copy` shows the tick at once on press (`AppMotion.d1500`, or `AppMotion.d1000` when the pill has no label) and calls `onCopy`. When `onCopy`
returns `false` or throws, the tick reverts at once. It never shows a toast. A `Timer` is cancelled in `dispose`. Tests use `FakeAsync` (`tester.pump(duration)`).

```dart
class ActionGroup extends StatelessWidget {          // lib/core/layout
  ActionGroup({required AppButton primary, AppButton? secondary, List<Widget> extra = const [],
      ActionGroupGap gap = ActionGroupGap.page});
}
enum ActionGroupGap { page, overlay }                // 12 and 8
```
Desktop and tablet: a `Row` with `MainAxisAlignment.end`, secondary first, primary at the far right. Mobile: a
`Column` stretched to full width, primary on top. Gap 12 for `page`, 8 for `overlay`.

### Input

```dart
class AppTextField extends StatefulWidget {
  AppTextField({String? label, String? semanticLabel, TextEditingController? controller, String? helpText,
      String? errorText, String? Function(String)? validator, ValueChanged<String>? onChanged,
      ValueChanged<String>? onSubmitted, TextInputType? keyboardType, bool obscureText = false,
      FocusNode? focusNode, bool enabled = true, Widget? leading, Widget? trailing});
}
```
`label` is optional (SF9): without it no label is drawn above the well and `semanticLabel` is required (asserted).
`leading` and `trailing` are optional slots inside the well (used by `SearchField`). Built on `EditableText` (infrastructure) inside a `TactileSurface(kind: well)`, with the `field` text role. Focus
deepens the fill to `ink(4)` and shows the 2 px focus ring. `errorText` or a `validator` result shows a 1 px
`danger.s11` ring and the message under the field. Validation runs on blur (focus lost) and on submit, never on every
key. Under a scrolling parent it calls `Scrollable.ensureVisible` when focused so `viewInsets` do not hide it. The
label is above the well. Semantics label is the `label`, and the error is announced through `Semantics(liveRegion)`.

```dart
class SearchField extends StatefulWidget {
  SearchField({required ValueChanged<String> onChanged, required String hint, String? clearLabel,
      Duration debounce = SearchField.defaultDebounce, TextEditingController? controller});
}
```
Composes `AppTextField` (its `leading` search icon and `trailing` clear `AppIconButton` slots, no label, `semanticLabel: hint`) and shows the clear button only while the text is
non-empty. `onChanged` goes through the existing core `Debouncer`. The default delay is 400 ms and lives in a
`SearchField.defaultDebounce` constant (`AppMotion.d400`, added in A5). Surface is `well`, or `raised` on mobile in light mode.

```dart
class AppSegmented<T> extends StatefulWidget {
  AppSegmented({required List<AppSegment<T>> options, required T value, required ValueChanged<T> onChanged,
      bool pageLevel = false});
}
class AppSegment<T> { AppSegment({required T value, required String label, IconData? icon}); }
```
A `Stack` with a track (`well`-like fill one step darker, lighter in dark mode, 4 px inset) and one raised pill that
slides to the selected option with `AppSprings.toggle` (a `SpringSimulation` driven by an `AnimationController`
unbounded, `tester.pump` friendly). The first build places the pill without animation (`initState` sets the
controller value). With reduced motion the pill moves instantly. `pageLevel: true` adds 14 px icons and on mobile
uses 34 px options in a 42 px track (`sizes.toggleTrack`). Width hugs content. Each option is a `Pressable`.
Selected state is exposed through `Semantics(selected: true, inMutuallyExclusiveGroup: true)`.

```dart
class ThemeModeSwitch extends StatelessWidget { ThemeModeSwitch({}); }
```
Reads `AppSettingsCubit` through `BlocBuilder`, renders `AppSegmented<AppThemeMode>(pageLevel: true)` with System,
Light, Dark and icons (`LucideIcons300.monitor`, `.sun`, `.moon`), and calls `setThemeMode`. Persistence is
already done by the cubit (`AppSettingsCubit` saves through `KeyValueStore`), so Req 4.8 is covered by a cubit-level
restart test in task D4 (create a second cubit on the same in-memory store and assert the mode).

### Content

```dart
class AppCard extends StatelessWidget {
  AppCard.data({required Widget child});
  AppCard.clickable({required Widget child, required VoidCallback onPressed, required String semanticLabel});
}
```
`TactileSurface(kind: raised, radius: containerAll)` with the `card` shadow it already gives for `raised`, padding 24 (20 on mobile). `.clickable` is
wrapped in `Pressable(pressedScale: 0.99)` and fills `ink(2)` on hover through the primitive's fill. The child gets
a fresh `SurfaceScope` from `TactileSurface`.

```dart
class AppRow extends StatelessWidget {
  AppRow({required String title, String? description, String? trailing, Widget? leading, VoidCallback? onPressed});
}
```
No box. Minimum height `sizes.row` (38 pointer, 44 touch). Title in `ink(12)`, description in `ink(11)`, trailing
right-aligned with tabular figures (`FontFeature.tabularFigures()`; this is a `FontFeature`, not a banned literal).
Fill only on hover and press, so it is a `Pressable` only when `onPressed` is set. Title and description clamp at two
lines.

```dart
class SectionHeader extends StatelessWidget { SectionHeader({required String title, String? description, List<Widget> actions = const []}); }
```
Title uses the `section` role (20/28), 6 px gap, description in `ink(11)`. On mobile the actions go under the
description at full width. A `Row` with `Expanded` text on wider windows.

```dart
class AppBadge extends StatelessWidget {
  AppBadge.tone({required String label, required HueRole hue});
  AppBadge.neutral({required String label});
}
```
`.tone` uses `context.hue(role).s3` fill and `context.hue(role).s11` text (`context.hue(HueRole)` is the accessor; `HueRole` has no `s3` itself), with a `DecoratedBox` and the `surface.badge(hue)` shadow (D3). Height `sizes.badge`, one line, ellipsis.

### Feedback

```dart
class EmptyState extends StatelessWidget { EmptyState({required IconData icon, required String title, required String body}); }
class ErrorView extends StatelessWidget { ErrorView({required Failure failure, required VoidCallback onRetry}); }
class LoadingView extends StatelessWidget { LoadingView({required Widget placeholder}); }
class SkeletonBlock extends StatefulWidget { SkeletonBlock({double? width, double? height, BorderRadius? radius}); }
Widget feedbackCell({required int index, required List<Widget> states});
```
- `EmptyState`: bare centred panel, `ink(2)` fill, 44 px padding (`AppSpace` plus a token if needed), icon 18 (24 on
  mobile), two text lines.
- `ErrorView`: `switch (failure)` over the sealed `Failure`, one `failure<Name>Title/Body` pair per subtype from
  `context.l10n`. It never reads `failure.message`, so raw exception text never shows (Req 6.3). One secondary
  `AppButton` "Try again".
- `LoadingView`: renders the caller's `placeholder` (built from `SkeletonBlock`s that mirror the content), so layout does
  not jump. It wraps it in `ExcludeSemantics` plus one `Semantics(label: loading, liveRegion: true)`.
- `SkeletonBlock`: an `AnimationController` repeats between alpha steps a3 and a4 (`palette.alphaA3`, `alphaA4`) using
  `AppMotion.d1200` (added in A5). With reduced motion the controller never starts and
  the block is solid a3.
- `feedbackCell`: `IndexedStack(index: index, ...)` where all states are laid out, so the cell is as large as the
  largest (an `EmptyState` therefore appears in a panel as tall as the list, which Req 6.5 asks for and the README notes).
  Each child is wrapped in `TickerMode(enabled: i == index, child: ...)` (D14), so a hidden `SkeletonBlock` schedules
  no frames and `pumpAndSettle` in tests of `HomeView` ends. Documented in the doc block of `LoadingView`.

```dart
class ToastController extends ChangeNotifier {       // toast_controller.dart, @lazySingleton
  ToastRequest? get current;
  void show(String message, {String? actionLabel, VoidCallback? onAction});
  void dismiss();
}
class ToastRequest { ToastRequest({required String message, String? actionLabel, VoidCallback? onAction}); }  // toast_request.dart
class AppToast extends StatefulWidget { AppToast({required ToastController controller, required Widget child}); }
```
The controller holds one request and replaces it on `show`. `AppToast` is the host: an `Overlay`-free `Stack` that
listens to `controller` and shows the current toast at the bottom centre, 48 px tall (`AppOverlay.toastHeight`),
raised, with one optional action and a 6 s `Timer` (`AppMotion.d6000`; restarted on replace, cancelled in `dispose`).
`App` inserts the host through `MaterialApp.router(builder:)` with `controller: getIt<ToastController>()` (H5), so
`core/` never imports `app/di`. Features call `getIt<ToastController>().show(...)`. The host is above the `Navigator`,
so there is no `Overlay` in it: the toast contains no `Tooltip` and no `AppIconButton`, and its action is a
`Pressable` (SF3). `ToastController` carries `@lazySingleton` (`injectable` is already a dependency; the annotation in
`core/` is allowed). Copy confirmation never uses it (6.7).

### Overlay

```dart
Future<T?> showAppDialog<T>(BuildContext context, {required AppDialog dialog});   // show_app_dialog.dart
class AppDialog extends StatelessWidget {
  AppDialog({required String title, required Widget body, Widget? footer, double width = AppOverlay.dialogDefault,
      bool showClose = false});
}
Future<bool> showConfirm(BuildContext context, {required String title, required String body,
    required String confirmLabel, String? cancelLabel, bool destructive = false});
class AppSheet extends StatelessWidget { AppSheet({required String title, required Widget child, Widget? footer}); }
Future<T?> showAppSheet<T>(BuildContext context, {required AppSheet sheet});
```
- Routing uses `PageRouteBuilder<T>(opaque: false, barrierDismissible: true, barrierLabel: context.l10n.close)` with no
  `barrierColor` (the default is null, so no `Colors.transparent` is written) and our own backdrop
  (`palette.scrim`, black 30 % light and 90 % dark, D13, with 2 px blur from `AppOverlay.backdropBlur` through the existing
  `blur_conversion`), so no `showDialog`,
  `showModalBottomSheet`, `AlertDialog`, or `Dialog` is used (Req 7.7). The route is pushed on the root navigator.
- `AppDialog` widths 620, 460, 440 are tokens (`AppOverlay.dialogDefault`, `dialogConfirm`, `dialogInfo`, added in
  A5). Header, body, and footer are split by 0.5 px hairlines (`surface.line`). Cancel is left and confirm right in the
  footer through `ActionGroup(gap: overlay)`. The "×" close only shows when there is no footer. The first field is
  focused on open through a `FocusScope` with `autofocus` on the first `EditableText` (`FocusTraversalGroup`
  requests focus in `initState` post-frame). Enter: 16 px rise + 4 px blur + fade in `AppMotion.d240`, exit
  `AppMotion.d200`. Reduced motion: 150 ms crossfade only.
- `showConfirm` picks `AppDialog` (width 460) or `AppSheet` by `context.windowClass == mobile`, and returns `true` only
  when the confirm button pops `true`. Dismissal returns `false`.
- `AppSheet` is mobile-only: it asserts `windowClass == mobile` in debug and does not fall back to a dialog. Top radius `AppRadius.sheet`, fill `overlay` surface kind `sheet`, grab handle 36 × 5 with an 88 × 44
  hit area, title with no header band, footer buttons under content. Rise 320 ms (`AppMotion.d320`), sink 200 ms,
  dismiss by dragging down through a `GestureDetector` vertical drag that closes past 1/3 of the height or a fling.

### Layout

```dart
class AdaptiveBuilder extends StatelessWidget {
  AdaptiveBuilder({required WidgetBuilder mobile, WidgetBuilder? tablet, WidgetBuilder? desktop});
}
class AdaptiveGrid extends StatelessWidget {
  AdaptiveGrid({required List<Widget> children, int mobileColumns = 1, int tabletColumns = 2, int desktopColumns = 3, double gap = AppSpace.s16});
}
class PageColumn extends StatelessWidget {
  PageColumn.reading({required Widget child}); PageColumn.data({...}); PageColumn.form({...});
}
class AdaptiveScaffold extends StatefulWidget {
  AdaptiveScaffold({required String title, required List<AdaptiveDestination> destinations, required int currentIndex,
      required ValueChanged<int> onDestination, required Widget body, List<Widget> actions = const [], List<String> breadcrumbs = const []});
}
class AdaptiveDestination { AdaptiveDestination({required String label, required IconData icon}); }
```
- `AdaptiveBuilder` reads `context.windowClass`. A missing `tablet` falls back to `mobile`, a missing `desktop` falls
  back to `tablet ?? mobile`.
- `AdaptiveGrid` uses a `Wrap`-free `LayoutBuilder` + `Row`s of `Expanded` (no fixed row height), column count from the
  window class.
- `PageColumn` is a centred `ConstrainedBox` (800, 1200, 440 from `AppLayout.colReading`, `colData`, `colForm`) inside
  a `SingleChildScrollView`, with 48 above and 64 below (`AppSpace.s48`, `s64`) and horizontal padding by window class.
  `.reading` wraps prose in `ConstrainedBox(maxWidth: 70 × em)` through a `Text` helper that measures `70ch` using
  the body font size (`maxWidth = body.fontSize * 35`, a documented approximation of 70 characters).
- `AdaptiveScaffold`: desktop = rail (`AppLayout.railExpanded`) on `ground`, floating `panel` 8 px from the window
  (`AppLayout.panelFloat`) with the 52 px top strip (`AppLayout.topStrip`). Tablet = collapsed rail
  (`railCollapsed`). Mobile = 56 px top bar (`mobileTopBar`) plus a bottom tab bar on `sheet` surface with a hairline
  above, active item `ink(12)` on `ink(3)`, inactive `ink(10)`, labels always shown. One `ScrollController`-listening
  `NotificationListener<ScrollNotification>` toggles the sticky hairline under the bar only once `pixels > 0`.
  State is kept across window class changes by keeping `body` in one `GlobalKey`-ed subtree that moves between layouts
  (`KeyedSubtree`). The scaffold uses Material `Scaffold` only as infrastructure for the body (`Material` ancestor,
  `ScaffoldMessenger` is not used). `SafeArea` is provided on mobile.

### Catalog block format

```dart
/// A button with five roles.
///
/// {@catalog}
/// category: action
/// use_when: ...
/// avoid_when: ...
/// variants: primary, secondary, ghost, destructive, destructiveConfirm
/// tags: button, cta, submit
/// {@endcatalog}
```
Same format as `05` §5 (without `chart`, which is not in this spec's category list). The scanner `test/core/catalog_blocks_test.dart`
parses doc comments with a regex over the source (the analyzer package is not a dependency). It requires, for each
public class declared in the files under `lib/core/widgets/`, `lib/core/layout/` (except `window_class.dart`), and
the two primitives, that the class doc contains one block with the five fields non-empty and `category` in the seven
allowed values. It also fails when `lib/core/widgets/CATALOG.md` exists (Req 1.5).

---

## Stress harness (`test/helpers/stress.dart`)

### API

```dart
enum StressFixture { normal, long, longWord, empty, emoji, rtl, bigNumber, nullValue }

class StressData {                     // what a fixture gives to the widget builder
  final String? text;                  // null for nullValue
  final String? secondary;
  final num? number;
  final TextDirection direction;
  final StressFixture fixture;
}

typedef StressBuilder = Widget Function(BuildContext context, StressData data);

void stressTest(String name, StressBuilder builder, {
  Set<StressFixture> fixtures = StressFixture.values.toSet(),
  bool interactive = false,            // runs the a11y guidelines at 375×812
  String? skipContrastReason,          // null = contrast runs; '' = test fails; text = skip with reason
  StressProfile? profile,              // default: from --dart-define=STRESS
});

void stressProperty(String name, StressBuilder builder, {int seed = 20260126, int maxExamples = 20});
```

### Profiles

```dart
sealed class StressCase { Size size; double devicePixelRatio; double textScale; Brightness brightness;
                          InputMode input; StressFixture fixture; String get label; }
```
- `profile = const String.fromEnvironment('STRESS', defaultValue: 'quick')`.
- `quick` (17 cases): `320×640 @2.0 touch light` × 8 fixtures, `1600×900 @1.0 pointer light` × 8 fixtures,
  `375×812 @1.0 dark touch normal` × 1.
- `full`: sizes `320×640, 375×812, 768×1024, 1024×768, 1200×800, 1600×900` × text scales `1.0, 1.5, 2.0` × light and dark
  × input mode. Touch is used for the sizes up to and including 1024 wide (320, 375, 768, 1024) and pointer for the sizes
  from 768 wide up (768, 1024, 1200, 1600), so 768 and 1024 run in both. That is 4 touch + 4 pointer = 8 (size, input)
  combinations × 3 scales × 2 themes = **48 groups**, and 48 × 8 fixtures = **384 labelled renders** per widget (not
  1 000 and not 120). The harness registers one `testWidgets` per group and pumps the eight fixtures in turn. Between
  fixtures it pumps a `SizedBox.shrink()` so no state leaks from one fixture to the next. Each fixture keeps its own
  failure label. The run time is recorded by the final task. Task A1 asserts these numbers (48 and 384; quick 17).
- Test name: `'<name> | <w>×<h> @<dpr> x<scale> <light|dark> <touch|pointer> | <fixture>'`. For grouped tests the
  failing fixture is added to the `reason` and to the thrown message (Req 9.6).

### Rendering one case

1. `tester.view.physicalSize = size * dpr`, `devicePixelRatio = dpr`, `tester.platformDispatcher.textScaleFactorTestValue
   = scale`, `platformBrightnessTestValue = brightness`. Resets in `addTearDown`.
2. `debugDefaultTargetPlatformOverride = input == touch ? iOS : macOS`, restored in a `finally` before the test ends.
   This is what `context.inputMode` reads.
3. Pump `MaterialApp(theme: buildTheme(brightness, WindowClassX.fromWidth(size.width), input), locale: fixture-based
   locale (en, or ar for rtl), localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales:
   AppLocalizations.supportedLocales, home: Directionality(textDirection: data.direction, child: SurfaceHost(...)))`.
   `SurfaceHost` (in `surface_host.dart`) builds the root `SurfaceScope(kind: ground, brightness, palette, shadows)`
   exactly as the existing theme tests do, and an `Align(topLeft)` with `ConstrainedBox(constraints: loose(size))` so
   the widget sees real, bounded constraints. There is no `Scaffold` (so a widget that needs a Material ancestor fails
   here the same way it would in the app root only if the app root has none; `MaterialApp` supplies one for text fields,
   and `AdaptiveScaffold` brings its own).
4. After `pumpWidget`, `pump(Duration(milliseconds: 400))` settles first-frame animations, then
   `expect(tester.takeException(), isNull)`.
5. Any `FlutterError` is caught through `FlutterError.onError` set by the harness for the case, collected, and rethrown
   as a `TestFailure` that starts with the case label. `RenderFlex overflowed` is a `FlutterError`.
6. On failure the harness saves `tester.binding.takeScreenshot`-equivalent via `RepaintBoundary.toImage` to
   `test/<mirror path>/failures/<label>.png` (best effort, errors ignored). `.gitignore` gets `test/**/failures/`
   (Req 9.10), and CI uploads the folder.
7. Font (R4 SF13): `stress.dart` calls `loadInterFont()` from `test/helpers/fonts.dart` (written in A1; `loadGoldenFonts()` of A2 reuses it)
   once in `setUpAll` of every file that calls `stressTest`. Metrics are then
   those of Inter Medium, as in the app. Text in a test without the font would use Ahem (one em per character), which
   is stricter and not representative, so it is not used.

### Fixtures

| Fixture | text | number | notes |
|---|---|---|---|
| normal | `"Weekly report"` | `1280` | |
| long | 60 words of lorem text | `1280` | |
| longWord | 80 characters without spaces | `1280` | |
| empty | `""` | `0` | |
| emoji | `"Plan 🚀 review 👩‍💻✅"` | `1280` | includes ZWJ sequences |
| rtl | Arabic sentence | `1280` | `direction: rtl`, locale `ar` for the delegates falls back to `en` strings |
| bigNumber | `"Total"` | `123456789` | 9 digits |
| nullValue | `null` | `null` | the builder must handle null |

A builder uses only what the widget takes. A widget without text ignores `text`.

### Accessibility checks (`interactive: true`)

At the `375×812 @1.0` case (quick) the harness runs, in both light and dark, with the `normal` fixture:

```dart
await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
await expectLater(tester, meetsGuideline(textContrastGuideline));
```
It enables semantics with `tester.ensureSemantics()` first. The light case at 375 is added to the quick profile for
`interactive` tests only, so those tests have 18 renders (17 + one light at 375×812). `skipContrastReason` is
validated at registration: an empty string throws `ArgumentError` so the test fails at load (Req 10.2). A skipped
contrast check prints the reason through `printOnFailure`.

### Harness self-tests (`test/helpers/stress_test.dart`)

- A widget that overflows (`Row` with two fixed 400 px `SizedBox`es) fails; the failure message contains the size,
  scale, theme, input mode, and fixture. The test uses `expectLater(() => ..., throwsA(...))` through an internal
  `runStressCase` function that `stressTest` calls, not through nested registration.
- A `Text` in a flexible box passes in all 17 cases.
- `skipContrastReason: ''` throws.
- The quick profile creates exactly 17 case labels, the full profile creates the expected counts.

### `stressProperty` and kiri_check

`kiri_check` 1.4.0 depends on `package:test`, not on `flutter_test`, and its `forAll` block cannot receive a
`WidgetTester`. The design therefore uses two steps and a spike (task A7):

1. Preferred: inside `property(...)`, `forAll(combine2(string(...), integer(...)), (v) async { ... })` where the block
   renders through `TestWidgetsFlutterBinding.instance` with a manually driven pump
   (`binding.attachRootWidget` / `binding.pump`) wrapped in the same host and error capture as `stressTest`. The spike
   proves whether this works under `flutter test`.
2. Fallback if the spike fails: draw the samples with the kiri_check arbitraries and a fixed `seed` at declaration
   time through `forAll(..., onGenerate:)` in a `property`, write them to a list in a `setUpAll`-free helper, and run
   them as normal `testWidgets` in the same file. If neither works, `stressProperty` uses a seeded `dart:math` `Random`
   and the deviation is recorded in the README and the spec check as a known gap (not blocking).

The seed is fixed (`20260126`) so CI is deterministic (Req 9.8).

---

## Golden setup (`test/helpers/golden.dart`)

```dart
Future<void> loadGoldenFonts();                         // FontLoader('Inter') from assets/fonts/Inter-Medium.ttf
void goldenTest(String name, WidgetBuilder builder, {Size size = const Size(...), Set<Brightness> themes = both});
// Writes/compares   goldens/<name>_light.png  and  goldens/<name>_dark.png   next to the test file.
```

- `dart_test.yaml`: `tags: { golden: { } }`. Every `goldenTest` registers with `tags: ['golden']`.
- `setUpAll`: `if (!Platform.isMacOS) fail('Golden tests run on macOS only (04 §12).')`. This fails with a clear message
  and writes nothing.
- Font: `FontLoader('Inter')..addFont(rootBundle.load('assets/fonts/Inter-Medium.ttf'))` then `await load()`, before the
  first pump. A self-test renders a `Text` and asserts that the rendered family is `Inter` (through `RenderParagraph`
  text style) and the font load completed.
- Device pixel ratio 2, `debugDefaultTargetPlatformOverride = TargetPlatform.macOS`, so `InputMode.pointer` and 0.5 px
  hairlines render as 1 physical px.
- One image per theme per widget (Q8 default): `goldenGallery(name, variants: {label: Widget})` lays the variants and
  states out in a `Wrap` on a `ground` surface with a caption per cell. States that need user input (hover, pressed,
  focus) are produced by pumping a `TestGesture` (`addPointer`, `moveTo`, `down`) in a pre-step callback
  (`prepare: (tester) async`), or by passing a controlled state through test-only constructor parameters that already exist
  for tests (none are added to public APIs: hover and pressed are driven by gestures).
- Real root test (Req 11.6): `test/app/app_test.dart` already pumps `App()` with the real router (`_pumpApp`), so that test
  is the evidence now. No new `app_root_test.dart` is made in A2 (the widget `AdaptiveScaffold` does not exist yet and
  H5 owns `test/app/**`). H5 adds one case to `app_test.dart`: at 390×844 `find.byType(AdaptiveScaffold)` finds one.
- Platform: the golden helper sets `ThemeData.platform` and `debugDefaultTargetPlatformOverride` to macOS (`context.inputMode`
  reads `defaultTargetPlatform`, `window_class.dart:45`). `flutter test` defaults to Android, so the override is needed.
- Stability: task A2 runs the golden suite twice and compares file hashes (Req 11.7). A difference is reported as a
  finding and not hidden with `comparator` tolerance.
- Review: goldens are viewed at 2× by the user in a `[manual]` task (Req 12.6).

---

## Home feature

```
lib/features/home/
  FEATURE.md                          source: local, lists files
  domain/
    entities/home_item.dart                 HomeItem {id, title, subtitle, value}   (@freezed)
    repositories/home_repository.dart       Future<Either<Failure, List<HomeItem>>> getItems();
    usecases/get_home_items_usecase.dart    GetHomeItemsUseCase implements UseCase<List<HomeItem>, NoParams>
  data/
    datasources/home_local_datasource.dart  returns a static const list of HomeItemModel
    models/home_item_model.dart
    mappers/home_item_mapper.dart           extension HomeItemModelX on HomeItemModel { HomeItem toEntity() }
    repositories/home_repository_impl.dart  guardRepository(() => ds.read()) → mapper
  presentation/
    bloc/home_cubit.dart, home_state.dart   (+ .freezed.dart generated)
    pages/home_page.dart                    provides HomeCubit via BlocProvider(getIt), {@screen summary: ...}
    pages/home_view.dart                    renders states
    widgets/home_summary_tile.dart          feature widget (an AppRow + AppBadge composition)
    widgets/language_switch.dart            feature widget: AppSegmented<AppLocale> (System, English, Indonesia) over AppSettingsCubit.setLocale
```

The path layout follows `03` §5 (folder names and suffixes). If `03` §5 differs in folder names, the brick and the
feature follow `03` §5 and the deviation goes into the README.

- State: `@freezed sealed class HomeState { initial | loading | success(List<HomeItem> items) | empty | failure(Failure) }`.
  A cubit, not a bloc, because the page has one action (`load`/`retry`). `03` §5 allows either (Req 13.4).
- `HomeCubit.load()`: emit `loading`, call the use case, emit `empty` for an empty list, `success` otherwise, `failure`
  on `Left`. The data source is synchronous static data wrapped in a `Future`, so the failure path is reachable only
  through tests with a mock data source (and through a debug-only constructor flag is NOT added).
- `HomeView` is the body of the shell's `AdaptiveScaffold` (see the shell bullet below): `PageColumn.data` → `SectionHeader`
  → `feedbackCell(index: …, states: [LoadingView, EmptyState, ErrorView, list])` → `ActionGroup(secondary: AppButton.secondary,
  primary: AppButton.primary)` → `ThemeModeSwitch` → `LanguageSwitch`. Every state is rendered by `BlocBuilder` with an
  exhaustive `switch`.
- Language picker (S5, SF11, preserve existing behaviour): the placeholder's System, English, Indonesia group moves to
  `LanguageSwitch`, an `AppSegmented<AppLocale>` fed by `AppSettingsCubit.setLocale`, with the existing `localeTitle`,
  `localeSystem`, `localeEnglish`, `localeIndonesian` strings. The cubit, the keys, and the "a saved Dark and Indonesia
  survive a restart" test stay (H5 rewrites the test to find the home page and tap `localeIndonesian`). No new core widget.
- `AppShell` (in `lib/app/router/app_shell.dart`) becomes the `AdaptiveScaffold` host (Req 8.5): its `ShellRoute` builder
  owns the destination list (one: Home) and passes `child` as `body`. The `TODO(core-widgets-and-templates)` is removed.
  Since `HomeView` also wants `AdaptiveScaffold`, the split is: `AppShell` builds `AdaptiveScaffold` and the page body
  is a `PageColumn` (the page does not nest a second scaffold). The Req 13.5 wording "renders inside AdaptiveScaffold"
  is met through the shell, and `HomeView` golden tests wrap it in the same `AdaptiveScaffold` through a test helper
  `pumpInShell`.
- Routes: `RouteNames.home = '/'` replaces `RouteNames.root`'s builder. `routes.dart` keeps the only `GoRoute(` in the
  project (existing rule 20).
- DI: `@lazySingleton` on the data source and repository (`@LazySingleton(as: HomeRepository)`), `@injectable` on the use
  case and cubit. `injection.config.dart` is regenerated, never hand edited.
- Architecture test: the "lib/features does not exist" case becomes "lib/features/home has data, domain, and
  presentation". All layer rules already scan `features/` paths.
- Removal of the placeholder: delete `lib/app/placeholder/`, the tests under `test/app/placeholder/`, the DI entry, the
  `checkConnection*` ARB keys, `Env.connectionCheckUrl` and its test line in `test/app/env_test.dart`, the
  `checkConnection` cases in `test/core/l10n/arb_test.dart` (replace by `themeDark` and `tryAgain`, English and
  Indonesian), update `test/app/app_test.dart` (it finds `PlaceholderPage` today) and `routes_test.dart`, and rename
  `placeholderTitle` to `appTitle`. The `locale*` keys stay.

### Home tests

| Test | Folder | Covers |
|---|---|---|
| mapper, use case, repository impl (mocktail data source) | `test/features/home/data`, `.../domain` | success and thrown-exception paths (14.1) |
| `bloc_test` for `HomeCubit` | `test/features/home/presentation` | initial→loading→success, loading→empty, loading→failure (14.2) |
| widget test of `HomeView` with `MockHomeCubit` | same | four states and "Try again" calls `load` (14.3) |
| `stressTest` of `HomeView` + a11y | same | 14.4 |
| golden tests `HomeView` 390×844, 834×1194, 1440×900 × light, dark | `test/features/home/presentation/goldens/` | 6 images (14.5) |
| `kiri_check` property: mapper preserves `id`, `title`, `subtitle`, `value` for any generated model | `.../data/home_item_mapper_property_test.dart` | 14.6 |

---

## Bricks

`mason.yaml` registers five local bricks under `bricks/<name>/` (`brick.yaml`, `__brick__/`, `hooks/` only if needed,
and a `README` line in the skeleton README). Variables: `name` (snake_case, required), plus `feature` for `page`,
`bloc`, `usecase` (which feature folder to write to, default `name`).

| Brick | Generates | Based on |
|---|---|---|
| `feature` | full `data/`, `domain/`, `presentation/` tree, `FEATURE.md`, one test per layer, DI annotations | the `home` feature |
| `page` | `<name>_page.dart` + `<name>_view.dart` with `{@screen summary: ...}`, a widget test | `home_page`, `home_view` |
| `bloc` | `_bloc.dart`, `_event.dart`, `_state.dart` with `initial | loading | success | empty | failure`, a `bloc_test` | `03` §5 |
| `usecase` | `<name>_usecase.dart` implementing `UseCase`, a unit test | `get_home_items_usecase.dart` |
| `core_widget` | `lib/core/widgets/<name>.dart` with a Catalog_Block, `test/core/widgets/<name>_test.dart` with `stressTest`, a golden test | an existing core widget |

Templates use mustache with `{{name.snakeCase()}}`, `{{name.pascalCase()}}`, and the package name read from a
`package` variable (default `skeleton`; `create_app` leaves bricks in place and the default is overwritten by the
generated app through a one-line replace of `package: ` in each `brick.yaml`).

Template files under `__brick__/` end in `.dart` and hold mustache (`{{name.snakeCase()}}`), which is not valid Dart. They would
break the Skeleton's own checks, so (R4 BL8): `analysis_options.yaml` gets `bricks/**` in `analyzer: exclude:` (task I1),
and `tool/check.dart` runs `dart format --set-exit-if-changed lib test tool` instead of `.` (task A2, because `dart format`
has no exclude setting). `create_app` copies `bricks/` with these two files, so the generated app is covered too.

Verification (`test/repo_tools/bricks_test.dart`): copy `skeleton/` (without `build/`, `.dart_tool/`) to a temp folder,
run `mason get`, then `mason make <brick> --name sample_thing` for each brick (feature first, so the others have a
feature folder), then `dart run build_runner build -d`, `flutter analyze` (zero issues), and `flutter test` on the
generated tests. The file has `@Timeout(Duration(minutes: 10))` and `@Tags(['slow'])` (R4 SF6; `dart_test.yaml` declares
`slow`), because `flutter pub get` alone costs 30 to 60 s and the default test timeout is 30 s. The test skips with a clear message when `mason` is not on `PATH` or when the temporary `pub get` fails for lack of network, and runs in the default gate and in CI
(`check.dart` excludes only `golden` and `e2e`). The generated tests are fast, so the test builds one temp copy and
shares it across the five bricks.

---

## `tool/create_app.dart`

Usage: `dart run tool/create_app.dart <package_name> [--dir <folder>] [--org com.example] [--display-name "My App"] [--out .] [--clean]`.

```
tool/create_app.dart               arg parsing, orchestration, process runs
tool/src/create_app_core.dart      pure: validateName, replaceInText, shouldCopy, renamePlatformIds, cleanHome
tool/src/process_runner.dart       runs a command with a working dir, returns exit code (injectable in tests)
```

Flow:

1. Parse and validate. A valid package name matches `^[a-z][a-z0-9_]*$`, is not a Dart reserved word, and is not
   `skeleton`'s private words. The target is `<out>/<dir ?? name>`. If invalid or the target exists, print the error and
   exit 64 with no file written (check before the first copy).
2. Copy `skeleton/` file by file (`File.copy`, `Link` entries are resolved to real files), skipping `build/`,
   `.dart_tool/`, `*.iml`, `.idea/`, `pubspec.lock`, `test/repo_tools/`, and `.fvm/`. `.fvmrc` is copied.
3. Text replacement over text files only (by extension list): `package:skeleton/` → `package:<name>/`, `name: skeleton` in
   `pubspec.yaml`, and the platform identifiers. IDs come from `--org` plus the name: Android `applicationId` and
   `namespace` in `android/app/build.gradle(.kts)`, `PRODUCT_BUNDLE_IDENTIFIER` in iOS and macOS `project.pbxproj`
   (and the `RunnerTests` suffix) and macOS `AppInfo.xcconfig`, Linux `APPLICATION_ID` in `linux/CMakeLists.txt`,
   Windows `BINARY_NAME`, web `manifest.json` (`name`, `short_name`) and `index.html` `<title>`, and `package: skeleton` in
   each `bricks/*/brick.yaml`. The display name replaces
   `Skeleton` in the platform label files that `skeleton-foundation` task 1.2 touched. The Android `INTERNET`
   permission, the `https` `<queries>` entry, and the macOS `network.client` entitlement are never matched by any
   replacement pattern, and a post-step test asserts they are still present. Tests that assert the name (R4 SF1):
   `test/platform/web_index_test.dart` asserts `<title>Skeleton</title>` and `"name": "Skeleton"`, so J2 rewrites those
   literals in the copy to the display name (a replacement rule on that one file, with a test), and
   `test/docs/readme_test.dart` is rewritten in the copy to keep only the checks that hold in the app (the Z1 rule "every
   path named in the README exists" is limited to paths inside `skeleton/`, because `tool/create_app.dart` and
   `tool/sync_core.dart` live at the repository root).
4. Fallback (Req 16.6): if a platform file does not contain the expected pattern, the script prints which file and runs
   `flutter create --org <org> --project-name <name> --platforms=... <tmp>`, copies only that platform's folder
   across, and re-applies the permission and entitlement edits. This path is covered by a unit test with an injected
   runner and a fixture missing the pattern.
5. Reset templates if present: `api/openapi.yaml`, `api/api_map.yaml`, `api/CHANGELOG.md`,
   `.kiro/steering/product.md` are overwritten with the template text from `tool/src/templates.dart`. If a file is
   absent, skip silently.
6. `--clean`: delete `lib/features/home/`, `test/features/home/`, and their goldens, then edit `routes.dart` (remove the
   home `GoRoute`, leaving a single empty-state route to a minimal `AppHome` that is generated), `route_names.dart`,
   `app_shell.dart` destinations, and ARB keys marked with the comment-free prefix `home*` (identified by prefix), then
   regenerate DI. The minimal replacement is one `EmptyState` page
   `lib/app/home_placeholder_page.dart` created by the script, with a test, so the app does not start on a blank
   screen and `routes.dart` keeps one route. The `home` page uses ARB keys of its own for that page's two text lines
   (`appHomeEmptyTitle`, `appHomeEmptyBody`, not the `home*` prefix, in both languages). Tests that name the home feature
   (R4 SF2) are listed explicitly, one test each in J4: `test/features/home/**` (deleted), `test/app/router/routes_test.dart`,
   `test/app/app_test.dart` (language and theme tests now find the minimal page and a `LanguageSwitch` is not there, so the
   persistence case is kept by driving `AppSettingsCubit` directly), `test/app/shell_golden_test.dart` (deleted, with its
   goldens), and `test/architecture/architecture_test.dart` (Z2's "home has three layers" rule is written as
   `if (Directory('lib/features/home').existsSync())`, so it also holds in a `--clean` app). The generated app still analyses and tests.
7. `git init` and a first commit when the target is not inside a git work tree (`git rev-parse --is-inside-work-tree`).
   The commit passes the identity on the command line (`git -c user.name=... -c user.email=... commit`, fixed values from
   `create_app`), because a hosted runner has no git identity (R4 SF7). A unit test with the injected runner covers the argument list.
8. `flutter pub get`, `dart run build_runner build -d`, `dart run tool/generate_tokens.dart`. Print next steps: open
   in Kiro, fill `product.md` (when present), adjust `design/tokens.yaml`. No `kit` mention.

Tests: `test/repo_tools/create_app_test.dart` covers the pure parts without Flutter (names, copy filter, replacements
on string fixtures, permission survival). An end-to-end test runs the script into a temp folder with and without `--clean`
and then `flutter analyze` and `flutter test --exclude-tags golden`. It is tagged `e2e`.
`dart_test.yaml` declares the tag and `check.dart` excludes it, so the normal gate stays short. The Template_Job in CI and
the manual task run the script directly, and a `[kode]` task runs the e2e test with `--tags e2e`.

---

## `tool/sync_core.dart`

Usage: `dart run tool/sync_core.dart --from <app> --to <target> [--dry-run]`.

```
tool/sync_core.dart           args, orchestration
tool/src/sync_core_core.dart  pure: plan(from, to) → SyncPlan{copies, conflicts, packages}; rewriteImports; diff
```

1. Read the package name of each side from `pubspec.yaml` (`name:` line).
2. Collect files under `lib/core/widgets/**` and `lib/core/layout/**` of `--from` that do not exist in `--to`, plus for each
   widget its tests (`test/core/widgets/<base>_test.dart`, `<base>_golden_test.dart`) and goldens
   (`test/core/widgets/goldens/<base>_*.png`).
3. Conflicts: a file that exists on both sides with different bytes. The tool prints a unified-style diff and exits 1
   before writing anything (all plans are computed first). Identical files are skipped.
4. Rewrite `package:<from>/` to `package:<to>/` in copied Dart files.
5. Packages: scan copied files for `package:<x>/` imports where `<x>` is neither `<to>` nor in `--to`'s `pubspec.yaml`
   dependencies. Add `<x>: <constraint>` from `--from`, as text under `dependencies:` (or `dev_dependencies:` for test-only
   imports), and run `flutter pub get` in `--to`.
6. `--dry-run`: print copies and packages, write nothing.
7. After copy: run `flutter test <copied tests>` in `--to`. `kit catalog` and `kit check` run only when `kit` exists in `--to`
   (a `kit` directory or `dart run kit` entry); otherwise print "kit not present, skipped".

Tests (`test/repo_tools/sync_core_test.dart`): two temp fixture projects (small `pubspec.yaml`, a widget, a test, a golden
byte file). Covers copy, import rewrite, added package, dry run (nothing written), identical file skip, and conflict stop.
Process calls (`flutter pub get`, `flutter test`) go through the injected runner so the unit tests do not need Flutter.
The runner is `tool/src/process_runner.dart`, written once by J1 (S2 depends on J1; there is no second copy, R4 SF8).
`shortcut:` `sync_core` does not update `test/helpers/core_widget_inventory.dart` in the target, so the UI005 stand-in
does not see synced widgets; documented in the README, to be fixed when `kit` exists (R4 N8).

---

## CI (`.github/workflows/ci.yml`)

```yaml
name: ci
on:
  push:         { paths: ['skeleton/**', 'tool/**', '.github/workflows/ci.yml'] }
  pull_request: { paths: ['skeleton/**', 'tool/**', '.github/workflows/ci.yml'] }
jobs:
  skeleton:                                   # matrix keeps room for app_orbit, app_tally
    runs-on: ubuntu-latest
    strategy: { matrix: { project: [skeleton] } }
    defaults: { run: { working-directory: ${{ matrix.project }} } }
    steps:
      - actions/checkout
      - subosito/flutter-action (flutter-version from `skeleton/.fvmrc` through `jq`, see below; cache: true)
      - flutter pub get
      - dart run build_runner build -d
      - dart run tool/generate_tokens.dart                    # tokens.g.dart is not made by build_runner
      - git diff --exit-code                                  # stale generated files (injection.config.dart, tokens.g.dart)
      - flutter analyze --fatal-infos
      - flutter test --exclude-tags golden --dart-define=STRESS=full
      - upload-artifact test/**/failures/ (if: failure())
      - flutter build web --release
  template:
    needs: skeleton
    steps: checkout, flutter setup, dart pub global activate mason_cli <pinned>,
           dart run tool/create_app.dart ci_app --out /tmp, then in /tmp/ci_app: flutter analyze, flutter test --exclude-tags golden
```

- Flutter version: `subosito/flutter-action` reads `flutter-version-file`, which expects a `pubspec.yaml`
  environment constraint, not `.fvmrc`. The version file is `skeleton/.fvmrc` (the repository root has none). The workflow therefore takes the version with a small first step
  (`echo "v=$(jq -r .flutter .fvmrc)" >> $GITHUB_OUTPUT`, run with the job's `working-directory: skeleton`) and passes `flutter-version: ${{ steps.v.outputs.v }}`.
- `*.freezed.dart` is in `skeleton/.gitignore`, so `git diff --exit-code` guards only `injection.config.dart` and, with the
  added generator step, `tokens.g.dart`. Stale freezed output would fail `analyze` or tests instead.
- `mason_cli` pinned to the version in `mason-lock.json`/README (0.1.4). The Brick test runs inside the `skeleton` job's
  `flutter test`, so the mason install step goes before it in that job, and the `template` job reuses nothing.
- No `kit` steps, no golden comparison. `spike-pages.yml` is not touched.
- Local verification (Req 18.9): `test/repo_tools/ci_workflow_test.dart` parses the YAML with the `yaml` package (a
  dev dependency already present), asserts the jobs, triggers, the absence of `kit`, that every `run` line starts
  with an allowed command, and that `spike-pages.yml` has the fixed SHA-256 `ca14a184c8ff110b4e6d41d3554c97d074fa536a4010c1d84aafbeaa5d3a46d5`
  (a constant in the test, last changed in commit `ec47d7e`; comparing with `git show HEAD:` would never fail after a
  commit, and `origin/main` may be missing in a shallow clone, R4 SF14b). A `[kode]` task runs each `run` step in order in a clean clone in a temp folder and records
  the commands and exit codes in a report (no script is added for this).
  `actionlint` runs when installed.
- First hosted run: user task after push (D11).

---

## Error handling

| Where | Failure | Handling |
|---|---|---|
| `ErrorView` | any `Failure` | localized fixed text, never `failure.message` |
| `AppButton` loading | press while loading | ignored (no-op `onPressed` and `IgnorePointer`, D16; no dimming) |
| `AppPill.copy` | `onCopy` returns false or throws | tick reverted at once, no toast, exception swallowed after `AppLogger.e` |
| `AppTextField` | validator throws | treated as valid, error logged, never crashes the form |
| `AppDialog` / `AppSheet` | route popped while animating | controllers disposed in `dispose`, no setState after dispose (mounted checks) |
| `create_app` | invalid name, target exists | exit 64 before any write |
| `create_app` | pattern missing in platform file | `flutter create` fallback, report which file |
| `sync_core` | conflict | diff printed, exit 1, nothing written |
| harness | failed render | label in message, failure image best effort |
| goldens | non-macOS | `fail` with a clear message |

Process-spawning tools return the child exit code, print the failing command, and never swallow a non-zero exit.

---

## Testing strategy

- Every widget has `<name>_test.dart` with: a behaviour group (examples of every rule in its requirement: roles, sizes,
  loading, disabled, reduced motion, hit area at touch, semantics), a `stressTest`, and for interactive widgets the
  accessibility run. Reduced motion is driven by `MediaQuery(disableAnimations: true)` around the host.
- Every widget has `<name>_golden_test.dart` (tag `golden`), one gallery image per theme.
- Architecture test additions (A4): the Material visual ban for `app`, `core/widgets`, `core/layout`, `features` (list extended), `Scaffold`
  only in `adaptive_scaffold.dart` plus the dated `app/router/app_shell.dart` exception; the reserved-name rule is removed and the existing test
  `'Material buttons and reserved names'` is rewritten; the home layer rules; the "no `CATALOG.md`" rule lives in the catalog test.
- `test/core/catalog_blocks_test.dart` (WID002 stand-in) and `test/core/core_widget_coverage_test.dart` (UI005 stand-in) read
  `core_widget_inventory.dart`.
- Quality gate: `dart run tool/check.dart` runs `dart format --set-exit-if-changed lib test tool`, build_runner, analyze, and
  `flutter test --exclude-tags golden,e2e` (quick profile). The bricks test is tagged `slow` with a 10 minute timeout, not `e2e`, so it
  runs in the gate and skips when `mason` or the network is missing (R4 SF6, BL8).
  Task A2 changes `tool/check.dart` to pass the exclude flag, and extends its test if one exists.
- Not PBT: the spec has two properties (stress samples, mapper). They run with a fixed seed.

---

## Sequencing and dependencies

```
P1 strings ─ A1 stress ─ A2 golden ─ A3 inventory+scanners ─ A4 architecture ─ A5 tokens ─ A6 a11y ─ A8 API compile check (A7 stressProperty, optional)
                                                                                   │
   lanes in parallel after A8:                                         ▼
   B action (B1..B4)   C layout (C1..C5)   D input (D1..D4)   E content (E1..E4)
   F feedback (F1..F4) G overlay (G1..G2)   S sync_core (S1..S2, S2 after J1)   J create_app (J1..J3)
   B2 AppButton before: C4 ActionGroup, F2 ErrorView, F4 AppToast (no), G2 showConfirm
   B3 AppIconButton before: D2 SearchField, G2 AppDialog
   D1 AppTextField before: D2 SearchField, G2 AppDialog
   D3 AppSegmented before D4 ThemeModeSwitch
   C2, C5, B2, C4, D4, E2, E3, E4, F1..F3 before H4/H5 (home)
   H before: I (bricks), J4 and J5 (create_app --clean and the e2e run), K (CI)
   everything before: Z (README, strict inventory, full gate), then [manual] tasks M1..M4
```

### Shared files and owners

| File | Owner | Others |
|---|---|---|
| `pubspec.yaml`, `pubspec.lock`, `dart_test.yaml`, `.gitignore`, `lib/core/theme/tokens.g.dart`, `tool/src/ladders.dart`, `tool/src/palette.dart`, `lib/core/theme/tactile/motion.dart` | lane P | read only; ask P |
| `test/helpers/*` | lane P | read only |
| `test/architecture/architecture_test.dart` | A4, then H1, then Z2 | no one else |
| `lib/core/l10n/app_en.arb`, `app_id.arb` | P1 (core strings), H3 (home strings), H6 (removal and rename). A lane that needs another string asks lane P (R4: the old "append at the end" rule contradicted the single-owner rule) | conflicts keep both sides, then `flutter gen-l10n` |
| `lib/app/di/injection.config.dart`, `*.freezed.dart`, `*.g.dart` | generated | regenerate after every merge, never hand edit. Lanes run in sequence for tasks that regenerate it (F4, H2, H3, H5), conflicts are resolved by regenerating |
| `lib/app/**` | lane H | read only |
| `README.md` | Z1 | lanes leave notes in `spikes/crew-run/S5-<task>.md` |
| `test/core/core_widget_coverage_test.dart`, `catalog_blocks_test.dart` | A3, flipped to strict by Z2 | read only |
| `lib/core/widgets/<x>.dart`, `test/core/widgets/<x>*_test.dart`, `goldens/<x>_*.png` | the lane that owns widget `<x>` | read only |
| `bricks/**`, `mason.yaml`, `mason-lock.json` | I1 to I6 | |
| `tool/create_app.dart`, `tool/src/create_app_*`, `test/repo_tools/create_app_test.dart` | J1 to J5 | |
| `tool/sync_core.dart`, `tool/src/sync_core_*`, `test/repo_tools/sync_core_test.dart` | S1, S2 | |
| `.github/workflows/ci.yml`, `test/repo_tools/ci_workflow_test.dart` | K1 | |

---

## Revision notes

- R1 (S3 review answers): Q2 CI verification is local plus a manual first hosted run (D11). Q5 no `integration_test/`
  (D10). Q6 "Check connection" removed (D9). Q1, Q3, Q4, Q7 to Q10 use the S3 defaults.
- R2 (found while designing): the architecture test reserves the five layout names (`_reservedNames`) and forbids
  Material controls only in `lib/app`. Task A4 removes the reservation and extends the Material ban.
- R3: `kiri_check` cannot drive a `WidgetTester` directly (it depends on `package:test`), so `stressProperty` has a spike and
  two fallbacks (see the section above).
- R4: `subosito/flutter-action` does not read `.fvmrc`, so the workflow reads the version with `jq`.
- R5: Req 13.5 says `HomeView` renders inside `AdaptiveScaffold`. The shell owns `AdaptiveScaffold` (Req 8.5), so `HomeView`
  is the body, and the shell goldens (Req 12.3) and `HomeView` goldens show the combination.
- R6: Req 4.8 (theme persists after restart) is covered by a cubit-level restart test, because `AppSettingsCubit` already
  persists; the widget only calls it.
- R7 (S5, after review R4): BL1/BL2 tokens come from generator code and `motion.dart`, not `tokens.yaml` (D13). BL3 option (b)
  (D3). BL4 loading and disabled (D16). BL5 `Scaffold` rule with a dated exception. BL6 no duplicate ARB keys. BL7 helper types
  and scanner scope (D15). BL8 bricks excluded from format and analyze. BL9 no `app_root_test.dart`. BL10 dependency fixes. SF11
  language picker kept (`LanguageSwitch`). SF4 `TickerMode` (D14). SF5 counts 48 and 384. SF13 Inter in the stress harness.
  Details per item are in `spikes/crew-run/S5-spec-fixes.md`.

## API compile check (task A8)

Before any widget task starts, task A8 copies every public signature of the "Components and interfaces" section into one scratch
file `lib/core/_api_stubs.dart` (class bodies are `throw UnimplementedError()` or empty), runs `flutter analyze`, fixes the
design where the analysis finds a wrong type or name, records the result in `spikes/crew-run/S5-A8.md`, and deletes the
scratch file. The task commits only the report and design corrections. This catches an API that does not compile
(`HueRole`, `AppOverlay`, `palette.scrim`, `AppTextField` slots) before eight lanes depend on it (R4 suggestion 4).

## Risks

- `kiri_check` and `WidgetTester` (R3). Not blocking: fallback exists.
- Golden pixel stability on this Intel Mac (Req 11.7). Reported as a finding if two runs differ.
- Run time of the `full` stress profile for 25 widgets. Grouping per (size, scale, theme, input) keeps it bounded; the
  final task records the time, and CI runs `full` once.
- Spring-based `AppSegmented` and `tester.pumpAndSettle`: springs settle, but a never-ending `SkeletonBlock` animation never
  does, so tests use `pump(Duration)`.
- `AdaptiveScaffold` keeping page state across window classes depends on `KeyedSubtree` with a `GlobalKey`; one test
  resizes the window across 768 and 1200 and checks that a `StatefulWidget` in the body keeps its state.
