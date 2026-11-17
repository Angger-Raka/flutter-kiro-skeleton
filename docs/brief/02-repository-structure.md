# 02 — Repository structure

## Top level

```
flutter-kiro-skeleton/
├── .kiro/                         # used to BUILD this repo (judged)
│   ├── specs/                     # skeleton-foundation, core-widgets-and-templates, kit-check-tokens, kit-api, kiro-toolkit, release
│   ├── steering/                  # brief.md, brief-architecture.md, brief-design.md, brief-kit.md, repo-conventions.md
│   ├── hooks/                     # development hooks for this repo
│   └── settings/mcp.json          # Dart and Flutter MCP server (+ optional Figma)
├── skeleton/                      # PRODUCT: Flutter template + toolkit
├── app_orbit/                     # demo app 1, generated from skeleton/ (has its own .kiro/specs/orbit/)
├── app_tally/                     # demo app 2, generated from skeleton/ (has its own .kiro/specs/tally/)
├── tool/
│   ├── create_app.dart            # skeleton/ → new app folder
│   ├── sync_core.dart             # copy new core widgets from an app back into skeleton/
│   └── scenarios/                 # toolkit scenario prompts + run.sh for Kiro CLI (06 §8)
├── spikes/                        # Phase 0 experiments + baseline_app/ (plain Flutter, no toolkit)
├── docs/
│   ├── brief/                     # this brief
│   ├── kiro-journal.md            # running log for the write-up
│   └── assets/                    # screenshots, diagrams for README/Devpost
├── .github/workflows/             # ci.yml, deploy-pages.yml
├── THIRD_PARTY_NOTICES.md         # tactile-design, Radix Colors, fonts, icons, SNAPI terms
├── LICENSE                        # MIT
└── README.md                      # pitch, quick start, links to apps and video, credits
```

Kiro loads `.kiro/` from the workspace root it opens. Open the repo root for Phases 0–2 and 5. Open `app_orbit/` or
`app_tally/` as its own workspace for Phases 3–4, so only the product toolkit guides the agent. Each app keeps its own
spec in its own `.kiro/specs/`, and gets a copy of its brief document at `docs/app-brief.md` (`#[[file:]]` references
cannot reach outside the workspace).

## `skeleton/` (and every generated app)

```
skeleton/
├── .kiro/
│   ├── steering/                  # see 06-kiro-toolkit.md §2 (incl. design-language.md)
│   ├── skills/
│   │   ├── tactile-design/        # VENDORED (MIT) at commit 30495a2: SKILL.md, LICENSE, references/
│   │   └── api-intake/ api-update/ design-to-ui/ ui-update/ promote-widget/ new-feature/
│   ├── hooks/                     # kit-guards.json
│   ├── agents/                    # flutter-dev.md, ui-reviewer.md
│   └── settings/mcp.json          # dart mcp-server (+ figma, disabled)
├── api/
│   ├── openapi.yaml               # current API snapshot (absent if the app has no API)
│   ├── api_map.yaml               # endpoint → feature → files
│   └── CHANGELOG.md               # API changes applied, newest first
├── design/
│   ├── tokens.yaml                # tactile knobs (04 §4.1)
│   └── references/<feature>/      # design images from the user, named <screen>.<n>.png
├── assets/
│   ├── fonts/                     # one static weight per face (Inter-Medium.ttf by default) + OFL.txt
│   └── branding/                  # icon.png (1024), icon_foreground.png, splash.png, og.png; placeholders the apps replace
├── bricks/                        # Mason templates: feature/ page/ bloc/ usecase/ core_widget/
├── mason.yaml
├── tool/
│   ├── kit/                       # Dart package: the kit CLI (path dev_dependency), incl. radix_colors.g.dart
│   └── kit.sh, kit.ps1            # wrappers used by hooks
├── lib/
│   ├── main.dart
│   ├── app/                       # app.dart, bootstrap.dart, router/, di/
│   ├── core/                      # see 03-architecture.md §4
│   └── features/<feature>/{FEATURE.md, data/, domain/, presentation/}
├── test/                          # mirrors lib/; test/helpers/ holds the stress harness
├── docs/
│   ├── SCREENS.md                 # generated screen registry
│   ├── DESIGN_TOKENS.md           # generated token + contrast report
│   ├── toolkit-testing.md         # hook tests and skill scenarios (06 §8)
│   └── guide/                     # user guide for developers who use the skeleton (06 §9)
├── web/  android/  ios/  macos/  windows/  linux/
├── analysis_options.yaml
├── pubspec.yaml
└── README.md                      # how to use the skeleton with Kiro; design language credit
```

The skeleton ships with **one example feature** (`home`) so that every generated file type, test type,
and check has a working example. `create_app` keeps it by default; `--clean` removes it.

## `tool/create_app.dart`

Usage:
```
dart run tool/create_app.dart <package_name> [--dir <folder>] [--org com.example] [--display-name "My App"] [--out .] [--clean]
```

Behavior:
1. Validate `package_name` is a valid Dart package name. The target is `<out>/<dir>`; `--dir` defaults to the package
   name (the demo apps use `--dir app_orbit` and `--dir app_tally`). Fail if the target exists.
2. Copy `skeleton/` to the target, excluding `build/`, `.dart_tool/`, `*.iml`, `.idea/`, `pubspec.lock`. Real files
   only, no symlinks (the vendored skill must be a copy).
3. Replace the package name in `pubspec.yaml` and every `package:skeleton/` import.
4. Set bundle/application IDs for Android (`applicationId`, `namespace`), iOS/macOS (`PRODUCT_BUNDLE_IDENTIFIER`),
   Linux (`APPLICATION_ID`), Windows (`BINARY_NAME`), web (`manifest.json` name/short_name, `index.html` title).
   Prefer `flutter create --org <org> --project-name <name>` into a temp dir and copying its platform folders
   if text replacement proves fragile **[VERIFY in Phase 1]**. Either way, keep the platform setup from `03` §5
   (Android `INTERNET` permission, macOS network client entitlement).
5. Reset `api/openapi.yaml`, `api/api_map.yaml`, `api/CHANGELOG.md`, and `.kiro/steering/product.md` to templates.
   Branding placeholders stay until the app replaces them.
6. With `--clean`, remove the `home` example feature and its tests, references, and route.
7. If the target is not inside a git repository, run `git init` and make a first commit (`kit check --changed`
   relies on git).
8. Run `flutter pub get`, `dart run build_runner build -d`, `kit tokens`, `kit doctor`.
9. Print next steps: open the folder in Kiro and trust the workspace if asked (S26 checks whether hooks need it);
   fill `product.md`; adjust `design/tokens.yaml`; read `docs/guide/getting-started.md`.

Tests: an integration test in CI runs `create_app` into a temp dir and then `flutter analyze`, `kit check`, `flutter test` on the result.

## `tool/sync_core.dart`

Usage: `dart run tool/sync_core.dart --from app_orbit --to skeleton [--dry-run]`

1. Find core widgets (`lib/core/widgets/**`, `lib/core/layout/**`) present in `--from` and missing in `--to`.
2. Copy each widget with its stress test and goldens; rewrite `package:` imports.
3. If a copied file imports a package the target's `pubspec.yaml` lacks, add it with the source's version constraint
   and run `flutter pub get` (e.g. `cached_network_image` for `AppNetworkImage`).
4. Never overwrite an existing file; print a diff instead and stop.
5. Run `kit catalog`, `kit check`, and the copied tests in `--to`.

## Root `.kiro/` for developing this repo

| File | Purpose |
|---|---|
| `steering/brief.md` | always: points to `docs/brief/` (see the brief README) |
| `steering/brief-architecture.md` | fileMatch Dart under `lib/`: embeds 03 |
| `steering/brief-design.md` | fileMatch UI paths: embeds 04 and the vendored tactile `SKILL.md` |
| `steering/brief-kit.md` | fileMatch toolkit paths: embeds 05 and 06 |
| `steering/repo-conventions.md` | always: commit style (Conventional Commits), English only, never edit `app_*` code outside the app's own workspace when recording demos |
| `hooks/dev-format.json` | PostToolUse write `*.dart` → `dart format <file>` |
| `hooks/dev-skeleton-check.json` | Stop → if the skeleton changed, run `kit check` inside `skeleton/` (from Phase 2 on) |
| `settings/mcp.json` | `dart mcp-server` |
| `specs/<spec>/` | requirements.md, design.md, tasks.md for the 6 root specs in `11`; Kiro Crew may add a `TASK_PROGRESS.md` next to a spec (commit it) |

## `.gitignore` rules

- MUST NOT ignore `.kiro/` anywhere (check the `.gitignore` files Flutter generates).
- MUST NOT ignore `docs/SCREENS.md`, `docs/DESIGN_TOKENS.md`, `lib/core/widgets/CATALOG.md`, `lib/core/theme/tokens.g.dart`
  (agents and judges read them; CI verifies they are fresh).
- MUST ignore `.dart_tool/kit/` (compiled kit binary cache) and `test/**/failures/`.
