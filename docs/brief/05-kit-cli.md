# 05 — `kit` CLI

`kit` is the deterministic half of the toolkit: everything with a consistent output is a `kit` command, so the
agent spends tokens only on judgment. Hooks, skills, and CI all call `kit`.

## 1. Packaging and invocation

- Location: `skeleton/tool/kit/` — a standalone Dart package (`name: kit`) with `bin/kit.dart`.
- The app references it as a dev dependency: `dev_dependencies: kit: { path: tool/kit }`.
- Invocation from the app root: `dart run kit:kit <command> [args]`. In this brief: `kit <command>`.
- Dependencies: `analyzer` (AST parsing, never regex for Dart), `yaml`, `args`, `path`, `crypto`, `glob`.
  **[VERIFY]** analyzer version resolves together with `freezed`/`json_serializable`/`injectable_generator`.
  Fallback: keep `kit` outside the app's pubspec and run it with `dart run tool/kit/bin/kit.dart` after `dart pub get -C tool/kit`.
- Speed: hooks run often. `kit doctor --install` compiles `dart compile exe` to `.dart_tool/kit/kit`.
  Hooks call `tool/kit.sh` (and `tool/kit.ps1` on Windows), which uses the compiled binary if it is newer
  than `tool/kit/` sources, otherwise falls back to `dart run kit:kit`. Target: guard commands < 300 ms with the binary.

## 2. Output conventions

- Default output is short, plain text meant for an LLM: no colors, no banners, stable ordering.
- `--json` on every command for machine use.
- Exit codes: `0` ok, `1` findings (check failed / breaking changes), `2` guard block (only `kit guard`), `64` usage error, `70` internal error.
- Findings format, one per line: `<CODE> <severity> <path>:<line> <message>`; final line `kit: <n> errors, <m> warnings`.
- Output is truncated to 60 findings with "… and N more (run kit check --all)". Hooks pass this to the agent; keep it short.
- Every command accepts `--project <dir>` (default: the current directory), so `kit check` can scan any Flutter
  project, for example the baseline app (`11` Phase 2).

## 3. Command reference

| Command | Purpose |
|---|---|
| `kit doctor [--install]` | Verify Flutter/Dart versions, mason_cli, build_runner outputs fresh, hook scripts executable, and the platform setup (`03` §5); `--install` compiles the binary and runs `mason get` |
| `kit api summarize <spec> [--tag t] [--out api/summary.md]` | Endpoint summary (§6.1) |
| `kit api diff <old> <new>` | Structured diff with breaking classification (§6.2) |
| `kit api impact [--old api/openapi.yaml] --new <spec>` | Diff joined with `api_map.yaml` → per-feature impact (§6.3) |
| `kit api gen-dto --feature <f> --schema <S>[,<S>...] [--spec api/openapi.yaml]` | Generate DTOs (§6.4) |
| `kit api adopt <spec>` | Copy spec to `api/openapi.yaml`, prepend entry to `api/CHANGELOG.md` with diff summary |
| `kit feature new <name> [--source api\|local]` | Wraps `mason make feature`; creates `FEATURE.md` from template |
| `kit catalog [--check]` | Generate `lib/core/widgets/CATALOG.md` (§5); `--check` fails if stale |
| `kit catalog similar <Name> [--top 5]` | Rank existing catalog entries by similarity to a proposed widget name/summary |
| `kit screens [--check]` | Generate `docs/SCREENS.md` (§7) |
| `kit usages <WidgetClass>` | Every file:line constructing the widget, grouped by feature/screen |
| `kit tokens [--check] [--report]` | Resolve `design/tokens.yaml` (Radix scales, derived colours, surface remaps, shadow conversion, springs; `04` §4–§5), run contrast gates and the hue-collision rule, write `lib/core/theme/tokens.g.dart` and `docs/DESIGN_TOKENS.md`. Exit 1 on a failed gate |
| `kit fonts measure <ttf>` (stretch) | Read OS/2 `sxHeight` and `unitsPerEm`; print the tactile size factor `0.546 / (xHeight / em)` for `typography.size_factor` |
| `kit refs <feature>` | List design references for a feature with mapped screens |
| `kit check [rules...] [--changed] [--all]` | Run rules (§8). `--changed` limits to files changed vs `git HEAD` + untracked |
| `kit guard <event>` | Hook adapter: reads hook JSON on stdin, applies guard rules (§9) |
| `kit context` | Short session summary for SessionStart hook: features, core widget count, pending API changes, failing checks count |
| `kit post-write` | PostToolUse adapter: format the written Dart file and regenerate tokens/catalog/screens when their sources changed (`06-kiro-toolkit.md` §4) |
| `kit route-prompt` | UserPromptSubmit adapter: reads `USER_PROMPT`, prints a one-line skill suggestion or nothing; never blocks |

## 4. `FEATURE.md` and `api_map.yaml`

### `lib/features/<f>/FEATURE.md`

YAML front matter is parsed by `kit`; the body is for humans and agents.

```markdown
---
feature: articles
status: active            # draft | active | deprecated
source: api               # api | local | mixed
screens: [articles, article_detail]     # route names from RouteNames
endpoints: [articles_list, articles_retrieve, info_retrieve]   # operationIds; must exist in api_map.yaml
confirmed_by_user: 2026-11-26
---
# Articles

## Purpose
Browse the latest spaceflight news, search by title, filter by news site.

## User flows
1. Open app → latest articles (newest first), infinite scroll, pull to refresh.
2. Type in search → results update after 400 ms.
...

## Rules and edge cases
- Pagination: limit/offset, page size 20. End when `next` is null.
- Errors: network → ErrorView with retry; empty search → EmptyState "No articles match".

## Decisions
- 2026-11-26: `blogs` endpoints not used yet (user decision).
```

### `api/api_map.yaml`

```yaml
version: 1
spec: api/openapi.yaml
operations:
  articles_list:                    # operationId (kit synthesizes "<method>_<path>" if missing)
    method: GET
    path: /v4/articles/
    feature: articles
    usecase: GetArticles
    datasource: ArticlesRemoteDataSource.getArticles
    request: { params: [limit, offset, title_contains, news_site, ordering] }
    response: PaginatedArticleListDto
  articles_retrieve:
    method: GET
    path: /v4/articles/{id}/
    feature: articles
    usecase: GetArticle
    datasource: ArticlesRemoteDataSource.getArticle
    response: ArticleDto
unused:                            # operations seen and deliberately not used
  blogs_list: { reason: "Not needed for v1 (user, 2026-11-26)" }
schemas:                           # schema → generated DTO file
  Article: lib/features/articles/data/models/article_dto.dart
  PaginatedArticleList: lib/features/articles/data/models/paginated_article_list_dto.dart
```

Invariants checked by `kit check` (FEAT00x): every `FEATURE.md` endpoint exists in `api_map.yaml`; every mapped
operation exists in the spec; every operation in the spec is either in `operations` or `unused`
(FEAT003 warning, so new endpoints are never silently ignored).

## 5. Widget catalog

### Doc comment format (on every public widget in `lib/core/widgets/` and `lib/core/layout/`)

```dart
/// A card with an image, title, optional subtitle, and a meta row.
///
/// {@catalog}
/// category: content            # primitive | action | input | content | feedback | overlay | layout | chart
/// use_when: Showing an item with a thumbnail in a list or grid (news, products, places).
/// avoid_when: Text-only rows (use AppRow); dense tables.
/// variants: vertical, horizontal
/// tags: card, thumbnail, image, list item, article
/// {@endcatalog}
class MediaCard extends StatelessWidget { ... }
```

`kit catalog` reads these with the analyzer, adds constructor parameters (name, type, required, default),
named constructors as variants, file path, and whether a stress test and golden exist.

### `lib/core/widgets/CATALOG.md` output

```markdown
<!-- GENERATED by kit catalog. Do not edit. kit-hash: ... -->
# Core widget catalog (14 widgets)

## content
### MediaCard — lib/core/widgets/media_card.dart
A card with an image, title, optional subtitle, and a meta row.
- use when: Showing an item with a thumbnail in a list or grid (news, products, places).
- avoid when: Text-only rows (use AppRow); dense tables.
- variants: MediaCard (vertical), MediaCard.horizontal
- params: title: String*, imageUrl: String?, subtitle: String?, meta: List<Widget> = const [], onTap: VoidCallback?
- tags: card, thumbnail, image, list item, article
- tests: stress ✓ golden ✓
```

Missing `{@catalog}` block on a public core widget → WID002 error.

### `kit catalog similar`

Scores each entry by token overlap between the query (name split on case + optional `--summary` text) and
entry name, tags, summary, use_when. Prints top N with scores. Used by `design-to-ui` and by WID001.
Deterministic, no embeddings.

## 6. API commands

Supported input: OpenAPI 3.0 and 3.1, YAML or JSON. Swagger 2.0 → error with hint to convert.
Non-OpenAPI docs (Postman, Markdown) are summarized by the agent into the same §6.1 format manually.
`$ref` resolution: local refs only (`#/components/...`); external refs → error listing them.

### 6.1 `api summarize` output

```markdown
# Spaceflight News API 4.37.1 (v4) — 7 operations, 11 schemas
Servers: https://api.spaceflightnewsapi.net
Auth: none

## articles (2)
- GET /v4/articles/ `articles_list` → PaginatedArticleList
  query: limit, offset, ordering, search, title_contains, news_site, published_at_gte … (+14)
- GET /v4/articles/{id}/ `articles_retrieve` → Article
## blogs (2)
...
## Schemas
- Article: id:int*, title:string*, authors:Author[]*, url:uri*, image_url:uri*, news_site:string*, summary:string*, published_at:date-time*, updated_at:date-time*, featured:bool, launches:Launch[]*, events:Event[]*
...
```
(`*` = required.) Long param lists are truncated with a count. Target: < 2,000 tokens for a 50-operation spec; `--tag` narrows.

### 6.2 `api diff` classification

Compares normalized models (refs resolved, properties sorted).

| Change | Class |
|---|---|
| Operation removed; path/method changed | breaking |
| Required request param added; param type changed; param removed that we send | breaking |
| Response property removed or renamed (= removed + added) | breaking |
| Response property type/format changed; nullable → non-nullable in request | breaking |
| Response property optional → required | non-breaking (stronger guarantee) |
| Response property required → optional / nullable | breaking for consumers (we may get null) |
| Enum value added in response | breaking-risk (warn: exhaustive switches) |
| Enum value removed in request | breaking |
| Operation added; optional param added; response property added | non-breaking |
| Description/summary/example changed | docs (hidden unless `--all`) |

Rename heuristic: a removed and an added property in the same schema with the same type and similar name
(`newsSite` → `news_site`, normalized by case/underscore) are reported as `renamed?` for the agent to confirm.

Output:
```
BREAKING  schema Article.newsSite removed (renamed? → news_site)
BREAKING  schema Article.imageUrl removed (renamed? → image_url)
ADDED     operation GET /v4/blogs/ blogs_list
ADDED     schema Article.featured (boolean, optional)
kit: 3 breaking, 4 non-breaking, 2 docs
```

### 6.3 `api impact` output

```
Feature articles (FEATURE.md: lib/features/articles/FEATURE.md)
  BREAKING Article.newsSite → news_site?
    - lib/features/articles/data/models/article_dto.dart (generated: regenerate)
    - lib/features/articles/data/mappers/article_mapper.dart:14 uses dto.newsSite
  ADDED Article.featured (not used)
Unmapped new operations (decide: map to a feature or add to unused):
  - GET /v4/blogs/ blogs_list
  - GET /v4/reports/ reports_list
No impact: bookmarks
```
Usage lookup uses the analyzer to find property accesses on the generated DTO types.

### 6.4 `api gen-dto`

Generates freezed + json_serializable DTOs into `lib/features/<f>/data/models/`, one file per schema, including
schemas referenced transitively (placed in the same feature; if already generated for another feature, `kit`
stops and suggests moving the shared DTO to `core/network/models/` — this is the API-side twin of promote-widget).

Header:
```dart
// GENERATED by kit api gen-dto from api/openapi.yaml#/components/schemas/Article. Do not edit.
// Regenerate: kit api gen-dto --feature articles --schema Article
// kit-hash: <sha256 of body>
```

Supported: object, required/optional, nullable (3.0 `nullable`, 3.1 `type: [x, "null"]`), string formats
`date-time` → `DateTime`, `date` → `DateTime`, `uri` → `String`, integer/number/boolean, arrays, `$ref`,
string enums (→ Dart enum with `@JsonValue` + `unknown` fallback via `unknownEnumValue`), `allOf` of objects (merged),
`additionalProperties` → `Map<String, T>`, snake_case keys → camelCase fields with `@JsonKey(name:)`.

Unsupported (generated as `Object?` with `// TODO(kit): <construct> at <pointer>` and listed in output so the agent handles it):
`oneOf`, `anyOf`, discriminators, `not`, external refs, recursive schemas deeper than self-reference.

Field doc comments come from schema `description`. Generated code passes `very_good_analysis`.

## 7. Screen registry (`docs/SCREENS.md`)

Built by parsing `lib/app/router/routes.dart` (GoRoute/ShellRoute trees: `path`, `name`, builder target class)
and then each page/view file (constructed widgets, core widgets used, feature widgets used, bloc types).

```markdown
<!-- GENERATED by kit screens. Do not edit. kit-hash: ... -->
# Screens (5)

## articles — /articles
- page: ArticlesPage (lib/features/articles/presentation/pages/articles_page.dart)
- feature: articles · blocs: ArticlesBloc
- layout: mobile list · tablet grid(2) · desktop list-detail      ← from `/// {@screen layout: ...}` doc on the page
- core widgets: AdaptiveScaffold, SearchField, PagedListView, MediaCard, EmptyState, ErrorView
- feature widgets: NewsSiteFilterBar
- design refs: design/references/articles/articles.1.png
- goldens: test/features/articles/presentation/goldens/articles_view_{mobile,tablet,desktop}.png
- summary: Latest articles with search and news-site filter.     ← from `{@screen summary: ...}`
```

Pages MUST have a `{@screen summary: ...}` doc block (SCR001). The summary and widget list are what the agent
uses to locate a screen from an image in `ui-update`.

## 8. Check rules

| Code | Sev | Rule |
|---|---|---|
| ARCH001 | error | `domain/` imports Flutter, dio, json_annotation, `data/`, `presentation/` |
| ARCH002 | error | `presentation/` imports its feature's `data/` |
| ARCH003 | error | A feature imports another feature |
| ARCH004 | error | `core/` imports `features/` |
| ARCH005 | error | `GoRoute(` declared outside `lib/app/router/routes.dart` |
| ARCH006 | warn | Repository impl method body not wrapped in `guardRepository` |
| UI001 | error | Literal number in `EdgeInsets.*`, `SizedBox(width/height)` used as gap, `padding:`/`spacing:` args in `presentation/` or `core/widgets/` (0 allowed; use `AppSpace.*` from the tactile ladder) |
| UI002 | error | `Color(0x...)`, `Color.fromARGB/fromRGBO`, `Colors.*` (except `Colors.transparent`) in `presentation/` or `core/widgets/` |
| UI003 | error | `fontSize:` set in `TextStyle` outside `core/theme/` |
| UI004 | error | Literal in `BorderRadius.circular(...)`, `Radius.circular(...)` outside `core/theme/` (use `AppRadius.*`) |
| UI005 | error | Core widget or page/view without a stress test that references it |
| UI006 | warn | String literal passed to `Text(...)` in `presentation/` (use l10n) |
| UI007 | warn | Tappable widget with explicit size < 48 that is not wrapped by `Pressable`/`AppIconButton` (which add the touch hit area) |
| UI008 | warn | `Column(children: <list>.map(...))` (use builder) |
| UI009 | warn | `Text` directly inside `Row` without `Expanded`/`Flexible` ancestor within the Row's children |
| WID001 | warn | New widget class under `features/*/presentation/widgets/` scores ≥ 0.6 similarity with a core widget, or a widget with the same name exists in another feature |
| WID002 | error | Public core widget without `{@catalog}` block |
| SCR001 | error | Page without `{@screen summary:}` block |
| GEN001 | error | Generated file's body hash ≠ header `kit-hash` (edited by hand) |
| GEN002 | error | `CATALOG.md`, `SCREENS.md`, `tokens.g.dart`, or `DESIGN_TOKENS.md` stale |
| FEAT001 | error | Feature has `data/` but no `FEATURE.md`, or `source: api` with no mapped endpoints |
| FEAT002 | error | `FEATURE.md` endpoint missing from `api_map.yaml` or from spec |
| FEAT003 | warn | Spec operation neither mapped nor in `unused` |
| TEST001 | warn | Bloc without `bloc_test` file |
| TAC001 | error | Material visual widget used in `presentation/`: `ElevatedButton`, `FilledButton`, `OutlinedButton`, `TextButton`, `IconButton`, `FloatingActionButton`, `SegmentedButton`, `Switch`, `Checkbox`, `Radio`, `Chip` family, `Card`, `ListTile`, `AlertDialog`, `Dialog`, `SnackBar`, `PopupMenuButton`, `DropdownButton`, `DropdownMenu`, `MenuAnchor`, `showDialog`, `showModalBottomSheet`. Message names the core replacement |
| TAC002 | error | `FontWeight.w600`–`w900` or `FontWeight.bold` outside `core/theme/` (one-weight rule) |
| TAC003 | error | `BoxShadow(`, `Border(`, `Border.all(`, `BorderSide(` or `boxShadow:`/`border:` arguments in `presentation/` (use `TactileSurface`/core widgets) |
| TAC004 | error | `Curves.*` in `presentation/` or `core/widgets/` (use `AppMotion`); `Curves.easeIn*` anywhere outside `core/theme/` |
| TAC005 | error | `Duration(` literal in `pages/`, `views/`, `widgets/` files (use `AppMotion`; blocs may use durations for debounce) |
| TAC006 | warn | More than one `AppButton.primary` constructed in one page, view, or dialog file |
| TAC007 | error | ARB string (any locale) contains three ASCII dots `...` (use "…") or an em dash `—` |
| TAC008 | warn | ARB string whose key ends in `Button`, `Action`, `Label`, or `Title` is in Title Case (two or more capitalised words not in `kit.yaml` `proper_nouns`) |
| TAC009 | error | Contrast gate failed for the current tokens (`04` §4.6); reported by `kit tokens` and re-checked by `kit check` |
| TAC010 | error | An identity hue is within 25° (OKLCH) of a status hue, or one hue is configured for both status and identity |
| PLAT001 | error | `dio` is a dependency but `android/app/src/main/AndroidManifest.xml` lacks the `INTERNET` permission |
| PLAT002 | error | `dio` is a dependency but a macOS entitlements file lacks `com.apple.security.network.client` |

Suppression: `// kit-ignore: UI001 <reason>` on the line or the line above. A suppression without a reason is itself an error (KIT001).
Rules are configurable in `kit.yaml` (severity overrides, extra excluded paths); defaults above.

## 9. `kit guard` (hook adapter)

Reads the hook event JSON from stdin (`hook_event_name`, `cwd`, `tool_name`, `tool_input`, …).
Exit `0` = allow; exit `2` = block with a one-paragraph reason on stderr that tells the agent what to do next.

| Guard | Event | Blocks when |
|---|---|---|
| `data-layer` | PreToolUse, write tools | Target path matches `lib/features/<f>/data/**` and `<f>` has no `FEATURE.md` with `source: api\|mixed` and at least one endpoint in `api_map.yaml`. Message: "Run the api-intake skill first: summarize the spec, confirm with the user, write FEATURE.md and api_map.yaml." |
| `generated` | PreToolUse, write tools | Target is `*.g.dart`, `*.freezed.dart`, `*.config.dart`, `tokens.g.dart`, `CATALOG.md`, `SCREENS.md`, `DESIGN_TOKENS.md`, a file under `.kiro/skills/tactile-design/` (vendored, upstream-owned), or a file with a `GENERATED by kit` header. Message names the regenerate command (or, for the vendored skill, says to change `design-language.md` instead). |
| `cross-feature` | PreToolUse, write tools | New content (if available in `tool_input`) adds `import '.../features/<other>/...'` from `features/<f>/`. Message points to promote-widget. |

**[VERIFY]** in Phase 0: tool names for write/edit in IDE and CLI, the `tool_input` field names for path and
content, and whether edits (str_replace style) expose the resulting content. If content is not available,
`cross-feature` runs at PostToolUse/Stop via `kit check ARCH003 --changed` instead.

## 10. Testing `kit` (unit + property-based)

`tool/kit/test/` with fixtures in `tool/kit/test/fixtures/` (small Dart projects and specs).

Properties (PBT):
- `diff(a, a)` is empty for any generated spec.
- Removing any response property from a spec yields ≥ 1 breaking finding.
- Adding any optional property yields no breaking finding.
- `gen-dto` output for any generated object schema compiles (analyzer reports no errors) and round-trips JSON (`fromJson(toJson(x)) == x`).
- `tokens.yaml` → Dart → re-parsed constants equal input values.
- `summarize` output is identical regardless of key order in the input spec.
- For any 12-step neutral, after `tune_faint_text` every contrast gate passes, and only ink-9/ink-10 changed.
- The CSS → Flutter blur conversion is monotonic and returns 0 for blur ≤ 1.
- OKLab mixing at 0 % and 100 % returns the inputs; hue distance is symmetric.
- For any (bounce, duration), the generated spring is critically damped at bounce 0 and settles within 1.5 × duration.

Golden tests for command output (stable text).
