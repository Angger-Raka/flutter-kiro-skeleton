# 13 — Risks and spikes

Run the spikes marked **P0** on 17–18 Nov. Run the others just before the phase that needs them (column *When*).
If a spike takes more than two hours, take its fallback and move on. Record the result and the decision in the
*Result* column, and update the referenced brief document whenever a fallback is taken.

## Spikes

| # | Question | How to test | Fallback | Affects | When | Result |
|---|---|---|---|---|---|---|
| S1 | Which tool names and `tool_input` fields does a PreToolUse hook receive for file writes and edits in Kiro IDE and CLI? Is the new content available? | Hook with matcher `write` that saves its stdin to `.spike/`; ask the agent to create a file, then edit it | Guards that need content run at PostToolUse/Stop via `kit check --changed` | 05 §9, 06 §4 | P0 | |
| S2 | Does exit 2 on PreToolUse block the write in IDE and CLI, and does the agent see stderr? Do hook commands need approval? | Hook that always exits 2 with a message | Rely on Stop + CI | 06 §4 | P0 | |
| S3 | Is a Stop hook's output shown to the agent, and does it continue to fix issues? | Stop hook that prints a fake finding and exits 1 | `workflow.md` tells the agent to run `kit check` before finishing; the Stop hook only reports | 06 §4 | P0 | |
| S4 | Does `matcher: "write"` match both create and edit tools? | Same as S1 | List tool IDs explicitly | 06 §4 | P0 | |
| S5 | Can `kit` (analyzer) and freezed/json_serializable/injectable_generator resolve together as dev dependencies? | `flutter pub add --dev` in a fresh project | Separate pubspec under `tool/kit`, run via `dart run tool/kit/bin/kit.dart` | 05 §1 | P0 | |
| S6 | Guard latency with `dart run` vs a compiled exe | Time 20 guard calls | Compiled exe required; `kit doctor --install` builds it | 05 §1 | P2 | |
| S7 | drift on Flutter Web (wasm + worker): setup and persistence | Minimal app: insert, reload the page, read | `hive_ce` | 09 §2 | before P4 | |
| S8 | GitHub Pages deep links with the path URL strategy | Deploy a hello app with a `/a/b` route, reload | Hash URL strategy | 10 §2 | P0 (with S24) | |
| S9 | Are goldens identical across runs on the Mac, and on a GitHub macOS runner (optional)? | Run the same goldens twice locally and once on `macos-latest` | Goldens stay local to the Mac (the plan) | 04 §12 | P1 | |
| S10 | PBT library: glados vs kiri-check (Dart 3, last release, API fit, works with Kiro's spec correctness tests) | pub.dev scores + one sample property each | Hand-rolled random generators with a fixed seed | 03 §2 | P0 | |
| S11 | Mason non-interactive generation from the agent (`mason make x --name y`, `--on-conflict`) and a post_gen hook running `kit catalog` | Create a brick and run it from a Kiro shell | Plain Dart template script in `kit feature new` | 05, 06 | P1 | |
| S12 | Skill activation by description and as a `/slash` command in the IDE; `references/` loading; the vendored tactile-design skill (17.8 KB) loads fully | Copy the skill, ask "make this card feel tactile", and run `/tactile-design` | Manual steering file that embeds SKILL.md | 06 §3 | P0 | |
| S13 | Figma MCP setup in Kiro (URL, auth) | Add the server, fetch a frame | Images only | 06 §7 | before P4 | |
| S14 | SNAPI `news_site` multi-value format, rate limits, terms, and whether article images may appear in the video and README screenshots | Requests + read the terms | Single-select filter; record the video and screenshots against the mock fixture with your own placeholder images | 08 §3, 12 §2 | P0 | |
| S15 | Does the pinned Flutter have `SpringDescription.withDurationAndBounce`? | Compile a one-liner | kit generates mass/stiffness/damping (04 §8) | 04 §8 | P0 (tactile spike) | |
| S16 | Does the CSS → Flutter blur conversion match the browser? | Render the button, card, and modal shadow recipes as goldens; screenshot the same CSS in Chrome; compare at 4× | Tune the conversion constant once, record it in 04 §4.5 | 04 §4.5 | P0 (tactile spike) | |
| S17 | How do 0.5 px hairlines and 1 px rings render at DPR 1, 2, 3 and on Flutter Web? | Golden + device screenshots | Use `1 / devicePixelRatio` on DPR 1 screens | 04 §4.2 | P0 (tactile spike) | |
| S18 | Does iOS Safari zoom into Flutter Web text fields below 16 px, and does 16 px on touch prevent it? | Deployed test page on an iPhone | Force 16 px field text on all web builds | 04 §6.1 | P1 | |
| S19 | `NoSplash` + custom `Pressable`: keyboard activation (Enter/Space), focus traversal, screen-reader labels, `BackdropFilter` cost on web | Small test app with VoiceOver/TalkBack and Tab navigation; frame times on web | Keep Material `InkWell` semantics inside `Pressable`; no backdrop blur on web | 04 §2, §8 | P0 (tactile spike) | |
| S20 | Effort for the tactile sheet drag thresholds (min(64, 15 %) or a 0.11 px/ms flick) on top of Flutter's sheet | Prototype in the tactile spike | Flutter's default drag-to-dismiss (cut order 3) | 04 §7 | P1 | |
| S21 | Typeface fit for Plus Jakarta Sans and Space Grotesk (x-height factor, closest weight to Inter 500, tabular figures) | Side-by-side goldens at 13 px | Use Inter for that app | 04 §6.2, 08 §4, 09 §6 | before P3 | |
| S22 | Radix data fetch: parse `src/light.ts` and `src/dark.ts` at commit `dbdb854` into Dart | Run `tool/fetch_radix.dart` | Vendor the two files and parse offline | 04 §4.3 | P2 | |
| S23 | Lucide in Flutter: package maintenance, stroke weight close to 1.5 px at 16 px, licence | Render 10 icons at 14/16/20 px | Material Symbols Rounded at weight 300 | 03 §2, 04 §2 | P0 | |
| S24 | Do SNAPI article images render on the deployed web app, through `Image.network` and through `cached_network_image`, with rounded corners and the frame? (17 Nov check: 5 of 10 image hosts allow CORS, 3 don't, 2 rejected a script request) | Same Pages deploy as S8: a grid of 10 SNAPI image URLs rendered both ways | `Image.network` on web only; blocked hosts show the image fallback | 03 §2, 04 §11, 08 §1 | P0 | |
| S25 | When Kiro Crew runs a chat or a Task Runner job in this repo, do the workspace steering, skills, hooks, and Markdown agents load through its kiro-cli backend? | With the S2 blocking hook in place, ask Crew to write a file; check that it is blocked; ask which steering files and skills it sees | Crew only for task runs on its own branch; Crew's own `hooks.json` calling `tool/kit.sh guard`; CI as the last guard | 06 §6, §9 | P0 | |
| S26 | Does Kiro CLI in a project folder load the workspace steering, skills, hooks, and agents, interactively and with `--v3 --no-interactive`? Does the IDE or the CLI ask to trust the workspace before hooks run? | With the S2 hook, ask `kiro-cli` (both modes) to write a file; invoke `/tactile-design` interactively | Run the scenarios in the IDE only; the write-up says so | 02, 06 §8, 12 §3 | P0 | |

## Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Scope too large for solo in 18 days | High | High | Smaller specs; Crew runs `kit-api` in parallel; cut order in 11; record demos as you build |
| Hook behavior differs from assumptions | Medium | High | S1–S4 on day 1; CI as the final guard |
| Tactile look is hard to reproduce in Flutter (shadows, hairlines) | Medium | High | Tactile spike in Phase 0 (S15–S17, S19) |
| Agent ignores skills (doesn't activate) | Medium | Medium | `route-prompt` hook + `workflow.md` routing table + slash commands + scenarios (06 §8) |
| Agent writes CSS-like code or restyles Material widgets | Medium | Medium | `design-language.md` mapping + TAC001–TAC005 |
| Design references conflict with tactile and the agent copies them | Medium | Medium | W3 step 5 asks per conflict; scenario SC7 checks it |
| Always-on context too big (catalog grows, tactile skill loaded often) | Medium | Medium | Compact catalog mode (06 §2); tactile references load on demand |
| Image matching (locate screen) inaccurate | Medium | Low | Always confirm with the user; registry summaries + goldens; scenario SC8 |
| Article images blocked on web or by hotlink protection | Medium | Medium | S24; intentional image fallback (04 §11) |
| SNAPI down or slow while judges test Orbit (16 Dec–29 Jan) | Low | High | Offline cache of the first page (08 §3); check the API before submitting |
| Judges see an empty Tally | Low (after the fix) | High | **Load sample data** on the empty dashboard (09 §3) |
| Crew branch conflicts with IDE work | Medium | Low | Crew works on its own branch; never run Crew and the IDE on the same spec; merge daily |
| OpenAPI edge cases | Medium | Low | Subset + TODO markers; SNAPI is simple |
| Flutter Web performance/size (fonts, blur) | Low | Medium | One font weight per face; no backdrop blur on web if S19 says so |
| Third-party content not disclosed or licence notice missing | Low | High | `THIRD_PARTY_NOTICES.md`, vendored `LICENSE`, Devpost disclosure (01, 12) |
| Rule interpretation ("2 repo folders") | Low | High | Asked the organizers; split plan ready (01) |
| Running out of Kiro credits | Medium | High | Credits requested in Phase 0; `kit` scripts save tokens; headless scenarios only before recordings; avoid unattended runs that loop |
| API key leaks | Low | Medium | `KIRO_API_KEY` only in the shell environment; `.env*` gitignored; rotate the key after the hackathon |
