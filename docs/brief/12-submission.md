# 12 — Submission materials

## 1. Devpost project text (outline)

**Name:** flutter-kiro-skeleton
**Tagline (≤ 60 chars):** A Flutter skeleton that teaches your AI agent to ask first.

**Inspiration** — the P1–P7 failures from `00-overview.md`, told from a solo developer's day.
**What it does** — skeleton (Clean Architecture + BLoC, adaptive, tokenized) with the tactile-design language ported
to Flutter + Kiro toolkit (6 own skills + the vendored tactile-design skill, 9 steering files, guards, `kit` CLI with
contrast gates and design lint) + two apps built with it: Orbit and Tally.
**How we built it** — spec per phase, Kiro IDE for specs/hooks, Kiro Crew for long runs, Kiro Web for planning; scripts for
everything deterministic; a third-party web design skill adapted to Flutter through steering and generated tokens.
**Built with / credits (disclosure of pre-existing work)** — tactile-design by Kosta / 4hands (MIT, vendored unchanged at
commit `30495a2`; our work is the Flutter adaptation, tokens pipeline, core widgets, and lint rules); Radix Colors data
(MIT); Inter, Space Grotesk, Plus Jakarta Sans (SIL OFL); the icon set (licence per S23); Spaceflight News API by
The Space Devs. Everything else was written during the submission period.
**Challenges** — real ones from the journal (e.g. hook input format, drift on web, agent skipping skills).
**Accomplishments** — measured against the baseline run without the toolkit (`11` Phase 2): questions asked before
coding, endpoints built without asking, duplicate widgets, overflow errors, literal design values found by `kit check`;
plus guard blocks during the build.
**What we learned** — steering vs skills vs hooks; when a script beats a prompt.
**What's next** — an auth module, a Firebase skill, Crew-native hooks, more OpenAPI constructs, bricks on BrickHub,
and the skills as a Kiro power (if not shipped).
**Links** — repo, Orbit URL, Tally URL, video, blog.

The README structure for judges and the Devpost field mapping are in `15-github-repo-guide.md` §5 and §8.

## 2. Video script (≤ 2:50)

| Time | Scene | Shows |
|---|---|---|
| 0:00–0:15 | Hook | Baseline clips from Phase 2: a plain agent builds endpoints without asking, duplicates a card, and overflows text; the counts on screen |
| 0:15–0:30 | Pitch | "flutter-kiro-skeleton: a lean Flutter skeleton + a Kiro toolkit." Repo tree, `create_app` running |
| 0:30–1:05 | Orbit: P1 + P4 | Drop spec → agent summarizes and asks → FEATURE.md → app running; new spec → impact report (renames, new endpoints) → agent asks → blogs tab appears |
| 1:05–1:15 | Guard | Agent tries to write a data source without intake → blocked message |
| 1:15–1:55 | Tally: P2 + P3 + P5 + P7 | Dashboard design → decision sheet flags the planted conflicts (two filled buttons, bold titles) and asks; budgets design → "reuse PeriodSwitcher"; cross-feature import blocked → promote-widget; "update this" image → agent lists 2 candidate screens and 4 usages |
| 1:55–2:15 | P6 + P7 | Stress test fails on a long Indonesian category at 2.0 text scale → fixed; literal padding flagged UI001; `/ui-reviewer` report on the dark dashboard |
| 2:15–2:40 | Versatility | Both apps on phone (iOS sim), tablet width, desktop (macOS) — same core widgets, different tokens |
| 2:40–2:50 | Close | URLs, "built with Kiro specs, steering, skills, hooks" |

Recording tips: 1440p screen capture, zoom on the Kiro chat, cut waiting time, captions on. No copyrighted music (use YouTube Audio Library tracks with free license or none).

## 3. Kiro write-up (answers the judges' questions)

Write from `docs/kiro-journal.md`. One section per item, with concrete examples and file links:

1. **Surfaces** — Web (planning this brief), IDE (specs, hooks, implementation, all demos), Kiro CLI (the toolkit scenarios, interactive and headless with `tool/scenarios/run.sh`), Crew (Task Runner on spec task lists, on its own branch). How they differed.
2. **Custom agents** — `flutter-dev`, `ui-reviewer`: why separate, what the reviewer caught.
3. **Agent hooks** — the guards and Stop check; numbers: how many times each guard fired while building Orbit/Tally.
4. **Spec-driven development** — 8 specs (6 at the root, 1 inside each app), EARS requirements, what Analyze Requirements caught, how tasks were structured, spec vs vibe (Phase 0 vibe vs Phase 1 spec).
5. **Steering** — always vs fileMatch vs embedded generated files (`#[[file:]]` catalog trick); what changed agent output most.
6. **MCP** — the Dart and Flutter MCP server (analysis, tests, runtime inspection while building UI); Figma MCP for design-to-ui (if done); what each enabled vs screenshots and shell commands.
7. **Property-based testing** — Kiro's spec correctness properties for `kit-check-tokens` (contrast gates, blur conversion, springs), `kit-api` (diff, gen-dto), and Tally money logic, plus `stressProperty`; which requirements got properties, and the bugs they found.
8. **Powers** — the Playwright power for checking both deployed apps at three widths and taking screenshots; the skills packaged as a power (if built); what they added.
9. **Skills** — six product skills; importing a third-party skill (tactile-design) and adapting a web skill to Flutter with steering + generated tokens instead of editing it; how skills differ from steering in this project.

## 4. `docs/kiro-journal.md` template

```markdown
## 2026-11-19 — Phase 1, skeleton-foundation
- Surface: Kiro IDE (spec tasks 1–4)
- What worked: ...
- What went wrong: ... → fix: ...
- Kiro feature used: spec / steering / hook / skill / MCP / PBT / Crew
- Numbers: guard blocks today: 3 (data-layer 1, generated 2)
- Demo clip: recordings/2026-11-16-guard.mp4
```

Guard counters: `kit guard` appends one line per block to `.dart_tool/kit/guard.log` (`timestamp guard path`);
`kit context --stats` prints totals for the write-up.

## 5. Blog post (bonus)

Title idea: "Teaching an AI agent to ask first: guards, skills and a Flutter skeleton for Kiroween 2026".
Must mention it is written for the Kiroween 2026 hackathon. Publish on dev.to or Medium during the submission period.

## 6. Social post (bonus)

Starts with `#KiroweenHackathon26`, then your favorite Kiro feature (likely hooks-as-guards) and how it changed your
approach, plus a 20–30 s clip of a guard blocking the agent. Write it yourself; judges score original thoughts over AI text.

## 7. Best Student Project (bonus)

Entered for Skeleton Crew. The form asks for your LinkedIn profile, student email, year and degree, and school name.
The organizers may ask for proof of enrollment, so keep a student card or an enrollment letter ready. It is a bonus
prize, so it stacks with a category or overall prize. Prize: $1,500 and a one-year Kiro Pro Max subscription.
