# Phase 0 runbook for the Kiro agent

Repo: `flutter-kiro-skeleton`. Plan: `docs/brief/` (Phase 0 in `docs/brief/11-roadmap.md`). Prepared 17 Nov 2026.

The user gives this file to the Kiro agent in Kiro IDE. The agent works through the stages below, ticks the boxes in
this file as it goes, and stops wherever the user has to act.

There are two ways to run it:

- **Kiro IDE:** one chat per stage, Stages 1–7 (Parts 1 and 2).
- **Kiro Crew:** the `kirocrew-conductor` agent runs Stage 1 and the spikes of Stages 5–7 as parallel work items
  (Part 3). Stages 2–4 always run by hand in Kiro IDE, before or after a Crew run, never during one.

---

## Part 1 — For the user

### Before the first chat

- [ ] Devpost: join Kiroween 2026, request the Kiro credits (Resources tab; the name on your ID must match your Devpost
      profile; deadline 1 Dec 12:00 PT), and start a submission draft.
- [ ] Discord `#kiroween-hackathon`: post the "2 repo folders" question.
- [ ] GitHub: the repo `flutter-kiro-skeleton` exists, is **public**, has the MIT licence (created with *Add license*),
      and is cloned on this Mac. In the repo on github.com: *Settings → Pages → Source: GitHub Actions*.
- [ ] In the repo root: unzip `flutter-kiro-skeleton-brief.zip` (it creates `docs/brief/`) and put this file next to
      it as `phase0-runbook.md`.
- [ ] Kiro IDE: *File → Open Folder* → the repo root. *Settings* (Cmd+,) → search "MCP" → turn MCP support on.
- [ ] Needed from Stage 3 on: install Kiro CLI (`curl -fsSL https://cli.kiro.dev/install | bash`) and Kiro Crew
      (https://kiro.dev/docs/crew/). Create a Kiro API key in your account settings and add
      `export KIRO_API_KEY="..."` to `~/.zshrc`. Never paste the key into a chat or into a file in the repo.

### Each chat

1. Open a **new chat**. Set the permission mode listed for the stage in the progress table (menu in the chat input;
   older versions show an *Autopilot* switch instead: off = Supervised, on = Accept file changes).
2. Send: `Baca phase0-runbook.md di root repo, lalu kerjakan tahap pertama yang belum selesai.`
3. Accept or reject what the agent proposes. When it says STOP, do what it asks, then come back in a new chat with the
   same message (for Stage 4, add your notes from Stage 3).

---

## Part 2 — For the agent

### Rules

- If you run in Kiro Crew, Part 3 decides: the conductor follows "Part 3 → For the conductor", and a worker (your first
  message is a conductor's seed, or `work_brief` returns an item) follows "Part 3 → For workers", which replaces these
  rules where they differ.
- Talk to the user in Indonesian. Write every file in English.
- At the start of a chat: read this file, find the first stage in the progress table that isn't ticked, tell the user
  which stage you'll do and which permission mode it expects, then do it.
- Do one stage per chat, unless the table says the next stage may follow in the same chat.
- Before each step, check whether it's already done. If it is done and correct, tick it and move on. Tick each step's
  box in this file as soon as it's finished.
- This runbook is the task. Read only the brief documents a step names; you don't need to read the rest of the brief
  (this overrides the general hint in `.kiro/steering/brief.md` for these stages).
- Shell: one command per call. No `#` comments (zsh on this Mac may pass them as arguments). No `!` inside double quotes.
- Files: create them with your file tools and copy the contents given here exactly. Keep the `#[[file:...]]` lines as
  they are: Kiro replaces them when it loads steering.
- Ask the user before: deleting any file, writing outside the repo (the `/tmp` downloads in this runbook are fine),
  installing or upgrading tools, `git push`, and changing any file in `docs/brief/` other than the Result column of
  `13-risks-and-spikes.md`.
- Never: read, print, or write `KIRO_API_KEY`; edit `skeleton/.kiro/skills/tactile-design/` after Stage 1; use
  `git add .` or `git add -A`; force-push; commit this file (Stage 7 decides what happens to it).
- If a command fails: stop that step, explain the error in plain words, propose a fix, and wait.
- STOP means: end your turn with exact instructions for the user, in Indonesian, and wait.

### Progress

| Stage | Who | Chat | Permission mode | Done |
|---|---|---|---|---|
| 1. Repo and Kiro setup | agent | new | Supervised | [ ] |
| 2. Prepare the hook, skill, CLI, and Crew tests | agent | same chat as Stage 1 is fine | Supervised | [ ] |
| 3. Manual tests | user | several new chats, terminal, Crew | as listed in Stage 3 | [ ] |
| 4. Record the test results, clean up | agent | new | Supervised | [ ] |
| 5. Tactile spike | agent + user | new | Accept file changes | [ ] |
| 6. Web spike on GitHub Pages | agent + user | new | Accept file changes | [ ] |
| 7. Other spikes and wrap-up | agent | new | Accept file changes | [ ] |

Stage 3 counts as done when the user sends you the filled-in notes.

---

## Stage 1 — Repo and Kiro setup

- [ ] **1.1 Check the starting point.** Run each command and compare.

| Command | Expected |
|---|---|
| `git rev-parse --show-toplevel` | this folder |
| `git remote get-url origin` | a github.com URL for `flutter-kiro-skeleton` |
| `head -n 1 LICENSE` | `MIT License` |
| `ls docs/brief` | 16 files: `README.md`, `00-overview.md` to `13-risks-and-spikes.md`, `15-github-repo-guide.md` (there is no 14) |
| `flutter --version` and `dart --version` | Dart 3.9 or later (needed for `dart mcp-server`) |
| `mason --version` | a version |
| `kiro-cli --version` | a version (needed only in Stage 3) |

- Not a git repo, no remote, or an incomplete brief: STOP and tell the user what's missing (Part 1).
- No `LICENSE`: ask for the copyright holder's name, then write the standard MIT licence text with the year 2026.
- No mason: ask, then run `dart pub global activate mason_cli` and remind the user to add `$HOME/.pub-cache/bin` to
  `PATH` in `~/.zshrc`.
- No kiro-cli: remind the user (Part 1) and continue.
- Tell the user the versions you found.

- [ ] **1.2 Folders and starter files.** Create the folders `.kiro/steering`, `.kiro/settings`, `.kiro/hooks`, `tool`,
  and `spikes` if they're missing. Don't overwrite existing content.

`README.md`, only if it's missing or holds just the title:

```markdown
# flutter-kiro-skeleton

A lean Flutter skeleton (Clean Architecture + BLoC) with a Kiro toolkit and the tactile-design language, built for
Kiroween 2026 (Skeleton Crew). Work in progress: the plan is in `docs/brief/`.
```

`docs/kiro-journal.md`, only if it's missing:

```markdown
# Kiro journal

Running log for the Kiro write-up. One entry per working session; the template is in `docs/brief/12-submission.md` §4.
```

- [ ] **1.3 `.gitignore`.** If it's missing, create it with exactly this content. If it exists, keep its lines and add
  the missing ones. Never add a line that ignores `.kiro`.

```gitignore
# OS and editors
.DS_Store
.idea/
*.iml
.vscode/

# Flutter / Dart, in every project folder
**/build/
**/.dart_tool/
**/.flutter-plugins
**/.flutter-plugins-dependencies
**/ios/Pods/
**/macos/Pods/
**/android/.gradle/
**/android/local.properties

# Secrets
**/env/*.json
!**/env/example.json
**/android/key.properties
*.jks
*.keystore
*.p12
*.mobileprovision
.env
.env.*

# Local work
recordings/
.spike/
**/test/**/failures/

# Never add .kiro here: the hackathon requires every .kiro/ folder to be committed.
```

- [ ] **1.4 Vendor tactile-design at commit `30495a2`.** If `/tmp/tactile-design-30495a2` doesn't exist, run
  `git clone https://github.com/kosta4a/tactile-design.git /tmp/tactile-design-30495a2`. Then run, one at a time:

1. `git -C /tmp/tactile-design-30495a2 checkout 30495a2`
2. `git -C /tmp/tactile-design-30495a2 rev-parse HEAD` → must start with `30495a2`
3. `mkdir -p skeleton/.kiro/skills`
4. `cp -R /tmp/tactile-design-30495a2/skills/tactile-design skeleton/.kiro/skills/`
5. `cp /tmp/tactile-design-30495a2/LICENSE skeleton/.kiro/skills/tactile-design/LICENSE`
6. `diff -r /tmp/tactile-design-30495a2/skills/tactile-design skeleton/.kiro/skills/tactile-design` → the only output
   is `Only in skeleton/.kiro/skills/tactile-design: LICENSE`

The folder now holds `LICENSE`, `SKILL.md`, and `references/` with 7 files. Don't edit them.

- [ ] **1.5 `THIRD_PARTY_NOTICES.md`.** Create it, or add this section if the file exists:

```markdown
# Third-party notices

## tactile-design
- Source: https://github.com/kosta4a/tactile-design, commit 30495a2
- Copyright: the tactile-design authors (Kosta / 4hands)
- Licence: MIT; the full text is in skeleton/.kiro/skills/tactile-design/LICENSE
- Use: vendored unchanged in skeleton/.kiro/skills/tactile-design/

Radix Colors, the fonts, the icon set, and the Spaceflight News API are added here when they enter the repo.
```

- [ ] **1.6 Root steering.** Create these five files with exactly this content. If a file exists with different
  content, replace it and tell the user.

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

`.kiro/steering/repo-conventions.md`

```markdown
---
inclusion: always
---
# Repo conventions
- Write code, docs, specs, and commit messages in English.
- Commit messages follow Conventional Commits (feat:, fix:, docs:, test:, refactor:, chore:).
- Never edit skeleton/.kiro/skills/tactile-design/ (vendored, MIT). Project changes go into the design-language steering.
- Don't edit app_orbit/ or app_tally/ from this workspace; open the app folder as its own workspace.
- When a spike finishes, write its result in docs/brief/13-risks-and-spikes.md. Ask before changing any other file in docs/brief/.
- Ask before adding a package or deleting files.
```

- [ ] **1.7 Dart MCP server.** Run `command -v dart`, then `dart mcp-server --help`. If the second command fails, Dart is
  too old: ask the user before running `flutter upgrade`. Create `.kiro/settings/mcp.json` with the absolute path that
  `command -v dart` printed (if the file exists, add the `dart` entry and keep the rest). The absolute path matters:
  Kiro starts MCP servers from the app, which may not see the `PATH` set in `~/.zshrc`.

```json
{
  "mcpServers": {
    "dart": {
      "command": "<absolute path printed by command -v dart>",
      "args": ["mcp-server"]
    }
  }
}
```

- [ ] **1.8 Dev format hook.** Run `printf '' | xargs -r echo xargs-ok`. If it prints an "illegal option" error, remove
  `-r ` from the command below (macOS xargs skips empty input anyway). Create `.kiro/hooks/dev-format.json`:

```json
{
  "version": "v1",
  "hooks": [
    {
      "name": "Format Dart after writes",
      "trigger": "PostToolUse",
      "matcher": "write",
      "action": {
        "type": "command",
        "command": "git ls-files -m -o --exclude-standard -- '*.dart' | xargs -r dart format"
      },
      "timeout": 60
    }
  ]
}
```

- [ ] **1.9 Command permissions (optional, outside the repo).** Ask the user (in Indonesian) whether you may add rules to
  `~/.kiro/settings/permissions.yaml` so Kiro stops asking before `flutter`, `dart`, and `mason` commands. Only after a
  yes: create the file, or add the two rules to its `rules:` list without removing existing rules. Don't add comments
  (Kiro may rewrite the file and drop them). If the write is refused, show the content and ask the user to add it.

```yaml
rules:
  - capability: shell
    match: ["flutter *", "dart *", "mason *", "tool/kit.sh *", "git status*", "git diff*", "git log*", "git add *", "git commit *"]
    effect: allow
  - capability: shell
    match: ["git push*", "rm -rf *", "sudo *"]
    effect: ask
```

- [ ] **1.10 Validate.**
  - `python3 -m json.tool .kiro/settings/mcp.json` and `python3 -m json.tool .kiro/hooks/dev-format.json` → both parse.
    If `python3` is missing, read both files back and check them by eye.
  - `ls .kiro/steering` → the five files.
  - `git check-ignore -v .kiro/steering/brief.md .kiro/hooks/dev-format.json skeleton/.kiro/skills/tactile-design/SKILL.md`
    → no output (nothing in a `.kiro` folder is ignored).
  - Ask the user to check the Kiro panel (ghost icon in the left bar) and answer: *Agent Steering & Skills* lists the five
    files; *MCP Servers* shows `dart` as connected; *Agent Hooks* lists "Format Dart after writes". If the steering isn't
    listed: Cmd+Shift+P → *Developer: Reload Window*. If `dart` isn't connected, ask for the error and fix the config.
    Wait for the answer.

- [ ] **1.11 Journal.** Append an entry (get the date from `date +%F`):

```markdown
## <date> — Phase 0, repo setup (Stage 1)
- Surface: Kiro IDE, vibe chat (Supervised), driven by phase0-runbook.md
- Done: brief, .gitignore, vendored tactile-design (30495a2), root steering, Dart MCP, dev format hook
- Versions: Flutter <x>, Dart <y>, Kiro CLI <z, or not installed yet>
- Notes: <what went wrong and how it was fixed>
```

- [ ] **1.12 Commit.** Run these one at a time; skip a commit when nothing is staged.

1. `git add .gitignore README.md LICENSE docs/brief`
2. `git commit -m "docs: add project brief and repo scaffolding"`
3. `git add skeleton/.kiro/skills/tactile-design THIRD_PARTY_NOTICES.md`
4. `git commit -m "chore: vendor tactile-design skill at 30495a2 (MIT)"`
5. `git add .kiro docs/kiro-journal.md`
6. `git commit -m "chore: add root Kiro steering, Dart MCP config, and dev format hook"`
7. Ask the user, then `git push`.

Tick Stage 1 in the progress table. Ask the user whether to continue with Stage 2 in this chat.

---

## Stage 2 — Prepare the hook, skill, CLI, and Crew tests

These files are temporary. Don't commit anything in this stage.

- [ ] **2.1 Capture and Stop hooks.** Create `.kiro/hooks/spike-capture.json`. The capture hook saves what Kiro sends to a
  hook before each file write (S1, S4). The Stop hook (S3) reports one fake problem at the end of the first turn after
  `spikes/a.txt` exists, then never again (it writes `.spike/stop-fired`), so it can't make the agent loop.

```json
{
  "version": "v1",
  "hooks": [
    {
      "name": "Spike S1/S4: capture write tool input",
      "trigger": "PreToolUse",
      "matcher": "write",
      "action": {
        "type": "command",
        "command": "mkdir -p .spike && cat > .spike/pre-$(date +%s)-$$.json"
      },
      "timeout": 10
    },
    {
      "name": "Spike S3: report one fake finding when a turn ends",
      "trigger": "Stop",
      "action": {
        "type": "command",
        "command": "mkdir -p .spike; [ -f spikes/a.txt ] || exit 0; [ -f .spike/stop-fired ] && exit 0; touch .spike/stop-fired; echo 'SPIKE001 error spikes/a.txt: add a last line that says stop-hook-seen'; echo 'SPIKE001 error spikes/a.txt: add a last line that says stop-hook-seen' >&2; exit 2"
      },
      "timeout": 10
    }
  ]
}
```

- [ ] **2.2 Block hook, switched off.** Create `.kiro/hooks/spike-block.json`. The user switches it on and off in Stage 3:
  while it's on, no agent can write files in new chats, including writes that would switch it off.

```json
{
  "version": "v1",
  "hooks": [
    {
      "name": "Spike S2: block every file write",
      "trigger": "PreToolUse",
      "matcher": "write",
      "enabled": false,
      "action": {
        "type": "command",
        "command": "mkdir -p .spike && cat > .spike/block-$(date +%s)-$$.json; echo 'Blocked by spike S2: use the api-intake skill first.' >&2; exit 2"
      },
      "timeout": 10
    }
  ]
}
```

- [ ] **2.3 Skill copy for S12.** Run `mkdir -p .kiro/skills`, then
  `cp -R skeleton/.kiro/skills/tactile-design .kiro/skills/`. Check that `.kiro/skills/tactile-design/SKILL.md` exists.
  Stage 4 removes this copy.

- [ ] **2.4 STOP.** Tick Stage 2. Give the user the Stage 3 steps and the notes template, translated into Indonesian.

---

## Stage 3 — Manual tests (the user)

Hooks and skills load when a session starts, so each test begins a new session. Run the steps in order and fill in the
notes as you go. If you don't have the CLI or Crew yet, skip that step and write "skipped".

1. **New chat in Kiro IDE, permission mode *Accept file changes*.** Send:
   `Create spikes/a.txt containing hello, then change hello to hi.`
   When the agent finishes, a test hook reports a fake problem once. Note whether the agent reacted by adding a last
   line `stop-hook-seen` to `spikes/a.txt`, and whether Kiro asked you to approve hook commands or to trust the workspace.
2. **Same chat.** Send `How should a secondary button look on a card in dark mode?` and note whether Kiro used the
   tactile-design skill (a note in the chat, or ask it "Did you use a skill?"). Then type `/` in the chat input: is
   `tactile-design` in the list?
3. **Switch the write block on.** Open `.kiro/hooks/spike-block.json`, change `"enabled": false` to `"enabled": true`,
   and save.
4. **New chat in Kiro IDE.** Send `Create spikes/ide_block.txt containing hello.` Note whether it was blocked and what the
   agent said. If it tries another way, such as a terminal command that writes the file, deny it and note it.
5. **Terminal in the repo root:** run `kiro-cli` (log in if asked). Type `/`: is `tactile-design` listed? Send
   `Create spikes/cli_block.txt containing hello.` Note whether it was blocked and whether the CLI asked you to trust the
   workspace. Exit the session.
6. **Same terminal:** run
   `kiro-cli chat --v3 --no-interactive --trust-all-tools "Create spikes/cli_headless_block.txt containing hello."`
   and copy the output.
7. **Kiro Crew:** start the gateway from the repo folder (`kirocrew gateway` run inside the repo, then open
   http://localhost:5476), or set the repo as the active project in the desktop app. In a new chat send:
   `Create spikes/crew_block.txt containing hello. Then list the steering files and skills you can see.`
   Copy the reply.
8. **Switch the write block off:** set `"enabled": false` in `.kiro/hooks/spike-block.json` and save.
9. **New chat in Kiro IDE, permission mode *Supervised*.** Send
   `Baca phase0-runbook.md lalu lanjutkan tahap berikutnya. Catatan Tahap 3 saya:` followed by your notes.

Notes template:

```text
T1 stop hook: agent added "stop-hook-seen": yes/no. What it said:
T1 approvals: asked to approve hook commands: yes/no. Asked to trust the workspace: yes/no
T2 skill by description: used: yes/no
T2 /tactile-design in the IDE list: yes/no
T4 IDE block: blocked: yes/no. Message:
T4 workaround attempted: yes/no. How:
T5 CLI: /tactile-design listed: yes/no. Blocked: yes/no. Asked to trust the workspace: yes/no
T6 CLI headless output:
T7 Crew: blocked: yes/no. Steering files and skills it listed:
```

---

## Stage 4 — Record the test results, clean up

- [ ] **4.1 Check that the block is off.** `.kiro/hooks/spike-block.json` must have `"enabled": false`. If your writes are
  blocked, ask the user to switch it off (Stage 3, step 8). Tick Stage 3 once you have the notes.
- [ ] **4.2 Collect the evidence.**
  - `ls -la .spike`, then read each `pre-*.json` and `block-*.json`. Group them by `session_id`. For each, note
    `hook_event_name`, `tool_name`, and the keys of `tool_input`: which key holds the path, and whether the full new
    content or only a replacement snippet is present.
  - `ls spikes` and `cat spikes/a.txt`. A test file that exists means the write got through on that surface.
  - The user's notes.
- [ ] **4.3 Write the results** in the Result column of `docs/brief/13-risks-and-spikes.md` for S1, S2, S3, S4, S12, S25,
  and S26: one or two sentences each with what happened and the decision (plan kept, or the row's fallback). Change only
  the Result column.
- [ ] **4.4 Fallbacks.** If a result takes a fallback, list the brief documents in that row's Affects column and what
  would change, then ask the user before editing them. If the agent got around the block with a terminal command (T4),
  say so: the plan's backstops for that are the Stop check, `kit check`, and CI.
- [ ] **4.5 Clean up (ask first).** Delete `.kiro/hooks/spike-capture.json`, `.kiro/hooks/spike-block.json`, the root
  copy `.kiro/skills/tactile-design/` (only this copy, never `skeleton/.kiro/skills/`), and the test files `spikes/*.txt`.
  Keep `.spike/` (it's gitignored) until Stage 7.
- [ ] **4.6 Journal and commit.** Add a journal entry with what each surface did. Then
  `git add docs/brief/13-risks-and-spikes.md docs/kiro-journal.md` and
  `git commit -m "docs: record hook, skill, CLI, and Crew spike results"`. Ask before `git push`.

---

## Stage 5 — Tactile spike (S15, S16, S17, S19)

Goal: check that the tactile look can be built in Flutter before Phase 1. This is throwaway spike code: keep it small
and skip the architecture. Read `docs/brief/04-design-system.md` §4–§8, then
`skeleton/.kiro/skills/tactile-design/SKILL.md` and its references `tokens.md`, `buttons-and-controls.md`, and
`surfaces-and-layering.md`.

- [ ] **5.1 Inter font.** Download the latest release zip from https://github.com/rsms/inter/releases into `/tmp`. Take the
  static `Inter-Medium.ttf` and the licence file (SIL OFL 1.1), and save them as `skeleton/assets/fonts/Inter-Medium.ttf`
  and `skeleton/assets/fonts/OFL.txt`. Add an Inter section to `THIRD_PARTY_NOTICES.md`. Space Grotesk and Plus Jakarta
  Sans come later, with spike S21 before Phase 3.
- [ ] **5.2 App.** Run `flutter create --platforms=web,macos --project-name tactile_spike spikes/tactile_spike`. Copy the
  font into the spike and register it in its `pubspec.yaml`. With the Radix sand values and the shadow recipes from
  `tokens.md` hard-coded for this spike only, build:
  - `TactileSurface` (panel and raised; fill, ring, and drop taken from the parent; light and dark), with shadows
    converted by the blur formula in 04 §4.5;
  - `Pressable` (press scale .97, hover fill, 2 px focus ring in ink-10, Enter and Space activate, a semantics label);
  - `AppButton.primary` and `AppButton.secondary` (36 px high, radius 6, Inter Medium 13/20, −0.01 em tracking);
  - `AppCard` on a panel (radius 8, padding 24, card shadow) holding a secondary and a primary button;
  - a light/dark toggle, and a "Blur" toggle that shows a modal-style overlay with a 2 px `BackdropFilter` blur.
- [ ] **5.3 Tests.**
  - Goldens of the card at 390×400, light and dark, at device pixel ratio 1, 2, and 3, in `test/goldens/`.
  - Widget tests: Tab moves focus through the buttons in order; Enter and Space trigger them; each button has a semantics
    label; `androidTapTargetGuideline` holds.
  - A test that uses `SpringDescription.withDurationAndBounce` (S15). If it doesn't compile, note it.
- [ ] **5.4 Browser reference.** Create `spikes/tactile_spike/web_reference.html` with the same button, card, and modal
  recipes in plain CSS from `tokens.md` (light and dark side by side, using the local Inter file). If the Playwright power
  is available, screenshot the page at device scale factor 2 and save the images next to the goldens.
- [ ] **5.5 STOP.** Ask the user to check and report:
  1. In `spikes/tactile_spike`: `flutter run -d chrome` and `flutter run -d macos`. Do the buttons press and show focus?
     Do Tab, Enter, and Space work?
  2. VoiceOver on macOS (Cmd+F5): are the buttons announced with their labels?
  3. The Blur toggle in Chrome: any stutter?
  4. `test/goldens/` next to `web_reference.html` in Chrome, both at 400 % zoom: do the rings, drops, and 0.5 px
     hairlines look the same?
- [ ] **5.6 Record** S15, S16 (give the constant if you tuned the blur conversion), S17, and S19 in the Result column of
  `13`. Ask before changing other brief documents (04 §4.5 holds the blur formula).
- [ ] **5.7 Journal and commit.**
  `git add spikes/tactile_spike skeleton/assets/fonts THIRD_PARTY_NOTICES.md docs/brief/13-risks-and-spikes.md docs/kiro-journal.md`,
  then `git commit -m "spike: tactile surfaces, buttons, and card in Flutter"`. Ask before `git push`.

---

## Stage 6 — Web spike on GitHub Pages (S8, S24)

- [ ] **6.1 App.** Run `flutter create --platforms=web --project-name web_spike spikes/web_spike`. Add `go_router`, `http`,
  and `cached_network_image`. Use `usePathUrlStrategy()` and two routes, `/` and `/a/b`. On `/`, fetch
  `https://api.spaceflightnewsapi.net/v4/articles/?limit=10` and show each `image_url` twice side by side, once with
  `Image.network` and once with `CachedNetworkImage`, each inside a `ClipRRect` with radius 8 and a 0.5 px border, with an
  error widget that names the loader that failed. Label each row with the image host. Add a link to `/a/b`.
- [ ] **6.2 Workflow.** Create `.github/workflows/spike-pages.yml`. Triggers: `workflow_dispatch`, and pushes to `main`
  that change `spikes/web_spike/**`. Build with `flutter build web --release --base-href /<repo name>/` (the repo name
  from `git remote get-url origin`), then copy `build/web/index.html` to `build/web/404.html`. Deploy with the official
  Pages flow: `actions/checkout`, `subosito/flutter-action` (stable channel), `actions/configure-pages`,
  `actions/upload-pages-artifact`, `actions/deploy-pages`, each at its latest major version (check each action's README).
  Permissions: `contents: read`, `pages: write`, `id-token: write`.
- [ ] **6.3 Commit and push.** `git add spikes/web_spike .github/workflows/spike-pages.yml`, then
  `git commit -m "spike: web images and deep links on GitHub Pages"`. Ask, then `git push`. Follow the run with
  `gh run list --workflow spike-pages.yml` if `gh` is installed; otherwise ask the user to watch the Actions tab. If the
  deploy fails because Pages isn't enabled, point the user to Part 1.
- [ ] **6.4 STOP.** Ask the user to open `https://<github user>.github.io/<repo name>/` in Chrome (and on an iPhone if
  possible) and report: which images load with each loader, and whether the rounded corners and the border show on the
  images that load. Then open `https://<github user>.github.io/<repo name>/a/b` directly and reload: does the page show?
- [ ] **6.5 Record** S8 and S24 in `13`, add a journal entry, commit (`docs: record web spike results`), and ask before
  pushing. Then ask the user whether to delete `.github/workflows/spike-pages.yml` now (recommended: the site keeps the
  last deploy, and Phase 5 replaces it with `deploy-pages.yml`).

---

## Stage 7 — Other spikes and wrap-up (S5, S10, S14, S23)

Use small scratch projects in `spikes/`. Record each result in `13` as soon as you have it.

- [ ] **7.1 S5: analyzer next to the code generators.** Run
  `flutter create --platforms=web --project-name deps_spike spikes/deps_spike`. In it, run
  `flutter pub add freezed_annotation json_annotation injectable get_it` and
  `flutter pub add --dev analyzer yaml args path crypto glob build_runner freezed json_serializable injectable_generator`.
  If it resolves, note the versions. If it conflicts, note the conflict and that the fallback applies (a separate
  `pubspec.yaml` for kit). Ask before deleting `spikes/deps_spike` afterwards.
- [ ] **7.2 S10: PBT library.** Compare `glados` and `kiri_check` on pub.dev (`https://pub.dev/api/packages/<name>` and
  `https://pub.dev/api/packages/<name>/score`: latest version, publish date, SDK constraint, pub points). In
  `spikes/pbt_spike` (`dart create -t package spikes/pbt_spike`), write one property with each library (for example,
  reversing a list twice returns the same list) and run `dart test`. Pick one.
- [ ] **7.3 S14: Spaceflight News API.** Get the news site names from `https://api.spaceflightnewsapi.net/v4/info/`. Compare
  the `count` of `/v4/articles/` with `news_site=A`, `news_site=B`, `news_site=A,B`, and `news_site=A&news_site=B` (URL
  encode the names) to find the multi-value format. Check the response headers for rate limits. Read the API docs
  (https://api.spaceflightnewsapi.net/v4/docs/) and the project's terms or about page for attribution and image use. The
  images come from third-party news sites, and the hackathon rules forbid copyrighted material in the video without
  permission. Record the filter format and a recommendation for the video and screenshots.
- [ ] **7.4 S23: icons.** Search pub.dev for Lucide packages (`https://pub.dev/api/search?q=lucide`). For the top
  candidates, check the latest release, the licence, and whether the stroke weight can be set. Create
  `spikes/icon_spike` (`flutter create --platforms=web,macos --project-name icon_spike spikes/icon_spike`) and render 10
  common icons (search, plus, x, check, chevron-down, copy, trash, settings, bookmark, external-link) at 14, 16, and 20 px
  next to Material Symbols Rounded at weight 300, as a golden. Pick one, or take the fallback.
- [ ] **7.5 Flutter version.** Record the output of `flutter --version` in the journal as the pinned version. Phase 1
  writes it into `skeleton/README.md` and CI.
- [ ] **7.6 Check.** Every P0 row in `13` has a result: S1, S2, S3, S4, S5, S8, S10, S12, S14, S15, S16, S17, S19, S23,
  S24, S25, S26. Tell the user which ones are still empty, and why.
- [ ] **7.7 Wrap-up.**
  1. Ask whether to delete `.spike/` (gitignored test logs).
  2. Ask what to do with this file: move it to `docs/phase0-runbook.md` and commit it (it shows how Kiro was used), or
     delete it.
  3. Add a journal entry for Phase 0. Commit (`docs: finish Phase 0 spikes`) and ask before pushing.
  4. Tick Stage 7. Tell the user which Phase 0 tasks are left for them (Devpost draft, credits, the Discord question),
     and that Phase 1 starts with the spec `skeleton-foundation`: Kiro panel → Specs → +, the starter prompt from
     `docs/brief/11-roadmap.md`, Requirements-first, then Analyze Requirements.

---

## Part 3 — Running it with Kiro Crew (`kirocrew-conductor`)

`kirocrew-conductor` is Kiro Crew's built-in conductor agent. It splits a goal into work items, starts one
`kirocrew-worker` session per item, checks each result against an acceptance condition it set before dispatch, and asks
the person only what a person must decide. It has no file-writing tools: workers do the work. Each worker works in the
conductor chat's project folder. Reference:
[work ledger](https://github.com/kirodotdev/KiroCrew/blob/main/src/kiro_crew/docs/work-ledger.md).

### What runs where

| Stages | Where | Why |
|---|---|---|
| 1 | Kiro IDE (Part 2), or Crew item C1 | One sequential job |
| 2–4 | Kiro IDE only, by hand | They test Kiro IDE, Kiro CLI, and Crew themselves. While the block hook is on, no agent can write files, so every Crew worker would stall. Run them before or after a Crew run, never during one |
| 5–7 | Crew items C2–C7 side by side, then C8 | Independent spikes, each with its own folder and result file; C8 merges the results |

### Before you start (the user)

1. Part 1 is done. Stages 2–4 are done or postponed, and `.kiro/hooks/spike-block.json` is gone or has
   `"enabled": false`.
2. No Kiro IDE agent works in this repo while the Crew run is active.
3. Start Crew from a terminal so it sees Flutter on your `PATH`: run `kirocrew gateway`, then open
   http://localhost:5476 (the first start guides you through kiro-cli sign-in).
4. Optional: add the rules from step 1.9 to `~/.kiro/settings/permissions.yaml` yourself. Crew's default engine reads the
   same file, so workers stop asking before `flutter`, `dart`, `mason`, `git add`, and `git commit`. They still ask before
   `git push`, downloads, and everything else.
5. Run `pwd` in the repo and keep the output: the goal message needs the repo's absolute path.
6. New chat in Crew:
   - switch it to **conductor mode** (or pick `kirocrew-conductor` in the agent picker) before the first message; after
     the first message the chat stays on that agent;
   - set its project to the repo with the project button in the message box, or start the chat in a sidebar folder linked
     to the repo. Without a project, Crew works in its own folder instead of your repo, and the workers inherit the
     conductor's project;
   - send the goal message below.
7. The conductor answers with a plan. Check it and reply `go`.
8. While it runs: approve tool prompts (each dispatch, `git push`, downloads); answer the items marked as needing you on
   the **Board** tab of the side panel or in the worker's own tab; do the checks C2 and C3 ask for. The session menu's
   **Crew board** lists every item and its state.

Goal message (fill in the path):

```text
Goal: run Part 3 of phase0-runbook.md for this repo. Repo path: <output of pwd>.
Read Part 3 of that file first: it lists the rounds, the items, what each item owns, its acceptance condition, and its budget.
Use at most 3 items at once. Talk to me in Indonesian.
```

### For the conductor

- Read this Part 3 fully before you plan. Read Part 2 only where an item points to it.
- Rounds: round 1 is C1, unless Stage 1 is ticked in Part 2's progress table (then skip C1). Round 2 is C2–C7. Round 3 is
  C8, once every round-2 item is closed.
- Concurrency cap: 3.
- Dispatch every item to `kirocrew-worker` with `agent_kind: "template"`.
- Acceptance: as in the table. For `file`, use an absolute path: the repo path from the goal message joined with the path
  in the table.
- Seed: the template below, filled in per item. The worker reads everything else from this file.
- One owner per shared file: only C1 and C8 write `.gitignore`, `README.md`, `THIRD_PARTY_NOTICES.md`,
  `docs/kiro-journal.md`, `docs/brief/13-risks-and-spikes.md`, and this file. Only C1, C3, and C8 run `git commit`.
- Items that wait on the person: C1 (permission rules, push), C2 (visual checks), C3 (push, browser checks), C8 (review).
  Park only that item and keep the others going.

| Item | Title | Round | Steps | Owns | Acceptance | Budget |
|---|---|---|---|---|---|---|
| C1 | Repo setup (Stage 1) | 1 | Stage 1, with the C1 changes below | every file Stage 1 creates | `file`: `spikes/crew-run/C1.md` | 40m |
| C2 | Tactile spike (S15, S16, S17, S19) | 2 | Stage 5 | `spikes/tactile_spike/`, `skeleton/assets/fonts/` | `file`: `spikes/crew-run/C2.md` | 150m |
| C3 | Web spike on GitHub Pages (S8, S24) | 2 | Stage 6 | `spikes/web_spike/`, `.github/workflows/spike-pages.yml` | `file`: `spikes/crew-run/C3.md` | 90m |
| C4 | Analyzer next to the code generators (S5) | 2 | step 7.1 | `spikes/deps_spike/` | `file`: `spikes/crew-run/C4.md` | 20m |
| C5 | PBT library (S10) | 2 | step 7.2 | `spikes/pbt_spike/` | `file`: `spikes/crew-run/C5.md` | 30m |
| C6 | Spaceflight News API (S14) | 2 | step 7.3 | only its result file | `file`: `spikes/crew-run/C6.md` | 20m |
| C7 | Icon set (S23) | 2 | step 7.4 | `spikes/icon_spike/` | `file`: `spikes/crew-run/C7.md` | 45m |
| C8 | Integrate the results | 3 | "Item C8" below | `docs/brief/13-risks-and-spikes.md`, `docs/kiro-journal.md`, `THIRD_PARTY_NOTICES.md`, this file, `spikes/crew-run/C8.md` | `human_approval` | 40m |

Seed template:

```text
budget: <budget>
You are the worker for item <id> (<title>) of the Kiro Crew run in phase0-runbook.md at the repo root.
Read "Part 3 → For workers" in that file, then do your item's steps: <steps>.
You own only <owns> and your result file spikes/crew-run/<id>.md. Don't change any other file.
Done when spikes/crew-run/<id>.md exists, written last in the format Part 3 gives. Report done with that path in artifacts.
```

### For workers

These rules replace Part 2's rules where they differ.

- Talk to the user in Indonesian. Write files in English. Your item's steps are in Part 2; the changes are below.
- Touch only the files your seed says you own, plus your result file. Unless you are C1 or C8, never edit `docs/brief/`,
  `docs/kiro-journal.md`, `THIRD_PARTY_NOTICES.md`, `.gitignore`, `README.md`, or this file. Don't tick boxes in this
  file: C8 does that.
- Where a step says to record a result in `13`, add a journal entry, add to `THIRD_PARTY_NOTICES.md`, or commit, put that
  content in your result file instead. Exceptions: C1 commits as Stage 1 says, and C3 commits only `spikes/web_spike` and
  `.github/workflows/spike-pages.yml` (it must push for Pages to deploy).
- Where a step says STOP, report `question` with reason `needs_human`, say exactly what the user should do (in
  Indonesian), and wait for the answer in your tab or from the conductor.
- Ask the same way before deleting files or writing outside the repo (the `/tmp` downloads are fine). `git push` asks
  through Crew's approval prompt. Don't delete your spike folder or workflow afterwards: C8 asks the user about cleanup.
- Part 2's shell rules hold: one command per call, no `#` comments, no `!` inside double quotes.
- Other workers run `flutter` at the same time. If you see "Waiting for another flutter command to release the startup
  lock", wait; don't delete the lock file.
- If `flutter` or `dart` isn't found, report `blocked` with reason `needs_human`: the user should restart the Crew
  gateway from a terminal.
- Write your result file last, then report `done` with its path in `artifacts`.

Result file format (`spikes/crew-run/<id>.md`):

```markdown
# <id> — <title>
- Date: <date +%F>
- Results: one line per spike, `S<n>: <what happened>. Decision: <plan kept | fallback: ...>.`
- Files created or changed: <paths>
- Checked by the user: <what, or "nothing needed">
- Brief changes proposed: <document, section, and the change; or "none">
- Third-party additions for THIRD_PARTY_NOTICES.md: <name, licence, path; or "none">
- Journal notes: <2–4 lines for docs/kiro-journal.md>
- Skipped: <what and why; or "nothing">
```

### Changes for C1

- 1.9: report `question` (`needs_human`) with the YAML and ask the user to add it to the file themselves.
- 1.10, last bullet: instead of the Kiro panel, ask the user to open **Customize → Steering files** in Crew and confirm
  the five workspace files are listed for this chat's project. Skip the MCP check: Crew's default agent merges only
  `~/.kiro/settings/mcp.json`, so the workspace `mcp.json` is checked the next time the repo is open in Kiro IDE.
- 1.11 and 1.12: also write `spikes/crew-run/C1.md`, and add it to the third commit
  (`git add .kiro docs/kiro-journal.md spikes/crew-run/C1.md`).

### Item C8 — integrate the results

1. Read every `spikes/crew-run/C*.md`.
2. Write each spike's result into the Result column of `docs/brief/13-risks-and-spikes.md`. Change nothing else there.
3. Add the third-party entries to `THIRD_PARTY_NOTICES.md`, and one journal entry for the Crew run: what each item did,
   and the Crew features used (conductor, workers, Board, approvals).
4. List the brief changes the result files propose. Report `question` (`needs_human`) and make only the ones the user
   approves.
5. Do Stage 7 steps 7.5–7.7. Ask before deleting `spikes/deps_spike` or `.github/workflows/spike-pages.yml`.
6. Tick in Part 2's progress table: Stage 1 (if it's done), 5, 6, and 7. Leave Stages 2–4 as they are.
7. Commit `docs/brief/13-risks-and-spikes.md`, `docs/kiro-journal.md`, `THIRD_PARTY_NOTICES.md`, and `spikes` with
   `git commit -m "docs: record Phase 0 spike results from the Kiro Crew run"`. Add this file only if the user chose to
   keep it as `docs/phase0-runbook.md`. Ask before `git push`.
8. Write `spikes/crew-run/C8.md` and report `done`. The conductor then asks the user to approve.
