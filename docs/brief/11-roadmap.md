# 11 — Roadmap

Start: Tue 17 Nov 2026 (planning ran 13–16 Nov). Deadline: Fri 4 Dec 2026 14:00 PT (Sat 5 Dec 05:00 WIB). Internal
submit target: 4 Dec 20:00 WIB. Solo, 18 days. Every spec goes requirements → design → tasks in Kiro IDE.

| Phase | Dates | Kiro workspace | Specs | Main output |
|---|---|---|---|---|
| 0 | 17–18 Nov | repo root | — (vibe chat) | Repo, vendored skill, P0 spikes, credits requested |
| 1 | 19–22 Nov | repo root | `skeleton-foundation` (19–20), `core-widgets-and-templates` (21–22) | Runnable skeleton: platform setup, settings, tactile foundation, shell, core widgets, harness, bricks, `create_app` |
| 2 | 23–26 Nov | repo root | `kit-check-tokens` (23–24), `kit-api` (24–25, in Crew), `kiro-toolkit` (25–26) | `kit`, hooks, skills, steering, agents, scenarios, user guide v1, baseline recordings |
| 3 | 27–29 Nov | `app_orbit/` | `orbit` | Orbit built through the toolkit, recorded; core widgets synced back |
| 4 | 30 Nov–2 Dec | `app_tally/` | `tally` | Tally built through the toolkit, recorded; core widgets synced back |
| 5 | 3–4 Dec | repo root | `release` | Deploy, README, user guide final, video, write-up |
| — | 4 Dec 20:00 → 5 Dec 05:00 WIB | — | — | Buffer only |

Root specs live in `.kiro/specs/`. App specs live in each app's own `.kiro/specs/`: the app folder is opened as its
own workspace, so only the product toolkit guides the agent (that is what users get and what the demo must show).

## How every spec runs

1. Create the spec (Feature, Requirements-first) with the starter prompt below. The root steering points Kiro at the brief.
2. Review `requirements.md` (EARS). Run **Analyze Requirements**, resolve its questions, then continue to design.
3. Review `design.md`. For specs marked **PBT**, check that Kiro extracted correctness properties and that the
   property-test tasks use the library chosen in S10.
4. Review `tasks.md`: small tasks, tests inside each task, the acceptance criteria below present.
5. Run tasks one by one at first, then **Run all tasks** once the pattern is stable. Commit after each task.
6. A task list may also run unattended in Kiro Crew's Task Runner on its own git branch (`06` §6, S25). Review and
   merge the branch in the IDE.

---

## Phase 0 — Setup and spikes (17–18 Nov)

- [ ] Devpost: join; request Kiro credits (deadline 1 Dec 12:00 PT; the name on your ID must match your Devpost
      profile); start the submission draft (`15` §8).
- [ ] Post the "2 repo folders" question on Discord #kiroween-hackathon or Devpost discussions.
- [ ] Create the public repo with the MIT licence; add `docs/brief/`, `.gitignore` (`15` §3), a README stub,
      `THIRD_PARTY_NOTICES.md`, `docs/kiro-journal.md`.
- [ ] Vendor tactile-design at commit `30495a2` into `skeleton/.kiro/skills/tactile-design/` (a copy, with its `LICENSE`).
- [ ] Root `.kiro/`: steering (`brief*.md` from the brief README, `repo-conventions.md`), `settings/mcp.json`
      (Dart MCP), dev hooks.
- [ ] Fonts (Inter, Space Grotesk, Plus Jakarta Sans; static Medium + OFL.txt) and the icon package (S23).
- [ ] Tactile spike in `spikes/tactile_spike/`: `TactileSurface`, `Pressable`, primary and secondary buttons, a card on
      a panel, light and dark; compare with 4hands.dev at 2× zoom. Answers S15–S17 and S19.
- [ ] The other P0 spikes in `13` (hooks, skills, Crew, Kiro CLI, web images + Pages deep links, analyzer deps, PBT library).
- [ ] Pin the Flutter version.

Exit: every P0 spike has a result; the tactile spike looks right in both themes.

## Phase 1 — skeleton (19–22 Nov)

### Spec `skeleton-foundation` (19–20 Nov)

Starter prompt:
> Create the spec `skeleton-foundation` for the `skeleton/` Flutter project. Sources: docs/brief/03-architecture.md
> §1–§5, 04-design-system.md §1–§10, 02-repository-structure.md. Scope: flutter create with all platforms and pinned
> packages; the platform setup in 03 §5; app/ (bootstrap, env, DI, router, shell); core error, usecase, network,
> storage, services, settings (AppSettings: theme System/Light/Dark with System as the default, and locale, both saved
> across restarts), utils (formatters incl. money and compact numbers), l10n (en, id); design/tokens.yaml with a first
> token generator (a simple Dart script with checked-in Radix scales for sand, slate, blue, green, red, and amber; kit
> replaces it later); the tactile foundation (SurfaceScope/TactileSurface, shadows with the blur conversion,
> Pressable, typography roles, motion tokens and springs, theme mapping); core/layout; branding placeholders, the
> native splash, and the web loading screen. Out of scope: other core widgets, the test harness, bricks, create_app,
> kit, hooks, skills.

Acceptance: the skeleton runs on web, the iOS simulator, Android, and macOS with the adaptive shell; the theme
switches between System, Light, and Dark and survives a restart; a release APK reaches the network.

### Spec `core-widgets-and-templates` (21–22 Nov)

Starter prompt:
> Create the spec `core-widgets-and-templates` for skeleton/. Sources: docs/brief/03-architecture.md §6–§7,
> 04-design-system.md §7, §11, §12, 02-repository-structure.md (create_app, sync_core), 10-quality-ci-deploy.md.
> Scope: the core widgets in 03 §6.1 (incl. ThemeModeSwitch) with {@catalog} doc blocks; test/helpers/stress.dart with
> the quick and full profiles and the accessibility checks; the golden setup (fonts, DPR 2, tag golden, generated on
> this Mac); stress tests and goldens for every core widget; the home example feature with all test types; Mason bricks
> (feature, page, bloc, usecase, core_widget) and mason.yaml; tool/create_app.dart and tool/sync_core.dart as
> specified; CI for the skeleton (analyze, tests without the golden tag, build web) and the template job. Out of scope:
> kit, hooks, skills.

Acceptance: success criterion 1 in `00-overview.md` minus `kit check`; goldens of the shell and every core widget look
right in light and dark at 2× zoom.

## Phase 2 — toolkit (23–26 Nov)

### Spec `kit-check-tokens` (23–24 Nov) · PBT

Starter prompt:
> Create the spec `kit-check-tokens` for skeleton/tool/kit. Sources: docs/brief/05-kit-cli.md §1–§3, §5, §7, §8, §10
> and 04-design-system.md §4–§5. Scope: the package scaffold, output conventions, kit.yaml, and the --project option;
> kit check with every rule in 05 §8 (ARCH, UI, WID, SCR, GEN, FEAT, TEST, TAC, PLAT, KIT) and fixtures; kit tokens
> (tool/fetch_radix.dart → radix_colors.g.dart at commit dbdb854, derived colours, surface remaps, shadow conversion,
> springs, contrast gates, DESIGN_TOKENS.md; it replaces the Phase 1 generator); kit catalog and catalog similar; kit
> screens; kit usages; kit doctor. Write the requirements so correctness properties can be extracted for tokens,
> contrast gates, blur conversion, and springs (05 §10). Out of scope: api commands and hook adapters.

### Spec `kit-api` (24–25 Nov) · PBT · runs in Kiro Crew

Starter prompt:
> Create the spec `kit-api` for the API commands of skeleton/tool/kit. Sources: docs/brief/05-kit-cli.md §4, §6, §10,
> 07-workflows.md W1–W2, 08-app-orbit.md §1–§2. Scope: kit api summarize, diff (breaking classes, rename heuristic),
> impact (joined with api_map.yaml, analyzer usage lookup), gen-dto (supported subset, TODO markers, kit-hash headers),
> adopt, and kit feature new. Test fixtures: the SNAPI v4 spec from https://api.spaceflightnewsapi.net/v4/schema/, the
> Orbit demo fixture described in 08 §2 (save it as tool/kit/test/fixtures/snapi_v1.yaml; Orbit reuses it), and small
> OpenAPI 3.0/3.1 specs. Write the requirements so the properties in 05 §10 can be extracted.

Create and review this spec in the IDE. Once `kit-check-tokens` has created the package scaffold, run its task list
in Kiro Crew while you continue `kit-check-tokens` in the IDE.

### Spec `kiro-toolkit` (25–26 Nov)

Starter prompt:
> Create the spec `kiro-toolkit` for skeleton/.kiro and the hook adapters. Sources: docs/brief/06-kiro-toolkit.md,
> 07-workflows.md, 05-kit-cli.md §9. Scope: kit guard, post-write, context, and route-prompt; tool/kit.sh and kit.ps1
> with the compiled binary; the 9 steering files (design-language.md condensed from 04); the 6 skills condensed from
> W1–W6 with references/; hooks/kit-guards.json; agents flutter-dev and ui-reviewer; settings/mcp.json; the vendored
> tactile-design skill left untouched; skeleton/docs/toolkit-testing.md and tool/scenarios/ (06 §8); the user guide v1
> (06 §9). Validate every hook and scenario in Kiro IDE with skeleton/ open in its own window.

### Baseline recordings (26 Nov)

- [ ] `flutter create spikes/baseline_app` (no `.kiro/`). Open it as its own Kiro workspace, check that
      `~/.kiro/steering/` is empty, and start recording.
- [ ] Send three prompts: (1) the SNAPI spec with "Build the app."; (2) "Build a list screen with an article card", then
      a second screen from an image that contains the same card; (3) a card list with long titles, then view it at
      320 px wide with the largest text size.
- [ ] Count questions asked before coding, endpoints built, duplicate widgets, overflow errors, and literal design
      values (`dart run skeleton/tool/kit/bin/kit.dart check --project spikes/baseline_app`). Write them in the journal.

Phase 2 acceptance: every P1–P7 row in `00-overview.md` has its workflow and guard; scenarios SC1–SC8 pass in the IDE;
SC1–SC4 pass through `tool/scenarios/run.sh`; the skeleton passes `kit tokens --check` and `kit check --all`.

## Phase 3 — `orbit` (27–29 Nov)

Preparation (repo root):
- [ ] `dart run tool/create_app.dart orbit --dir app_orbit --org dev.<you> --display-name "Orbit"`.
- [ ] Copy `docs/brief/08-app-orbit.md` to `app_orbit/docs/app-brief.md` and
      `skeleton/tool/kit/test/fixtures/snapi_v1.yaml` to `app_orbit/api/demo/openapi.v1.yaml`.
- [ ] Set `app_orbit/design/tokens.yaml` (08 §4), run `kit tokens`, fill `.kiro/steering/product.md`, add the branding assets.

Open `app_orbit/` in a new Kiro window. Starter prompt:
> Create the spec `orbit` from docs/app-brief.md. Build it only through this project's toolkit: api-intake with
> api/demo/openapi.v1.yaml, later api-update to the real v4 spec, adding blogs. Follow the design-language steering and
> the tactile-design skill for all UI. Create MediaCard, AppNetworkImage (Image.network on web), PagedListView,
> AppChoiceList, and FilterPill as core widgets. Include the offline cache of the first page and the settings page with
> ThemeModeSwitch. Log each toolkit moment in ../docs/kiro-journal.md.

Record the 🎥 moments in a Vibe chat, the way users will use the toolkit, then tick the matching tasks. Run the other
tasks from the spec.

Tasks
- [ ] Run SC1, then 🎥 W1 api-intake → `articles` (list, search, filter, detail, saved, offline cache).
- [ ] 🎥 Guard demo: ask for "a reports data source" → blocked by the data-layer guard.
- [ ] Run SC5, then 🎥 W2 api-update to v4 → renames, the `blogs` feature, the "Featured" badge.
- [ ] `settings` (W6): theme switch, attribution, licences.
- [ ] Adaptive layouts, goldens, integration test, release APK and macOS check, deploy check.
- [ ] Repo root: `dart run tool/sync_core.dart --from app_orbit --to skeleton`, then `kit catalog` and tests in the skeleton.

Acceptance: `08-app-orbit.md` §5.

## Phase 4 — `tally` (30 Nov–2 Dec)

Pre-req: the 5 design references in `09-app-tally.md` §4, with the planted conflicts (make them in Phase 2–3 evenings).

Preparation (repo root, after the Orbit sync):
- [ ] `dart run tool/create_app.dart tally --dir app_tally --org dev.<you> --display-name "Tally"`; copy
      `docs/brief/09-app-tally.md` to `app_tally/docs/app-brief.md`; tokens (09 §6); `kit tokens`; `product.md`;
      branding assets; add drift.

Open `app_tally/` in a new Kiro window. Starter prompt:
> Create the spec `tally` from docs/app-brief.md. Build every screen only through design-to-ui, ui-update, and
> promote-widget with the reference images in design/references, following the scripted demo moments in §5. Include
> the sample data service, the dashboard empty state, and Delete all data in settings. Log each moment in
> ../docs/kiro-journal.md.

Record the 🎥 moments in a Vibe chat, then tick the matching tasks. Run the other tasks from the spec.

Tasks
- [ ] Drift database + seeds + sample data (web setup per S7), l10n en/id.
- [ ] Run SC7, then 🎥 design-to-ui: dashboard → conflicts flagged and answered; `PeriodSwitcher`, `Figure`, `Meter`,
      `AppBarChart`, `AmountText` created in core.
- [ ] design-to-ui: transactions list + form (`AppChoiceTiles` created).
- [ ] Run SC6, then 🎥 design-to-ui: budgets → `PeriodSwitcher` reused.
- [ ] Run SC4, then 🎥 promote-widget: category badge blocked cross-feature → promoted.
- [ ] Run SC8, then 🎥 ui-update: transactions.2.png with "update this".
- [ ] 🎥 Stress test catches the long Indonesian category overflow.
- [ ] 🎥 `/ui-reviewer` on the dashboard (dark) → accept two fixes.
- [ ] Categories, settings (theme, language, currency, delete all data), money PBT, integration test, deploy check.
- [ ] Sync core widgets back to the skeleton.

Acceptance: `09-app-tally.md` §7.

## Phase 5 — `release` (3–4 Dec)

Starter prompt (repo root):
> Create the spec `release` from docs/brief/11-roadmap.md Phase 5, 10-quality-ci-deploy.md §2–§3, 12-submission.md, and
> 15-github-repo-guide.md. Scope: the deploy-pages workflow and the landing page; Android release APKs; the README for
> judges; THIRD_PARTY_NOTICES.md; the final pass on the user guide; a check of both deployed apps at 375, 834, and
> 1440 px with the Playwright power, saving screenshots to docs/assets/; drafts of the Devpost text and the Kiro
> write-up from docs/kiro-journal.md; the verification commands in 15 §7. I record the video myself.

- [ ] Deploy both apps; test the URLs in a private window on a phone, at tablet width, and on desktop.
- [ ] APKs in Releases; iOS and macOS footage recorded.
- [ ] Video (script in `12` §2) on YouTube, public.
- [ ] Write-up, student details (`12` §7), blog and social post (optional).
- [ ] Final checklist in `01` and `15` §7; tag `v1.0.0`; freeze `main` until judging ends (`15` §9).
- [ ] Optional: package the skills as a Kiro power (`06` §10).

## Buffer — 4 Dec 20:00 to 5 Dec 05:00 WIB

Submit by 4 Dec 20:00 WIB. No new features.

---

## Cut order (if behind schedule)

Cut from the top. api-update and ui-update stay in the MVP.
1. Figma MCP (images only).
2. The skills as a Kiro power.
3. Tactile sheet drag thresholds (Flutter's default drag-to-dismiss).
4. Page-entrance stagger and label-swap blur (plain fades).
5. `kit fonts measure` (`size_factor` by hand).
6. The Crew part of the user guide's surfaces page.
7. Tally: CSV export, categories management screen (seeds only).
8. Windows/Linux builds.
9. `kit catalog similar` scoring (the agent reads CATALOG.md; WID001 uses exact-name duplicates only).
10. `api gen-dto` unsupported constructs (only the subset SNAPI needs).
11. The headless scenario script (run the scenarios interactively in Kiro CLI instead).
12. Orbit `blogs` implementation (keep the impact report and the decision in `unused`).
13. `ui-reviewer` agent (keep the never-ship list in steering).
14. Integration tests.

Never cut: guards, `kit check` (incl. TAC and PLAT rules), `kit tokens` gates, stress tests, goldens in both themes,
the platform setup, Tally sample data, the two deployed apps, the baseline recordings, the video, the write-up, the
third-party disclosure.

## Daily routine

- Morning: pick tasks from the active spec and run them in Kiro IDE (or a task list in Crew).
- After each task: the definition of done (`10` §4), then a Conventional Commit.
- Evening: 3–5 lines in `docs/kiro-journal.md`; push.
