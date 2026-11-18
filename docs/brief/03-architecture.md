# 03 — Skeleton architecture

## 1. Principles

- **Lean**: the skeleton contains only what every app needs. If only one demo app needs it, it goes in that app.
- **Feature-first Clean Architecture**: `features/<name>/{data,domain,presentation}`.
- **Predictable for agents**: one way to do each thing, one place for each file type, generated files clearly marked.
- **Checkable**: every rule in §5 is enforced by `kit check` (rule codes in `05-kit-cli.md` §8).
- **One design language**: tactile-design adapted to Flutter (`04-design-system.md`). Feature code composes core
  widgets; it never styles Material widgets directly.

## 2. Stack

Pin exact versions in Phase 1 (latest stable at that time) and record them in `skeleton/README.md`.
Flutter: latest stable at project start (3.50 at the time of writing); FVM optional (`.fvmrc` included).

| Need | Package | Notes |
|---|---|---|
| State | `flutter_bloc`, `bloc_concurrency` | Bloc for async events; Cubit allowed for pure UI state |
| Immutability/unions | `freezed`, `freezed_annotation` | States, events, entities, DTOs |
| JSON | `json_serializable`, `json_annotation` | DTOs only |
| DI | `get_it`, `injectable`, `injectable_generator` | Annotations; never edit `injection.config.dart` |
| Functional result | `fpdart` | `Either<Failure, T>` |
| HTTP | `dio` | Single client from `core/network` |
| Routing | `go_router` | All routes in `lib/app/router/routes.dart` |
| Key-value storage | `shared_preferences` | Behind `KeyValueStore` interface in core |
| Formatting | `intl` | Dates, numbers, currency, plurals, compact numbers |
| Images | `cached_network_image` (Android, iOS, desktop); `Image.network` on web | Inside the core `AppNetworkImage` (created in Orbit, synced back). On web, Flutter falls back to an `<img>` element for images served without CORS **[VERIFY S24]** |
| URL opening | `url_launcher` | Wrapped by the core `LinkLauncher` service |
| Icons | `lucide_icons_flutter` with `LucideIcons300` (S23) | One icon set for the whole UI; fallback Material Symbols Rounded weight 300 |
| Fonts | Inter Medium (bundled, SIL OFL) | One weight (tactile one-weight rule); apps may swap via `tokens.yaml` |
| Branding | `flutter_launcher_icons`, `flutter_native_splash` (dev) | App icons, native splash, and the web loading screen from `assets/branding/` |
| Lints | `very_good_analysis` | Plus custom rules via `kit check` |
| Codegen | `build_runner` | |
| Test | `flutter_test`, `bloc_test`, `mocktail` | The `flutter_test` accessibility guideline matchers run inside the stress harness (`04` §12) |
| PBT | `kiri_check` (S10) | Maintained, Dart 3 constraint, stateful tests; fallback `glados` |
| Toolkit | `kit` (path dev_dependency `tool/kit`) | Depends on `analyzer`, `yaml`, `args`, `path`, `crypto`, `glob` |

App-only packages: Tally adds `drift`, `drift_flutter`, `sqlite3_flutter_libs`. Orbit adds nothing beyond the
skeleton. No chart package: charts are simple bars (`AppBarChart`, `04` §7).

Material is infrastructure only (routes, text editing, semantics, scrolling, tooltips). Ripples are disabled and
visuals come from the theme mapping (`04` §9) and core widgets.

## 3. Layers and dependency rules

```
presentation ──► domain ◄── data
      │                       │
      └────────► core ◄───────┘        domain may import only core/error, core/usecase, fpdart, freezed_annotation
```

| Layer | Contains | May import | Must not import |
|---|---|---|---|
| `domain/` | entities, repository interfaces, usecases | `core/error`, `core/usecase`, `fpdart`, `freezed_annotation`, `meta` | Flutter, dio, json, `data/`, `presentation/`, other features |
| `data/` | DTOs, datasources, repository impls, mappers | own `domain/`, `core/*` (not `core/widgets`, `core/theme`, `core/layout`), dio, json | `presentation/`, other features |
| `presentation/` | blocs/cubits, pages, views, feature widgets | own `domain/`, `core/*`, Flutter | own `data/`, other features, Material visual widgets listed in TAC001 |
| `core/` | shared infrastructure + design system + widgets | Flutter, packages | any `features/*` |
| `app/` | bootstrap, router, DI root, shell | everything | — |

Cross-feature navigation uses route names from `app/router/route_names.dart`, never imports.
Cross-feature data sharing: move the shared concept to `core/` (rare) or keep a small feature-local entity (preferred).

## 4. `lib/` contents

```
lib/
├── main.dart                      # calls bootstrap()
├── app/
│   ├── app.dart                   # MaterialApp.router; themeMode + locale from AppSettingsCubit; theme rebuilt per window class + input mode
│   ├── bootstrap.dart             # bindings, configureDependencies(), Bloc.observer, error handlers
│   ├── env.dart                   # Env.fromDartDefines()
│   ├── di/injection.dart          # @InjectableInit; injection.config.dart is generated
│   └── router/
│       ├── routes.dart            # the ONLY place GoRoute is declared
│       ├── route_names.dart
│       └── app_shell.dart         # AdaptiveScaffold with the app's destinations
├── core/
│   ├── error/                     # failure.dart (sealed), exceptions.dart
│   ├── usecase/usecase.dart
│   ├── network/                   # api_client.dart, interceptors/ (auth is a no-op extension point), dio_error_mapper.dart (guardRepository)
│   ├── storage/key_value_store.dart
│   ├── settings/                  # AppSettings (themeMode system|light|dark, default system; locale system|en|id),
│   │                              #   AppSettingsCubit, saved through KeyValueStore
│   ├── services/link_launcher.dart, clipboard_service.dart
│   ├── theme/
│   │   ├── tokens.g.dart          # GENERATED by kit tokens
│   │   ├── app_theme.dart         # buildTheme(brightness, windowClass, inputMode) (04 §9)
│   │   ├── theme_x.dart           # context.surface, context.text, context.sizes, context.hue(), context.reduceMotion
│   │   └── tactile/
│   │       ├── surface.dart       # SurfaceKind, SurfaceScope, TactileSurface (04 §5)
│   │       ├── shadows.dart       # recipe → List<BoxShadow> per surface and theme
│   │       ├── pressable.dart     # press scale, hover fill, focus ring, semantics, 48 hit area on touch
│   │       ├── typography.dart    # AppTypography ThemeExtension (04 §6)
│   │       └── motion.dart        # AppMotion, AppSprings, page transition builder, reduced motion
│   ├── layout/
│   │   ├── window_class.dart      # WindowClass, InputMode, context extensions
│   │   ├── adaptive_scaffold.dart # rail + floating panel + top strip / tab bar (04 §7)
│   │   ├── adaptive_builder.dart  # AdaptiveBuilder(mobile:, tablet:, desktop:)
│   │   ├── page_column.dart       # PageColumn.reading / .data / .form
│   │   ├── adaptive_grid.dart
│   │   └── action_group.dart      # desktop row vs mobile stack
│   ├── widgets/                   # see §6; CATALOG.md is generated
│   ├── l10n/                      # ARB files (en, id), generated localizations
│   └── utils/                     # formatters (date, number, money, compact), debouncer, extensions
└── features/
    └── home/                      # example feature (removed by create_app --clean)
```

## 5. Conventions (enforced or checked)

### Files and naming
- One public class per file; file name = snake_case of the class name.
- Suffixes: `*_dto.dart`, entity files without suffix (class `Article`), `*_repository.dart` (interface),
  `*_repository_impl.dart`, `*_remote_data_source.dart`, `*_local_data_source.dart`, `*_mapper.dart`,
  `*_usecase.dart` (class `GetArticles`), `*_bloc.dart` / `*_event.dart` / `*_state.dart`, `*_page.dart`, `*_view.dart`.
- `XPage` provides blocs and is referenced by routes; `XView` renders. Tests target `XView` with mock blocs.

### Data layer
- Remote data sources return DTOs or throw `*Exception`. Never return `Either`.
- Repository impls wrap calls with `guardRepository(() async {...})`, which maps exceptions to `Failure`.
- DTO ↔ entity conversion only in `*_mapper.dart` as extension methods.
- DTOs generated by `kit api gen-dto` carry a header; never edit them by hand (GEN001).

### Domain layer
- Entities: freezed, no JSON annotations. One usecase per operation.

### Presentation layer
- Loading pages use one freezed union: `initial | loading | success(data) | empty | failure(Failure)`.
  Paginated lists use one state class with `status`, `items`, `hasReachedEnd`, `failure`, `query`.
- Search/query events: `restartable()` + 400 ms debounce. Pagination: `droppable()`.
- Every data page renders all states with core widgets: `LoadingView`, `EmptyState`, `ErrorView` (with "Try again").
- **UI is composed from core widgets.** Material visual widgets (buttons, cards, chips, list tiles, dialogs,
  sheets, snackbars, switches, segmented buttons, menus) are not used in `presentation/` (TAC001).
- No raw `BoxShadow`, `Border`, colour literals, font sizes, font weights, curves, or durations in widget code
  (UI001–UI004, TAC002–TAC005). Use tokens, `TactileSurface`, and core widgets.
- One primary action per page, view, or dialog (TAC006).
- User-facing strings go through l10n (`context.l10n.x`, UI006) and follow the copy rules (`04` §10, TAC007–TAC008).
- No business logic in widgets. No `setState` for data.

### DI
- `@lazySingleton` for clients, data sources, repositories; `@injectable` for usecases and blocs.

### Errors and logging
- `bootstrap()` routes `FlutterError.onError` and `PlatformDispatcher.instance.onError` to a core `Logger`.
- `ErrorView` maps each `Failure` subtype to a localized two-line message.

### Environment
- `--dart-define-from-file=env/<flavor>.json`; `env/example.json` committed; no secrets in code, steering, or skills.

### Platform setup (part of the skeleton; `create_app` keeps it)
- Android: `<uses-permission android:name="android.permission.INTERNET"/>` in
  `android/app/src/main/AndroidManifest.xml`. The Flutter template allows network access only in debug and profile
  builds, so a release APK without it can't load data
  ([Flutter docs](https://docs.flutter.dev/deployment/android)).
- Android: if `canLaunchUrl` is used, add the `<queries>` entry for `https` links from the url_launcher README.
- macOS: `com.apple.security.network.client` set to `true` in both `DebugProfile.entitlements` and
  `Release.entitlements`. Without it, requests fail with "Operation not permitted"
  ([Flutter docs](https://docs.flutter.dev/platform-integration/macos/building)).
- iOS: nothing extra for HTTPS.
- Web: `flutter_native_splash` adds the loading screen to `web/index.html`; set the title, description, favicon, and an
  Open Graph image (`og.png`).
- `kit doctor` and `kit check` (PLAT001, PLAT002) verify the permission and the entitlement whenever `dio` is a dependency.

## 6. Core widgets

Every core widget has a `{@catalog}` doc block (`05-kit-cli.md` §5), a stress test, and goldens (light + dark).

### 6.1 Shipped in the skeleton (Phase 1)

| Category | Widget | Notes (rules in `04` §7) |
|---|---|---|
| primitive | `TactileSurface` | fill, edge, drop from the parent surface; provides `SurfaceScope` |
| primitive | `Pressable` | press scale, hover/pressed fill, focus ring, semantics, hit area |
| action | `AppButton` | roles: primary, secondary, ghost, destructive, destructiveConfirm; sizes regular/compact; leading icon; loading |
| action | `AppIconButton` | 22 / 28 / 44 |
| action | `AppPill` | utility pill; copy-feedback mode |
| input | `AppTextField` | well, label, help, error |
| input | `SearchField` | well (raised on mobile light), clear button, debounced callback |
| input | `AppSegmented` | sliding pill; page-level variant with icons |
| input | `ThemeModeSwitch` | System / Light / Dark on the page-level `AppSegmented` with icons; reads and writes `AppSettingsCubit` |
| content | `AppCard` | `.data`, `.clickable` |
| content | `AppRow` | plain list row |
| content | `SectionHeader` | title, description, actions |
| content | `AppBadge` | `.tone(hue)`, `.neutral` |
| feedback | `EmptyState`, `ErrorView`, `LoadingView`, `SkeletonBlock` | |
| feedback | `AppToast` + `ToastController` | |
| overlay | `AppDialog` + `showConfirm` | becomes a sheet on mobile |
| overlay | `AppSheet` | grab handle, card of rows, buttons below |
| layout | `AdaptiveScaffold`, `PageColumn`, `AdaptiveGrid`, `AdaptiveBuilder`, `ActionGroup` | |

### 6.2 Created while building the demo apps (through the toolkit, then synced back)

These are generic, so `design-to-ui` must classify them as **new core**. That is part of the P2 demo.

| App | Widgets |
|---|---|
| Orbit | `MediaCard`, `AppNetworkImage`, `PagedListView`, `AppChoiceList`, `FilterPill` |
| Tally | `Figure`, `Meter`, `AppBarChart`, `AmountText`, `PeriodSwitcher`, `AppChoiceTiles` |

After each app phase, `tool/sync_core.dart --from app_<x> --to skeleton` copies new core widgets (with tests and
goldens) back into the skeleton (`02-repository-structure.md`). Tally is created after the Orbit sync, so it starts
with Orbit's widgets.

Stretch (not needed by the demo apps): `AppSwitch`, `AppMenu`/`AppSelect`, `StatusDot`, `AppTable`.

## 7. The `home` example feature

Minimal but complete: a page in `AdaptiveScaffold` with a `SectionHeader`, a list of `AppRow`s from a cubit and a
usecase reading a static local list, a secondary and a primary action, all 4 states, one feature widget, bloc test,
stress test, and goldens. It exists so agents and users can copy a known-good pattern, and so every `kit check`
rule has a passing example. The page also shows `ThemeModeSwitch`, so a new app can switch themes from day one.
