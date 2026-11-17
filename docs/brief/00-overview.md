# 00 — Overview

## One-line pitch

A lean Flutter skeleton (Clean Architecture + BLoC, feature-first) that ships with a Kiro toolkit, so an
AI agent asks before it builds, reuses before it duplicates, and checks its UI before it says "done".

## Problem

Developers who use AI agents to build Flutter apps from API docs and design images hit the same failures:

| # | Failure | Example |
|---|---|---|
| P1 | Agent executes API docs without understanding the feature | User drops an OpenAPI file; agent generates clients for all 40 endpoints without asking which feature they serve |
| P2 | Reusable widgets end up inside one feature | A card used on 3 screens is created in `features/orders/presentation/widgets/` |
| P3 | Existing reusable widgets get duplicated | A new design contains a card that already exists in `core/`; agent writes a second one |
| P4 | API spec updates are applied by guesswork | User says "update the docs"; agent edits random files and misses a renamed field |
| P5 | UI updates without a location | User sends an image "update this" with no screen name; agent edits the wrong screen, or edits a shared widget and breaks other screens |
| P6 | Fragile UI | Text in a card overflows with long data, large text scale, or narrow screens |
| P7 | Poor composition | Random paddings, radii, font sizes; no consistent visual system |

Root cause: the agent writes code **without a comprehension step** and **without knowing what already exists**.

## Solution

Two layers, both shipped inside the skeleton:

1. **Workflows** (Kiro skills + steering) make the agent follow a process: summarize → ask → confirm → scaffold → implement → check.
2. **Guards** (Dart scripts called by Kiro hooks and CI) catch violations deterministically, even when the agent ignores instructions.

| Problem | Workflow | Guard |
|---|---|---|
| P1 | Skill `api-intake` | Hook blocks writes to `data/` for features not mapped in `api_map.yaml` |
| P2 | Skill `design-to-ui` classifies every component; skill `promote-widget` | `kit check`: cross-feature imports forbidden; similar-name warning |
| P3 | Widget catalog (generated) always in context; `design-to-ui` matches against it | `kit check` WID001 similar-widget warning |
| P4 | Skill `api-update` driven by `kit api diff` + `kit api impact` | Generated DTOs locked against manual edits |
| P5 | Skill `ui-update` driven by screen registry + `kit usages` | Agent must confirm location; shared-widget change requires explicit choice |
| P6 | Steering `ui-resilience.md` | Stress test harness (widths × text scales × data); `kit check` UI005 requires stress tests |
| P7 | tactile-design language: vendored skill (decision order, rules) + Flutter adaptation in steering `design-language.md` + tokens + core widgets; design conflicts in reference images are asked about; `ui-reviewer` agent | `kit check` UI001–UI004 (literal values) and TAC001–TAC010 (Material visuals in features, bold, hand-made shadows, curves, one primary, copy rules, contrast, hue collisions); `kit tokens` contrast gates |

## Product = skeleton + toolkit; proof = two apps

- `skeleton/` is the product: a Flutter project template plus its `.kiro/` toolkit, `kit` CLI, and Mason bricks.
- `app_orbit/` (spaceflight news reader, API-driven) and `app_tally/` (expense tracker, design-driven) are
  generated from the skeleton with `tool/create_app.dart`, then built **using the toolkit in Kiro**.
  They prove the skeleton is flexible and the toolkit works.

## Decisions

| Topic | Decision |
|---|---|
| Category | Skeleton Crew |
| Team | Solo developer; target users are also solo Flutter developers |
| Kiro surfaces | Kiro IDE primary: every spec and every demo (Phases 3–4 always run in the IDE). Kiro CLI runs the toolkit scenarios (`06` §8). Kiro Crew runs long task lists in Phases 1–2 on its own git branch |
| Platforms | Android, iOS, Web, macOS/Windows/Linux. Layout driven by 3 width classes: Mobile (< 768), Tablet (768–1199), Desktop (≥ 1200) |
| Design language | tactile-design (Kosta / 4hands, MIT) adapted to Flutter (`04-design-system.md`); Material 3 only as infrastructure; deviations: 48 touch hit area, bottom tab bar on mobile, platform-based touch detection |
| Theme | Real-world apps, not Halloween-themed |
| Template form | Single Flutter project, copied by script. No monorepo/Melos |
| Scaffolding | Mason bricks stored locally in the skeleton |
| Determinism | Anything with a consistent output is a script, not an LLM task |
| Language | English for all repo content; skills reply in the user's language |
| License | MIT |

## Success criteria

The project is done when all of these are true:

1. `dart run tool/create_app.dart <name>` produces an app that runs on web, Android, iOS, and macOS, passes `flutter analyze`, `kit check`, and `flutter test`.
2. Each of P1–P7 has a working workflow and, where listed, a working guard, demonstrated in video.
3. Orbit and Tally are deployed to public URLs and look correct at 375, 834, and 1440 px width, in light and dark.
4. Repo satisfies every item in `01-hackathon-requirements.md`.
5. Video < 3 minutes and write-up are published.
6. The toolkit scenarios in `06-kiro-toolkit.md` §8 pass in Kiro IDE, and the scripted ones also pass in Kiro CLI.

## Non-goals (for the hackathon)

- Firebase integration (abstractions only; future skill `add-firebase`).
- Authentication in the skeleton (login, token storage, refresh). The no-op auth interceptor is the extension point,
  the user guide explains how to add auth, and `api-intake` says so when a spec needs it. Orbit and Tally need no auth.
- Supporting every OpenAPI construct in DTO generation (subset; see `05-kit-cli.md`).
- Full Kiro Crew hook support.
- Localization beyond English + Indonesian strings in Tally.
- Tactile components the demo apps don't need: tables, switches, menus, status dots (stretch only).
- Editing the vendored tactile-design skill. Project changes go into `design-language.md`.

## Decision log

These decisions are settled. Don't reopen them without a new reason; ask the user if one seems wrong.

| Date | Decision | By |
|---|---|---|
| 13 Nov 2026 | Skeleton Crew, solo; Flutter, Clean Architecture, BLoC, feature-first; Kiro IDE primary, CLI compatible, Crew partial | user |
| 13 Nov 2026 | Two real-world apps (not Halloween-themed): Orbit and Tally; api-update and ui-update in the MVP; Mason bricks; single-project template copied by script | user |
| 15 Nov 2026 | tactile-design is the **default** design language, so generated UI doesn't look like generic AI output | user |
| 15 Nov 2026 | Deviations from tactile accepted: mobile < 768, 48 touch hit area, bottom tab bar on mobile (`04` §2) | user |
| 15 Nov 2026 | Primary action stays neutral (ink-12, tactile default) in both apps | user |
| 15 Nov 2026 | Fonts: Orbit Inter + Space Grotesk for display/section titles; Tally Plus Jakarta Sans | user |
| 15 Nov 2026 | Tally shows income in the info hue (blue, "money in"), expense in ink-12, over budget in danger | user |
| 15 Nov 2026 | The brief is downloaded, not pushed; the user creates the public repo in Phase 0 (`15-github-repo-guide.md`) | user |
| 17 Nov 2026 | Review items accepted: platform setup, web image fallback, Tally sample data, Mac-only goldens, `create_app` naming, user guide, baseline recordings, toolkit scenarios, smaller specs, Kiro spec PBT + Analyze Requirements + powers, branding, stress profiles, `AppSettings`, accessibility checks, Orbit offline cache, new cut order | user |
| 17 Nov 2026 | `AppSettings` theme: System (default, follows the device), Light, Dark; saved across restarts. Both apps follow the device until the user picks a theme | user |
| 17 Nov 2026 | Tally's "Load sample data" is a deliberate exception to tactile's "never show fake data": the user starts it, it is labelled, and it can be deleted | user |
| 17 Nov 2026 | Auth stays out of the skeleton for the hackathon; documented extension point only | user |
| 17 Nov 2026 | Entering the Best Student Project bonus (Skeleton Crew). Paid Kiro plan, so headless Kiro CLI runs with an API key are available | user |
