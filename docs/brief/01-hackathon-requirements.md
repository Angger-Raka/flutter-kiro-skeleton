# 01 — Hackathon requirements (Kiroween 2026)

Sources: [Overview](https://kiroween.devpost.com/), [Official Rules](https://kiroween.devpost.com/rules),
[Resources](https://kiroween.devpost.com/resources). Checked on 13 Nov 2026. Re-check the Updates tab weekly.

## Dates

| Item | Date (Pacific) | Date (WIB) |
|---|---|---|
| Submission period | 30 Oct 2026 09:00 – 4 Dec 2026 14:00 | until 5 Dec 05:00 |
| Kiro credit request deadline | 1 Dec 2026 12:00 | 2 Dec 03:00 |
| Credit redemption deadline | 4 Dec 2026 | |
| Judging | 16 Dec 2026 – 29 Jan 2027 | |
| Winners | ~3 Feb 2027 | |

No extensions. Late submissions are rejected. Internal target: submit by **4 Dec 2026 20:00 WIB**.

## Skeleton Crew definition

> Build a skeleton code template lean enough to be clear but flexible enough to support various use cases.
> Show us its versatility with two distinct applications from your foundation.

Implications:
- "Lean enough to be clear": keep `skeleton/lib` small. Ship only what every app needs. App-specific
  packages (for example `drift`) are added in the app, not in the skeleton.
- "Two distinct applications": Orbit and Tally differ in data source, interaction pattern, and visual identity.

## Submission checklist

### Eligibility
- [ ] All code written during the submission period (planning started 13 Nov 2026; code starts 17 Nov 2026).
- [ ] Age: at least the age of majority in your country of residence at the time of entry (rules §3). If you are
      unsure how this applies to you, ask the hackathon manager before submitting.
- [ ] Pre-existing work disclosed in the Devpost description and README: the tactile-design skill (MIT, vendored at
      commit `30495a2`), Radix Colors data (MIT), fonts (SIL OFL), the icon set. No other pre-existing code.
      Standard libraries/frameworks are allowed.
- [ ] Every vendored or bundled third-party item keeps its licence notice (`THIRD_PARTY_NOTICES.md`, the skill's `LICENSE`).
- [ ] Third-party APIs used within their terms (Spaceflight News API is free and public; credit it in Orbit's About screen and README).

### Repository
- [ ] Public GitHub repository (not GitLab/Bitbucket).
- [ ] Open source license file (MIT) detected and shown in the repo **About** section.
- [ ] `/.kiro` directory at the repo root containing specs, steering, hooks. **Not** in `.gitignore`
      (check every `.gitignore`, including the ones Flutter generates).
- [ ] Two separate folders for the two applications: `app_orbit/` and `app_tally/`.
- [ ] All source, assets, and instructions needed to run the project.

### Devpost form
- [ ] Category: Skeleton Crew.
- [ ] URLs to working apps (GitHub Pages for both). No login needed.
- [ ] Text description of features and functionality.
- [ ] Demo video: under 3 minutes, public on YouTube, shows the apps running on their target devices,
      no copyrighted music or third-party trademarks without permission.
- [ ] Write-up on how Kiro was used (see `12-submission.md`).
- [ ] Optional bonus: blog post (mention Kiroween 2026), social post starting with `#KiroweenHackathon26`.
- [ ] **Best Student Project: Skeleton Crew** (a bonus prize; it stacks with a category or overall prize): LinkedIn
      profile, student email, year and degree, school name (`12` §7). Keep proof of enrollment ready.

What to commit, repo settings, and the final verification commands are in `15-github-repo-guide.md`.

### Open question (asked on Discord/Devpost)
- Whether "2 separate repo folders" means two folders in one repo (assumed) or two repos.
  If the answer is "two repos", split `app_orbit` and `app_tally` into their own repos, keep the
  monorepo as the skeleton repo, and link all three in the submission.

## Judging (stage 2, 20% each)

| Criterion | How this project scores |
|---|---|
| Potential Impact | Real, common pain for solo devs using AI agents; skeleton usable on day one |
| Technological Implementation | 8 specs with EARS requirements, Analyze Requirements, and Kiro's property-based correctness tests; steering with 3 inclusion modes; skills; hooks as guards; custom agents; MCP (Dart, Figma); the Playwright power; toolkit scenarios in Kiro CLI; IDE + CLI + Web + Crew used for different jobs |
| Design | Both apps polished and adaptive across Mobile/Tablet/Desktop; consistent tokens |
| Innovation | The toolkit itself: deterministic guards around an agent, catalog + registry as agent memory, API impact analysis |
| Presentation | Video shows each failure and the toolkit preventing it, side by side |

Stage 1 is pass/fail on fitting the category and using Kiro sufficiently. The `/.kiro` folder and write-up cover this.
