# Kiro journal

Running log for the Kiro write-up. One entry per working session; the template is in `docs/brief/12-submission.md` §4.

## 2026-11-17 — Phase 0, repo setup (Stage 1)
- Surface: Kiro Crew worker (item C1), driven by phase0-runbook.md Part 3
- Done: brief, .gitignore, vendored tactile-design (30495a2), root steering (5 files), Dart MCP config, dev format hook
- Versions: Flutter 3.44.8, Dart 3.12.2, Kiro CLI 3.4.0
- Notes: brief, .gitignore and the vendored skill were already committed in d08f06b, so runbook commits 1 and 2 were not repeated. The existing hook and mcp.json were rewritten to the runbook content (mcp.json now uses the absolute dart path).

## 2026-11-18 — Phase 0, spikes run with Kiro Crew (Stages 1, 5, 6, 7)
- Surface: Kiro Crew. `kirocrew-conductor` split Part 3 of phase0-runbook.md into eight work items and started one `kirocrew-worker` session per item (three at a time). The Board showed each item's state. Workers reported `progress`, `question` and `done` through the work ledger, and the conductor checked each result file with `accept_eval.py` before closing the item. Crew approval prompts and the protected-branch policy stopped `git push`, so the user pushed.
- C1 (Stage 1): repo setup, five steering files, Dart MCP config, dev format hook. The user confirmed the permission rules and the Steering list.
- C2 (S15-S17, S19): tactile spike. Plan kept for all four. The user's Chrome check found a double underline (missing Material root) and an unthemed top strip; both fixed and re-checked.
- C3 (S8, S24): web spike. The GitHub Pages run failed on account billing, so both are verified locally only. Image loading differs per host.
- C4 (S5): analyzer and generators resolve together; analyzer held at 10.2.0.
- C5 (S10): kiri_check chosen over glados.
- C6 (S14): `news_site=A,B` is the multi-value format; no licence terms; keep publisher images out of the video.
- C7 (S23): `lucide_icons_flutter` at weight 300.
- C8: results merged into brief 13, THIRD_PARTY_NOTICES.md and this journal.
- Pinned versions: Flutter 3.44.8 (stable, revision 058e0af2c2), Dart 3.12.2, DevTools 2.57.0. Phase 1 writes the Flutter version into skeleton/README.md and CI.
- Not run: Stages 2-4 (S1, S2, S3, S4, S12, S25, S26), so those rows in 13 are still empty.
