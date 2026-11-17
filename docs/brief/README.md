# flutter-kiro-skeleton — Project Brief

This folder is the complete brief for building **flutter-kiro-skeleton**, a submission to the
Kiroween 2026 hackathon (Skeleton Crew category). It is written to be handed to Kiro (IDE or Crew)
as the source of truth for specs, steering, and implementation.

## Documents

| # | File | What it defines |
|---|---|---|
| 00 | [00-overview.md](00-overview.md) | Goal, problems solved, decisions, success criteria |
| 01 | [01-hackathon-requirements.md](01-hackathon-requirements.md) | Rules that the submission must satisfy |
| 02 | [02-repository-structure.md](02-repository-structure.md) | Repo layout, `create_app`, `sync_core`, what goes where |
| 03 | [03-architecture.md](03-architecture.md) | Skeleton app: stack, layers, conventions, core modules, core widgets |
| 04 | [04-design-system.md](04-design-system.md) | tactile-design for Flutter: deviations, tokens, surfaces, type, components, motion, resilience, stress tests |
| 05 | [05-kit-cli.md](05-kit-cli.md) | The `kit` CLI: every command, input/output, file formats, check rules |
| 06 | [06-kiro-toolkit.md](06-kiro-toolkit.md) | Steering, skills (incl. the vendored tactile-design), hooks, custom agents, MCP |
| 07 | [07-workflows.md](07-workflows.md) | End-to-end user workflows (the 7 problems + UI review) with example dialogues |
| 08 | [08-app-orbit.md](08-app-orbit.md) | Demo app 1: Orbit, a spaceflight news reader (API-driven) |
| 09 | [09-app-tally.md](09-app-tally.md) | Demo app 2: Tally, an expense and budget tracker (design-driven) |
| 10 | [10-quality-ci-deploy.md](10-quality-ci-deploy.md) | Tests, CI, deployment, platform builds |
| 11 | [11-roadmap.md](11-roadmap.md) | Phases, tasks, acceptance criteria, dates, cut order, spec prompts |
| 12 | [12-submission.md](12-submission.md) | Devpost text, credits, video script, Kiro write-up, journal |
| 13 | [13-risks-and-spikes.md](13-risks-and-spikes.md) | Unverified assumptions and how to test them on day 1 |
| 15 | [15-github-repo-guide.md](15-github-repo-guide.md) | What to upload to GitHub, what never to commit, repo settings, README, release, final checks, Devpost field mapping |

Read order for a human: 00 → 01 → 15 → 02 → 03 → 04 → 06 → 07 → 11.
Read order for an implementing agent: the document referenced by the current spec, plus 03 and 05.

## How to use this brief with Kiro

The tasks and the starter prompt for every spec are in [11-roadmap.md](11-roadmap.md). Setup:

1. Create the GitHub repo `flutter-kiro-skeleton` and copy this folder to `docs/brief/`.
2. Create root steering so Kiro always knows the brief exists, without loading all of it:

   `.kiro/steering/brief.md`
   ```markdown
   ---
   inclusion: always
   ---
   # Project brief
   This repo is built from the brief in `docs/brief/`. Treat it as the source of truth.
   Before working on a phase, read `docs/brief/11-roadmap.md` and the documents it references.
   If an instruction here conflicts with the brief, ask instead of guessing.
   Overview: #[[file:docs/brief/00-overview.md]]
   ```

   `.kiro/steering/brief-architecture.md`
   ```markdown
   ---
   inclusion: fileMatch
   fileMatchPattern: ["skeleton/lib/**", "skeleton/test/**", "skeleton/bricks/**"]
   ---
   #[[file:docs/brief/03-architecture.md]]
   ```

   `.kiro/steering/brief-design.md`
   ```markdown
   ---
   inclusion: fileMatch
   fileMatchPattern: ["skeleton/lib/core/theme/**", "skeleton/lib/core/widgets/**", "skeleton/lib/core/layout/**", "skeleton/lib/**/presentation/**", "skeleton/design/**"]
   ---
   The design language is tactile-design adapted to Flutter. Follow the Flutter mapping and deviations below,
   and the upstream rules after them. Never write CSS concepts in Dart. Open the skill's references in
   skeleton/.kiro/skills/tactile-design/references/ when working on that area.
   #[[file:docs/brief/04-design-system.md]]
   #[[file:skeleton/.kiro/skills/tactile-design/SKILL.md]]
   ```

   `.kiro/steering/brief-kit.md`
   ```markdown
   ---
   inclusion: fileMatch
   fileMatchPattern: ["skeleton/tool/**", "skeleton/.kiro/**", "tool/**"]
   ---
   #[[file:docs/brief/05-kit-cli.md]]
   #[[file:docs/brief/06-kiro-toolkit.md]]
   ```
3. Create the specs listed in `11-roadmap.md` with their starter prompts (two or three per phase in Phases 1–2).
4. Keep `docs/kiro-journal.md` updated as you go (template in `12-submission.md`). It becomes the write-up.

### Kiro IDE vs Kiro Crew for building this repo

- **Kiro IDE** is the primary surface. Specs, all hook triggers, and the spec task UI are available.
- **Kiro Crew** runs long task lists unattended with its Task Runner: each task in its own session, tested, reviewed,
  and committed on a separate git branch. Crew reads the project's `.kiro/steering/`; whether workspace skills and
  hooks also load through its kiro-cli backend is checked in S25 (`13-risks-and-spikes.md`). Use Crew for task runs
  in Phases 1–2, review and merge the branch in the IDE, and never use it for the demo phases 3–4.
- **Kiro CLI** runs the toolkit scenarios (`06-kiro-toolkit.md` §8), interactively or headless.

## Conventions used in this brief

- **MUST / SHOULD / MAY** have their RFC 2119 meaning.
- `kit <command>` means `dart run kit:kit <command>` run from an app root (see `05-kit-cli.md`).
- Items marked **[VERIFY]** are assumptions that must be confirmed during Phase 0 (see `13-risks-and-spikes.md`).
- "tactile" or "the skill" means the vendored tactile-design skill at commit `30495a2`.
- All repository content is written in English because Devpost submission materials must be in English.
