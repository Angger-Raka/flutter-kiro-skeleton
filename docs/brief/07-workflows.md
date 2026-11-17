# 07 — End-to-end workflows

Each workflow is the source for one skill's `SKILL.md`. Dialogues show the intended agent behavior; they are
also the scripts for the demo video. Agent replies are shortened.

---

## W1 — API intake (P1)  → skill `api-intake`

**Trigger:** user shares an API spec or docs, often with little context ("here's the API, build it").

**Steps**
1. Save the spec to `api/openapi.yaml` (or `api/incoming/<name>.yaml` if a spec already exists → switch to W2).
2. `kit api summarize api/openapi.yaml` (use `--tag` if > 30 operations).
3. Present the summary grouped by tag and ask the **intake questions** (defaults in brackets):
   1. Which feature(s) is this for, and what is the user trying to do? [proposal derived from tags]
   2. Which operations are in scope now? [the minimal set for the proposed flow]; the rest go to `unused`.
   3. Main user flow, screen by screen. [proposal]
   4. Auth: none / API key / bearer / OAuth? [from spec `securitySchemes`]. The skeleton has no auth module (non-goal);
      if the spec needs auth, say so and propose the smallest approach before writing code.
   5. Pagination style and page size. [detected: limit/offset, 20]
   6. Error and empty behavior. [ErrorView with "Try again"; EmptyState per screen]
   7. Offline/caching needs. [none]
   8. Is there a design for these screens? [no → tactile defaults with catalog widgets]
4. Write `lib/features/<f>/FEATURE.md` (status `draft`) and `api_map.yaml` entries; show both; wait for "ok".
5. Set `status: active`, `confirmed_by_user: <date>`.
6. `kit feature new <f> --source api` (Mason brick) → `kit api gen-dto --feature <f> --schema ...`.
7. Implement: entities, mappers, data source, repository impl, usecases, bloc, page/view using core widgets.
   UI follows W3 steps 0 and 3–9 even without a design image.
8. Tests: mapper unit tests, repository tests (mock data source), bloc_test, stress test, goldens.
9. `dart run build_runner build -d`, `kit check`, `flutter test`. Summarize what was created and what was left in `unused`.

**Never:** generate code for operations the user did not put in scope; invent fields not in the spec; skip step 4.

**Guard:** writing into `features/<f>/data/` before step 5 is blocked by `kit guard data-layer`.

**Example (Orbit)**
> **User:** Here's the Spaceflight News API. Build the app. *(attaches openapi.yaml)*
>
> **Agent:** The spec has 7 operations in 4 groups: articles (2), blogs (2), reports (2), info (1). Before I write
> code, please confirm or change:
> 1. Feature: `articles`, to browse and read spaceflight news. *(default)*
> 2. In scope: `articles_list`, `articles_retrieve`, `info_retrieve` (for the news-site filter). Blogs and reports → unused for now.
> 3. Flow: list (newest first, infinite scroll) → detail → open the original article in the browser.
> 4. Auth: none (the spec has no security schemes).
> 5. Pagination: limit/offset, page size 20, stop when `next` is null.
> 6. Errors: ErrorView with "Try again"; empty search shows "No articles match '<query>'".
> 7. Offline: none.
> 8. Design: none yet. I'll follow tactile defaults. The catalog has no media card or paged list, so I'll add
>    `MediaCard` and `PagedListView` to core (they're generic).
>
> **User:** ok, but add search by title.
>
> **Agent:** Added the `search` param to `articles_list`. Here is FEATURE.md and api_map.yaml … Confirm?

---

## W2 — API update (P4)  → skill `api-update`

**Trigger:** user shares a newer spec or says "the API changed, update the docs/code".

**Steps**
1. Save as `api/incoming/openapi.<date>.yaml`. Never overwrite `api/openapi.yaml` yet.
2. `kit api impact --new api/incoming/openapi.<date>.yaml` (runs diff internally).
3. Present: breaking changes per feature (with affected files), `renamed?` candidates, non-breaking additions, new unmapped operations.
4. Ask: (a) confirm each `renamed?`; (b) for each new operation: map to a feature (which?) or add to `unused`;
   (c) for new optional fields: use them now or ignore [ignore]; (d) for enum additions: how to display unknown values [show raw value].
5. `kit api adopt <incoming>` → updates snapshot + `api/CHANGELOG.md`.
6. Regenerate affected DTOs (`kit api gen-dto ...`). Update mappers/entities/usecases/blocs/UI only where impacted.
7. Update `FEATURE.md` decisions and `api_map.yaml` (`unused` reasons).
8. `build_runner`, `kit check` (FEAT003 must be clean), tests (mapper tests updated for renamed fields).
9. Summarize: changes applied, files touched, decisions recorded.

**Never:** hand-edit generated DTOs (blocked by `kit guard generated`); silently adopt new endpoints.

**Example (Orbit, demo fixture `api/demo/openapi.v1.yaml` → real v4 spec)**
> **User:** The API was updated, here's the new spec.
>
> **Agent:** Impact report:
> - **articles, 3 breaking:** `Article.newsSite` → `news_site`?, `imageUrl` → `image_url`?, `publishedAt` → `published_at`?
>   Affected: article_dto.dart (regenerate), article_mapper.dart lines 12–16.
> - New optional field `Article.featured`.
> - 4 new operations not mapped: blogs_list, blogs_retrieve, reports_list, reports_retrieve.
>
> Questions: 1) Confirm the 3 renames? [yes] 2) Blogs and reports: add as new features `blogs` and `reports` with the
> same list/detail pattern, or keep unused? [keep unused] 3) Show a "Featured" badge using `featured`? [no]
>
> **User:** yes to renames, add blogs as a tab, show featured badge.

---

## W3 — Design to UI (P2, P3, P7)  → skill `design-to-ui`

**Trigger:** user shares an image or Figma link for a new screen or widget.

**Steps**
0. Activate the `tactile-design` skill. `design-language.md` (fileMatch) supplies the Flutter mapping.
1. Save the image to `design/references/<feature>/<screen>.<n>.png` (ask for feature/screen name if unclear; propose one).
   Figma: fetch via MCP (screenshot + layout + variables).
2. Decompose the design into a component list (top to bottom), including states visible or implied (empty, loading, error).
3. **Decision sheet** (tactile decision order, one line each): the single next step and its primary (or "none");
   the least data that answers the screen's question; placement and page column (reading/data/form);
   component per element; surfaces; type roles; colour roles; motion (or "none"); mobile changes.
4. For each component: `kit catalog similar <ProposedName> --summary "<what it is>"`, then classify
   (rules in `references/component-classification.md`):
   - **reuse**: a catalog widget matches (same role, compatible params).
   - **extend**: a catalog widget matches but needs a new variant or param (changes core; list affected usages via `kit usages`).
   - **new core**: generic UI with no domain types (buttons, cards, inputs, pills, rows, figures, empty states). Default for anything that could appear in another feature.
   - **new feature widget**: depends on this feature's entities or blocs, or is a composition used only here.
5. **Design conflicts.** List every place where the design breaks a tactile rule or token, for example a second
   filled button, bold or coloured hierarchy, a grey filled button, a colour used for importance, a literal size
   off the spacing ladder, actions placed under the data, a big soft shadow. For each one, ask:
   "follow the system (default) or keep the design exactly?" Record the answer in `FEATURE.md` → Decisions.
6. Map remaining visual values to tokens: spacing to the ladder (±2 px), radius to the radius ladder, text to a type
   role, colours to ink or hue roles. Values with no token are asked about, never hardcoded.
7. Show the decision sheet, classification table, conflicts, and the layout plan per window class (the design usually
   shows one size; propose the other two). Wait for confirmation.
8. Scaffold: `mason make core_widget` / `page` as needed. Build core widgets first (catalog block, stress test,
   goldens light + dark), then feature widgets, then the page.
9. `kit catalog`, `kit screens`, `kit check`, tests. Optional: `/ui-reviewer` and fix the findings the user accepts.

**Never:** create a widget without step 4; hardcode values (UI001–UI004); style Material widgets in features (TAC001);
put a generic widget in a feature folder "for now"; silently "fix" or silently copy a design conflict.

**Example (Tally dashboard)**

Decision sheet: next step = none on the dashboard (adding a transaction is a page action, secondary); data = one net
figure for the month, budgets as meters, 30 days of bars, the last 5 transactions; page column = data (1200).

| # | Component in design | Match | Decision | Notes |
|---|---|---|---|---|
| 1 | Month switcher (‹ November 2026 ›) | none (0.21) | new core `PeriodSwitcher` | generic, reused by budgets |
| 2 | Big net amount + "This month" | none | new core `Figure` | number 24/32 over a 13/20 label |
| 3 | Income / expense numbers | `Figure` (from #2) | reuse | 32 apart |
| 4 | Category progress bars | none | new core `Meter` | identity hue per category, red at ≤ 10 % left |
| 5 | Daily spending bars | none | new core `AppBarChart` | bars only, fade in, hover dims others |
| 6 | "Recent transactions" + "See all" | `SectionHeader` (0.92) | reuse | "View all" goes after the list |
| 7 | Transaction row | `AppRow` (0.71) | reuse | amount via new core `AmountText` |

Conflicts found: section titles are bold (→ one weight, size + ink step); "Add" is a green filled button and there is
a second filled "Export" button (→ both secondary; no primary on the dashboard); card padding 18 (→ 20 or 24).
Questions: follow the system for all three? [yes]

---

## W4 — UI update without location (P5)  → skill `ui-update`

**Trigger:** user shares an image of a changed UI, maybe with "update this", no screen named.

**Steps**
0. Activate the `tactile-design` skill.
1. **Locate.** Compare the image against `docs/SCREENS.md` (summaries, widget lists, layout) and golden images of
   candidate screens. Produce a ranked candidate list with reasons.
   - One candidate clearly matches → state it and ask for a quick confirm.
   - Otherwise → show the top 2–3 candidates and ask which one. Never pick silently.
   - No screen matches → probably new → switch to W3.
2. **Diff.** List added / removed / changed elements versus the current screen (the golden is "before").
3. **Impact.** For each change, find the owning widget. If it is a core widget: `kit usages <Widget>` and ask:
   (a) change all N usages, (b) add a variant or param used only here [default], (c) feature-local widget (only if not generic).
   A changed **pattern** (for example how a badge looks) is applied to every instance in the same change, per tactile.
4. **Conflicts and tokens:** same as W3 steps 5–6.
5. Implement → update stress tests and goldens → `kit screens`, `kit catalog`, `kit check`, tests.
6. Save the image as a new reference version (`<screen>.<n+1>.png`).
7. Report as *Changed / Moved / Flag* bullets.

**Example (Tally)**
> **User:** update this *(image of a transaction row with a category badge and a note line)*
>
> **Agent:** This looks like the transaction row on **transactions** (`/transactions`): same list layout, amount on the
> right, grouped by day. It could also be **dashboard → Recent transactions**, which uses the same row.
> Changes: (1) the category shows as a badge instead of an icon, (2) the note shows as a second line, 1 line max.
> The row is the core `AppRow`, used in 4 places (transactions, dashboard, budget detail, search).
> Apply to: a) all 4, b) only transaction rows (a new core `TransactionRow` composing `AppRow` + `AppBadge`) [default], c) only this screen?

---

## W5 — Promote widget (P2)  → skill `promote-widget`

**Trigger:** a widget in `features/a/presentation/widgets/` is needed in feature `b`; or ARCH003/WID001 reported.

**Steps**
1. Show the widget's current params. Replace feature types (entities, blocs) with primitives or callbacks
   (e.g. `Category c` → `String label, String iconKey, int identityIndex`).
2. Propose a core name and category; run `kit catalog similar` to avoid a duplicate in core.
3. Move to `lib/core/widgets/`, add the `{@catalog}` doc block, move/adapt the stress test and goldens.
4. In feature `a`, keep a thin adapter only if mapping is non-trivial (an extension like `category.toBadge()` stays in the feature).
5. Update imports, `kit catalog`, `kit check` (ARCH003, WID001 clean), tests.

---

## W6 — New feature without API or design → skill `new-feature`

1. Ask: purpose, user flows, data (local/none), screens, which existing screens link to it. Propose defaults.
2. Write `FEATURE.md` (`source: local`), confirm.
3. `kit feature new <f> --source local`, implement with catalog widgets and tactile defaults, tests, `kit check`.

---

## W7 — Resilience and composition (P6, P7) — applies to every UI workflow

No separate skill; enforced by steering, the tactile skill, and checks:
- While writing UI: `design-language.md` and `ui-resilience.md` load automatically (fileMatch).
- Literal values blocked (UI001–UI004), Material visual widgets blocked in features (TAC001), one weight (TAC002),
  no hand-made shadows or borders (TAC003), motion tokens only (TAC004–TAC005), one primary (TAC006), copy rules (TAC007–TAC008).
- Before finishing: a stress test exists (UI005) and passes at 6 sizes × 3 text scales × 2 themes × fixtures.
- Demo moment: a `MediaCard` with an 80-character unbroken word at text scale 2.0 on a 320 px screen fails a stress
  test in a draft without `Expanded`, then passes after the fix.

---

## W8 — UI review → custom agent `ui-reviewer`

**Trigger:** "review this screen", "polish", "something feels off", or the optional last step of W3/W4.

**Steps**
1. `/ui-reviewer <screen or widget>` runs goldens (light + dark) and reads stress-test output.
2. It reviews against the tactile decision order, the never-ship list, and `design-language.md` deviations.
3. Output: *Changed* (proposed), *Moved*, *Flag* bullets, each with the rule, severity, and the smallest fix
   (in units of 2 px, one ink step, or 5 % opacity/scale). It edits nothing.
4. The user picks fixes; the main agent applies them with the tactile skill, everywhere the same pattern appears, then
   reruns checks and goldens.

**Example**
> **ui-reviewer:** Dashboard, light and dark.
> - Changed: "Export" was a second primary → secondary. Rule: one primary per surface.
> - Moved: the pager from inside the transactions card to 12 px below it. Rule: paging sits outside the card.
> - Flag: meta text in ink-10 misses 4.5 : 1 on white with the sand neutral → kit already routes it to ink-11; the design reference shows lighter text.
