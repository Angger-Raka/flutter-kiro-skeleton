# 06 — Kiro toolkit (inside `skeleton/.kiro/`)

The toolkit is what the end user (a solo Flutter developer) gets when they open a generated app in Kiro.
Kiro docs used: [Steering](https://kiro.dev/docs/steering/), [Skills](https://kiro.dev/docs/skills/),
[Hooks](https://kiro.dev/docs/hooks/), [Hook types](https://kiro.dev/docs/hooks/types/),
[Custom agents](https://kiro.dev/docs/custom-agents/configuration-reference/),
[MCP configuration](https://kiro.dev/docs/mcp/configuration/).

```
.kiro/
├── steering/
│   ├── product.md            always
│   ├── tech.md               always
│   ├── architecture.md       always
│   ├── workflow.md           always
│   ├── catalog.md            always   (embeds generated CATALOG.md + SCREENS.md)
│   ├── design-language.md    fileMatch (tactile-design in Flutter: mapping, deviations, never-ship)
│   ├── ui-resilience.md      fileMatch
│   ├── api-layer.md          fileMatch
│   └── testing.md            fileMatch
├── skills/
│   ├── tactile-design/       VENDORED from kosta4a/tactile-design@30495a2 (MIT), never edited
│   │   ├── SKILL.md, LICENSE, references/*.md
│   ├── api-intake/SKILL.md
│   ├── api-update/SKILL.md
│   ├── design-to-ui/SKILL.md
│   ├── ui-update/SKILL.md
│   ├── promote-widget/SKILL.md
│   └── new-feature/SKILL.md
├── hooks/
│   └── kit-guards.json
├── agents/
│   ├── flutter-dev.md
│   └── ui-reviewer.md
└── settings/
    └── mcp.json              Dart and Flutter MCP server (enabled), Figma MCP (disabled until configured)
```

## 1. Design rules for the toolkit

- Steering states **rules**; skills state **procedures**; `kit` does **computation**; hooks **enforce**.
- Always-on steering stays under ~1,500 words total (excluding embedded generated files). Detailed rules load by fileMatch.
- Our skills keep `SKILL.md` actionable (< 300 lines) and put long material in `references/`.
- The vendored `tactile-design` skill is upstream-owned. Project-specific changes go into `design-language.md`,
  never into the skill folder (the `generated` guard blocks edits there).
- Every skill ends with a **Definition of done** that includes `kit check` passing.
- Skills reply in the user's language; files they write are English.
- Every "ask the user" step uses a compact, numbered question list with a proposed default for each question.

## 2. Steering files

### `product.md` (always) — template, filled per app
Sections: Product summary · Target users · Core features (links to FEATURE.md files) · Non-goals · Platforms · Tone of copy.

### `tech.md` (always)
- Stack table (`03-architecture.md` §2) and the one approved package per need.
- "Do not add a package without asking. Propose it with reason, size, and maintenance status."
- Commands: `flutter pub get`, `dart run build_runner build -d`, `kit check`, `kit tokens`, `flutter test` (stress
  profile `quick`), `flutter test --dart-define=STRESS=full` (CI), `flutter test --tags golden` (on the developer's
  Mac only), `mason make <brick>`.
- Env: `--dart-define-from-file=env/dev.json`.

### `architecture.md` (always)
- Layer table and dependency rules (`03` §3), naming (`03` §5), core module map (`03` §4).
- "Features never import other features. Shared UI goes to `core/widgets` via the promote-widget skill."
- "Never hand-edit generated files or the vendored tactile-design skill."

### `workflow.md` (always) — routing table for the agent
| When the user… | Do |
|---|---|
| shares an OpenAPI/Swagger/Postman/API doc for something new | `api-intake` skill |
| shares a new version of an API spec, or says the API changed | `api-update` skill |
| shares a design (image/Figma) for a new screen or widget | `design-to-ui` skill |
| shares an image of changes to an existing UI, with or without a location | `ui-update` skill |
| asks to review, polish, or "make it feel better" | `/ui-reviewer` agent, then apply chosen fixes with the tactile-design skill |
| needs a feature widget in a second feature | `promote-widget` skill |
| asks for a feature without API and without design | `new-feature` skill |
| touches any UI | load the `tactile-design` skill and follow `design-language.md` |

Universal loop: **understand → check what exists (`CATALOG.md`, `SCREENS.md`, `api_map.yaml`, `DESIGN_TOKENS.md`)
→ ask → scaffold with Mason → implement → test → `kit check` → summarize changes**.
"If a request is ambiguous about location, feature, or scope, ask. Do not guess silently."

### `catalog.md` (always)
```markdown
---
inclusion: always
---
# What already exists
Before creating any widget, search this catalog (or run `kit catalog similar <Name>`).
#[[file:lib/core/widgets/CATALOG.md]]
#[[file:docs/SCREENS.md]]
```
Budget: if the two generated files exceed ~6,000 tokens combined, `kit catalog` writes a compact form (one line per
widget) and the skills read the full file on demand.

### `design-language.md` — fileMatch `["lib/**/presentation/**", "lib/core/widgets/**", "lib/core/layout/**", "lib/core/theme/**", "design/**"]`
Condensed from `04-design-system.md`:
1. "This project uses tactile-design. Load the `tactile-design` skill for the decision order and rules. Apply them
   through tokens and core widgets; never write CSS concepts in Dart."
2. Precedence (`04` §1) and the deviations table (`04` §2).
3. Window classes and input mode (`04` §3).
4. Role → Flutter mapping: which core widget implements each tactile component (`04` §7), which `context.text.*`
   role to use (`04` §6), which `AppMotion` token (`04` §8).
5. How to read tokens: `docs/DESIGN_TOKENS.md` (generated). Never invent a value; if none fits, ask.
6. Never-ship checklist, Flutter edition (the skill's list, minus web-only items, plus TAC rules).
7. Report format for UI changes: *Changed / Moved / Flag* bullets.

### `ui-resilience.md` — same fileMatch
`04` §11 rules with before/after snippets, plus how to write a stress test (`04` §12).

### `api-layer.md` — fileMatch `["lib/**/data/**", "api/**"]`
Data-layer conventions (`03` §5), `guardRepository`, mapper and pagination patterns, error mapping,
"DTOs are generated; change the spec mapping, not the DTO".

### `testing.md` — fileMatch `["test/**"]`
bloc_test pattern, mocktail conventions, stress profiles (quick by default, full in CI), accessibility checks, goldens
(light + dark, DPR 2, generated on the developer's Mac), fixture helpers.

## 3. Skills

Format: `.kiro/skills/<name>/SKILL.md` with front matter `name` (matches the folder) and `description`.
Full procedures with example dialogues are in `07-workflows.md`; each SKILL.md is a condensed version of the matching section.

| Skill | Source | Description (front matter) | references/ |
|---|---|---|---|
| `tactile-design` | **vendored**, upstream MIT | (upstream) design-engineering rules and decision process for tactile, layered, quiet product UI | upstream: tokens, buttons-and-controls, surfaces-and-layering, layout-and-hierarchy, motion, mobile, decisions |
| `api-intake` | ours | Turn API documentation (OpenAPI, Swagger, Postman, or prose) into a feature. Use when the user shares an API spec or docs for functionality that does not exist yet. | `question-bank.md`, `pagination-patterns.md` |
| `api-update` | ours | Apply a new version of an API spec safely: diff, impact per feature, confirm, regenerate, update code. Use when the user shares an updated spec or says an API changed. | `breaking-change-playbook.md` |
| `design-to-ui` | ours | Build screens or widgets from a design image or Figma frame with tactile-design, reusing the core widget catalog and design tokens. Use when the user shares a design for something new. | `component-classification.md`, `token-mapping.md`, `design-conflicts.md` |
| `ui-update` | ours | Change an existing screen from an image or description: locate the screen, list differences, assess shared-widget impact, then apply. Use when the user shares a UI change, even without saying where. | `locating-screens.md` |
| `promote-widget` | ours | Move a feature widget into core/widgets so other features can use it. Use when a widget is needed in more than one feature or flagged by WID001/ARCH003. | — |
| `new-feature` | ours | Create a feature without an API spec or design: clarify purpose and flows, write FEATURE.md, scaffold. | — |

`design-to-ui` and `ui-update` start by activating `tactile-design` (step 0), so the decision order runs before any
component is chosen.

Skill body skeleton (our skills):
```markdown
---
name: api-intake
description: ...
---
# API intake
## Inputs
## Steps            (numbered; each step names the kit command or the question to ask)
## Questions to ask (with defaults)
## Never
## Definition of done
```

## 4. Hooks (`.kiro/hooks/kit-guards.json`)

Only triggers that run on IDE, CLI, and Web are used (PreToolUse, PostToolUse, Stop, SessionStart, UserPromptSubmit).

```json
{
  "version": "v1",
  "hooks": [
    { "name": "Guard: data layer requires API intake", "trigger": "PreToolUse", "matcher": "write",
      "action": { "type": "command", "command": "tool/kit.sh guard data-layer" }, "timeout": 10 },
    { "name": "Guard: generated and vendored files are read-only", "trigger": "PreToolUse", "matcher": "write",
      "action": { "type": "command", "command": "tool/kit.sh guard generated" }, "timeout": 10 },
    { "name": "Guard: no cross-feature imports", "trigger": "PreToolUse", "matcher": "write",
      "action": { "type": "command", "command": "tool/kit.sh guard cross-feature" }, "timeout": 10 },
    { "name": "Format and regenerate after writes", "trigger": "PostToolUse", "matcher": "write",
      "action": { "type": "command", "command": "tool/kit.sh post-write" }, "timeout": 60 },
    { "name": "Check before finishing", "trigger": "Stop",
      "action": { "type": "command", "command": "tool/kit.sh check --changed" }, "timeout": 120 },
    { "name": "Session context", "trigger": "SessionStart",
      "action": { "type": "command", "command": "tool/kit.sh context" }, "timeout": 20 },
    { "name": "Route API and design inputs to skills", "trigger": "UserPromptSubmit",
      "action": { "type": "command", "command": "tool/kit.sh route-prompt" }, "timeout": 5 }
  ]
}
```

| Hook | Behavior |
|---|---|
| guards | See `05-kit-cli.md` §9. Exit 2 + reason on stderr blocks the write. |
| `post-write` | `*.dart` → `dart format`. `design/tokens.yaml` → `kit tokens`. `lib/core/widgets/**`, `lib/core/layout/**` → `kit catalog`. `lib/app/router/**`, `**/pages/**` → `kit screens`. `build_runner` is not run per write (too slow); `check` reports stale codegen instead. |
| `check --changed` | Fast rules on changed files + `--check` of generated files. **[VERIFY S3]** whether Stop output makes the agent continue; fallback: `workflow.md` tells the agent to run `kit check` itself before finishing. |
| `context` | Prints `kit context` (≤ 15 lines). |
| `route-prompt` | Reads `USER_PROMPT`. Spec content or path → "Use the api-intake (or api-update) skill." Image, Figma URL, "design", "screen" → "Use design-to-ui (or ui-update) and the tactile-design skill." "review", "polish", "looks off" → "Run /ui-reviewer first." Never blocks. |

Command paths are relative to the workspace root (hooks run in the project root).

## 5. Custom agents

### `.kiro/agents/flutter-dev.md`
```markdown
---
name: flutter-dev
description: Builds features in this Flutter skeleton following its steering, skills, tactile-design, and kit checks.
tools: ["read", "write", "shell", "web", "@mcp"]
includeMcpJson: true
resources:
  - file://.kiro/steering/**/*.md
  - skill://.kiro/skills/*/SKILL.md
welcomeMessage: "Flutter skeleton agent ready. Share an API spec, a design, or describe a feature."
---
You build Flutter features in this repository. Follow workflow.md for every request.
Prefer kit commands and Mason bricks over writing boilerplate. Use core widgets and tokens for all UI.
Ask before guessing.
```
Custom agents don't load steering automatically, hence the `resources` entries (the skill glob includes tactile-design).

### `.kiro/agents/ui-reviewer.md`
- Read-only: `tools: ["read", "shell"]`; shell limited by `permissions` to `flutter test *` and `tool/kit.sh *`.
- Resources: `design-language.md`, `ui-resilience.md`, the `tactile-design` skill, `DESIGN_TOKENS.md`, `CATALOG.md`.
- Procedure:
  1. Run goldens for the target views (light + dark).
  2. Compare each golden with its design reference (`kit refs`), the tactile decision order, and the never-ship list.
  3. Check worst-case data in stress-test output.
  4. Report in the tactile format: **Changed** (proposed), **Moved**, **Flag** (conflicts with an earlier rule),
     each with screen, rule, severity, and the smallest fix. Never edit files.
- Runs after deterministic checks pass. Invoked by `design-to-ui` and `ui-update` as an optional last step, or
  directly with `/ui-reviewer`.

## 6. Surface compatibility

| Component | Kiro IDE | Kiro CLI (V3) | Kiro Web | Kiro Crew |
|---|---|---|---|---|
| Steering `.kiro/steering/` | ✓ | ✓ | ✓ | ✓ (project steering) |
| Skills `.kiro/skills/` (incl. tactile-design) | ✓ | ✓ | ✓ | Through the kiro-cli backend **[VERIFY S25]**; fallback: import from GitHub into `~/.kiro/crew/skills/` |
| Hooks `.kiro/hooks/*.json` | ✓ | ✓ (also in `--v3 --no-interactive` runs) | ✓ (5 triggers used) | Through the kiro-cli backend **[VERIFY S25]**; fallback: Crew's own `~/.kiro/crew/hooks.json` calling `tool/kit.sh guard ...` |
| Custom agents | ✓ | ✓ | ✓ | Crew runs agents as `kiro-cli acp --agent <name>` and reads the project's `.kiro/agents/`; Markdown agents **[VERIFY S25]** |
| MCP `.kiro/settings/mcp.json` | ✓ | ✓ | depends on sandbox | through kiro-cli |
| `kit` + CI | ✓ | ✓ | ✓ | ✓ |

Crew runs every agent as `kiro-cli acp` and reads a project's own `.kiro/agents/`
([KiroCrew architecture](https://github.com/kirodotdev/KiroCrew/blob/main/docs/architecture/overview.md)), so the
workspace steering, skills, and hooks may load there too. S25 tests it. Until it passes, use Crew only for unattended
task runs in Phases 1–2 (on its own git branch), never for the demo phases 3–4. The user guide's surfaces page (§9)
records the result. CI (`kit check` in GitHub Actions) is the last line of defense for every surface.

## 7. MCP (`.kiro/settings/mcp.json`)

```json
{
  "mcpServers": {
    "dart": { "command": "dart", "args": ["mcp-server"] },
    "figma": { "url": "<official Figma MCP URL>", "disabled": true }
  }
}
```

- **Dart and Flutter MCP server** (official, `dart mcp-server`, see [docs.flutter.dev/ai/mcp-server](https://docs.flutter.dev/ai/mcp-server)):
  analyzer diagnostics, symbol resolution, test runner, pub, runtime inspection. Enabled by default. Agents use it
  to run analysis and tests and to inspect the running app while building UI.
- **Figma MCP** (official, optional, **[VERIFY S13]** URL and auth): used by `design-to-ui` and `ui-update` for
  frame screenshots, layout, and variables. Figma variables are mapped to tactile roles and `DESIGN_TOKENS.md`
  names (`token-mapping.md`); unmapped values are asked about, never hardcoded. Without it, both skills work from images.
- Official Flutter agent skills (`flutter/agent-plugins`) are **not** installed in the skeleton: their layout and state
  guidance could conflict with this architecture and design language. Evaluate later.

## 8. Toolkit behavior scenarios

`skeleton/docs/toolkit-testing.md` lists the hook tests and these scenarios, each with a prompt, setup, and pass
criteria. Run them in Kiro IDE before recording a demo. The ones marked CLI also run unattended through
`tool/scenarios/run.sh` (repo root): it creates a throwaway app with `create_app`, runs
`kiro-cli chat --v3 --no-interactive --trust-all-tools "<prompt>"` with `KIRO_API_KEY` set, and checks the files and
the output. V3 headless runs load the workspace hooks ([Kiro CLI headless mode](https://kiro.dev/docs/cli/headless/)),
so the guards are active. Results go into the journal.

| # | Scenario | Prompt (short) | Pass when | Where |
|---|---|---|---|---|
| SC1 | api-intake asks first | the SNAPI spec in `api/openapi.yaml` + "Build the app." | the agent asks the intake questions; no file under `lib/features/*/data/` changes in that turn | IDE + CLI |
| SC2 | data-layer guard | "Add a reports remote data source." (no FEATURE.md) | the write is blocked and the agent points to api-intake | IDE + CLI |
| SC3 | generated guard | "Fix the spacing value in tokens.g.dart." | blocked; the agent edits `design/tokens.yaml` and runs `kit tokens` instead | IDE + CLI |
| SC4 | cross-feature guard | "Reuse the home feature's widget in a new feature called profile." | the import is blocked and promote-widget is proposed | IDE + CLI |
| SC5 | api-update impact first | a changed spec + "The API changed." | an impact report and questions before any code change | IDE |
| SC6 | design-to-ui reuse | an image that contains an existing core widget | the classification table marks it reuse | IDE |
| SC7 | design conflict | an image with two filled buttons and bold titles | each conflict is listed and asked about | IDE |
| SC8 | ui-update locate | an image of a changed row + "update this" | candidate screens and usages listed; nothing edited before the answer | IDE |

## 9. User guide (for developers who use the skeleton)

The brief is the build plan; developers who use the skeleton need their own guide. It is written in English during the
`kiro-toolkit` spec, finished in the `release` spec, and copied into every app by `create_app`.

| File | Content |
|---|---|
| `skeleton/README.md` | What it is, requirements (Flutter, Kiro, Mason), quick start, links to the guide |
| `docs/guide/getting-started.md` | `create_app`, opening the folder in Kiro, trusting the workspace if asked, filling `product.md`, the first prompts |
| `docs/guide/design.md` | tactile in Flutter, the `tokens.yaml` knobs (neutral, hues, fonts, radius), contrast gates, the theme setting |
| `docs/guide/workflows.md` | Every skill and `/ui-reviewer`, with example prompts and what the agent will ask |
| `docs/guide/kit.md` | Commands, check rules, suppressions |
| `docs/guide/extending.md` | Adding a feature, a core widget, or a package; adding auth (not included; the auth interceptor is the extension point); Firebase later |
| `docs/guide/surfaces.md` | Kiro IDE, Kiro CLI (interactive and headless), and Kiro Crew: what works where (from S25 and S26) |
| `docs/guide/troubleshooting.md` | Hooks not firing, skills not activating, approval prompts, MCP offline, goldens, platform permissions |

## 10. Packaging the skills as a Kiro power (optional)

Powers follow the Agent Plugins format: a `plugin.json` manifest, a `skills/` folder, and an optional `mcp.json`
([Kiro powers](https://kiro.dev/docs/powers/)). A `power/` folder at the repo root can bundle the six product skills,
the vendored tactile-design skill (with its licence), and the Dart MCP config, so other Flutter projects can install
them from the GitHub URL. The guards and `kit` still need the skeleton. Build it in the `release` spec only if time
allows (cut order in `11`).
