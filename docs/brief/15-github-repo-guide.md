# 15 — GitHub repository guide: what to upload for the submission

Rules this guide implements (from the [Official Rules](https://kiroween.devpost.com/rules)): a **public GitHub**
repository; an open-source licence detected in the About section; all source, assets, and instructions needed to run
the project; `/.kiro` at the root and never gitignored; for Skeleton Crew, two separate folders for the two apps; the
project available to judges, free, until the judging period ends (29 Jan 2027).

## 1. Make the repo public from the start

- GitHub Pages on a free account works only for **public** repositories, and making a repo private unpublishes its
  Pages site ([GitHub docs](https://docs.github.com/en/pages/getting-started-with-github-pages/creating-a-github-pages-site)).
  Orbit and Tally are deployed to Pages, so the repo must be public anyway.
- Regular commits from 13 Nov onward are evidence that the project was built during the submission period.
  Don't squash the history into one commit at the end.
- Kiro Crew can import skills only from a public repo.

## 2. What goes in the repo

| Path | Commit | Notes |
|---|---|---|
| `.kiro/` (root) | ✅ required | `specs/` (skeleton-foundation, core-widgets-and-templates, kit-check-tokens, kit-api, kiro-toolkit, release, plus any `TASK_PROGRESS.md` Kiro Crew writes next to a spec), `steering/` (brief*.md, repo-conventions.md), `hooks/` (dev hooks), `settings/mcp.json`. Delete spike hooks before the final commit |
| `skeleton/` | ✅ | The product. Includes `.kiro/` (steering, skills incl. vendored `tactile-design/` with its `LICENSE`, hooks, agents, settings), `tool/kit/` (incl. `radix_colors.g.dart` with the Radix MIT notice in its header), `bricks/`, `design/tokens.yaml`, `assets/fonts/` + the fonts' `OFL.txt`, `docs/SCREENS.md`, `docs/DESIGN_TOKENS.md`, tests and goldens, `README.md` |
| `app_orbit/` | ✅ required (app 1) | Full Flutter project + its own `.kiro/` (incl. `specs/orbit/`), `api/` (incl. `demo/` fixture), `design/`, `docs/app-brief.md`, tests, goldens, `README.md` (what it is, live URL, how to run) |
| `app_tally/` | ✅ required (app 2) | Same, plus `design/references/*.png` (your own design images) |
| `tool/create_app.dart`, `tool/sync_core.dart`, `tool/scenarios/` | ✅ | Scenario prompts and `run.sh`; `KIRO_API_KEY` comes from your shell, never from a file |
| `spikes/` | ✅ | Phase 0 experiments and `baseline_app/` (the run without the toolkit); shows experimentation to judges. Keep it small |
| `docs/brief/` | ✅ | This brief; shows the planning behind the specs |
| `docs/kiro-journal.md` | ✅ | Source of the write-up. Write it in English |
| `docs/assets/` | ✅ | README screenshots and GIFs, each under ~2 MB |
| `.github/workflows/` | ✅ | `ci.yml`, `deploy-pages.yml` |
| `pubspec.lock` (skeleton and both apps) | ✅ | Reproducible builds for judges (Dart's guidance for applications) |
| Generated Dart (`*.g.dart`, `*.freezed.dart`, `injection.config.dart`, `tokens.g.dart`) | ✅ | The project builds without running codegen first; CI checks freshness |
| `LICENSE` | ✅ required | MIT, created through GitHub's licence picker so the About section shows it |
| `THIRD_PARTY_NOTICES.md` | ✅ | tactile-design (MIT, commit `30495a2`), Radix Colors (MIT), fonts (SIL OFL), icon set, Spaceflight News API attribution |
| `README.md` | ✅ | See §5 |

Golden images: keep core-widget goldens at the widget's own size (not a full window); only page views use the three
window sizes. That keeps the repo small without Git LFS.

## 3. What must never be committed

- Build output and caches: `build/`, `.dart_tool/` (includes the compiled kit binary), `ios/Pods/`, `macos/Pods/`,
  `android/.gradle/`, `android/local.properties`, `.flutter-plugins*`.
- Secrets: `env/*.json` except `env/example.json`, `android/key.properties`, `*.jks`, `*.keystore`, `*.p12`,
  `*.mobileprovision`, `.env`. Orbit and Tally need no API keys; keep it that way. If you add a Figma token, reference
  it as `${FIGMA_TOKEN}` in `mcp.json`, never the value.
- Local work: `recordings/` (videos go to YouTube), `.spike/`, `test/**/failures/`.
- Release binaries in git: APKs go to GitHub Releases. GitHub blocks files over 100 MB and warns at 50 MB.
- Third-party images you don't have rights to. Orbit loads article images from the API at runtime; none are committed.

Root `.gitignore` (each Flutter project also keeps its own generated `.gitignore`):

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

Also check your global gitignore (`git config --global core.excludesFile`) doesn't ignore `.kiro`.

## 4. Repository settings on GitHub

| Setting | Value |
|---|---|
| Visibility | Public |
| About → description | "Flutter skeleton (Clean Architecture + BLoC) with a Kiro toolkit and the tactile-design language. Two apps built from it." |
| About → website | The GitHub Pages landing page that links both apps |
| About → topics | `flutter`, `dart`, `kiro`, `kiroween`, `clean-architecture`, `bloc`, `boilerplate`, `design-system` |
| About → licence | Shows "MIT license" (if not, the `LICENSE` file isn't in the root or isn't the standard MIT text) |
| Settings → Pages → Source | GitHub Actions (used by `deploy-pages.yml`) |
| Settings → Actions | Enabled |
| Releases | `v1.0.0` with both APKs (§6) |

## 5. README for judges

1. Title, one-line pitch, CI and licence badges.
2. Links: **Orbit (live)**, **Tally (live)**, **demo video (YouTube)**, blog post.
3. Category: Skeleton Crew. What the skeleton is, and that the two applications built from it are in
   **`app_orbit/`** and **`app_tally/`** (say it explicitly; it's a rule).
4. How the two apps differ (data, interaction, tokens), with 2–4 screenshots.
5. How to test: live URLs (no login; in Tally, tap **Load sample data**), Android APKs in Releases, and local commands:
   ```bash
   git clone https://github.com/<you>/flutter-kiro-skeleton && cd flutter-kiro-skeleton/app_orbit
   flutter pub get && flutter run -d chrome
   ```
6. Quick start for developers: `dart run tool/create_app.dart my_app`, then open `my_app/` in Kiro.
7. How Kiro was used: a short summary plus links to `.kiro/` (root), `skeleton/.kiro/`, `app_orbit/.kiro/`,
   `app_tally/.kiro/`, the specs, and the write-up.
8. Credits and disclosure of pre-existing work (text in `12-submission.md` §1).
9. Licence.

## 6. Releases and live apps

- Tag the submission commit `v1.0.0` and create a GitHub Release "Kiroween 2026 submission" with `orbit.apk` and
  `tally.apk` attached, plus short notes.
- Live URLs (from `deploy-pages.yml`): `https://<you>.github.io/flutter-kiro-skeleton/` (landing),
  `/orbit/`, `/tally/`.
- Keep the repo public, Pages live, the release, and the video public at least until winners are announced
  (around 3 Feb 2027). The judging period ends 29 Jan 2027.

## 7. Final verification (3–4 Dec, on the final commit)

Run from the repo root:

```bash
# 1. Every .kiro folder is tracked: each line must show more than 0 files
for d in .kiro skeleton/.kiro app_orbit/.kiro app_tally/.kiro; do echo "$d: $(git ls-files "$d" | wc -l) files"; done

# 2. Nothing inside a .kiro folder is ignored: expect no output
git status --ignored --porcelain | grep '\.kiro/'

# 3. No secrets or local files are tracked: expect no output
git ls-files | grep -E '(^|/)(\.env|key\.properties)$|\.(jks|keystore|p12|mobileprovision)$|/env/(dev|prod|staging)\.json$|^recordings/|\.spike/'

# 4. Largest tracked files: keep each under ~10 MB
git ls-files -z | xargs -0 du -k 2>/dev/null | sort -rn | head -10

# 5. GitHub detects the licence: expect MIT
gh api repos/<you>/flutter-kiro-skeleton --jq '.license.spdx_id'

# 6. A fresh clone builds and passes tests
rm -rf /tmp/fks && git clone --depth 1 https://github.com/<you>/flutter-kiro-skeleton /tmp/fks
for p in skeleton app_orbit app_tally; do
  (cd "/tmp/fks/$p" && flutter pub get && flutter test --exclude-tags golden && flutter build web) || echo "FAILED: $p"
done
```

Then by hand:
- Open both live URLs in a private browser window on a phone, at tablet width, and on desktop.
- Install the Orbit APK on an Android phone and run Orbit on macOS: articles load (platform setup in `03` §5).
- The YouTube video is **Public** (not Unlisted or Private), under 3 minutes, without copyrighted music.
- The README links all work.
- Every item in `01-hackathon-requirements.md` is checked.

## 8. Devpost form: where each item comes from

Field names on the form may differ. If a field doesn't exist, put the content in the project description.

| Devpost item | Content | Source |
|---|---|---|
| Project name, tagline | flutter-kiro-skeleton; "A Flutter skeleton that teaches your AI agent to ask first." | `12` §1 |
| Project story | Inspiration, what it does, how it was built, challenges, accomplishments, lessons, what's next | `12` §1 |
| Built with | flutter, dart, kiro, bloc, go-router, dio, freezed, drift, github-actions, github-pages, spaceflight-news-api | — |
| Try it out links | Orbit URL, Tally URL, repo URL | §6 |
| Image gallery + thumbnail | 4–6 screenshots; JPG/PNG/GIF, ≤ 5 MB, 3:2 ratio works best ([Devpost help](https://devpost.helpscoutdocs.com/article/126-know-your-submission-steps)) | `docs/assets/` |
| Video | YouTube URL | `12` §2 |
| Category | Skeleton Crew | `01` |
| Repository URL | `https://github.com/<you>/flutter-kiro-skeleton` | — |
| App URLs and testing instructions | No login needed; APKs in Releases; local run commands | README §5 |
| Kiro write-up | 9 sections | `12` §3 |
| Pre-existing work | Credits paragraph | `12` §1 |
| Best Student Project | LinkedIn profile, student email, year and degree, school name | `12` §7 |
| Bonus (optional) | Blog URL, social post URL | `12` §5–6 |

Start a Devpost draft in Phase 0 with placeholders and save it often.

## 9. After you submit

- Don't push to `main`, move the `v1.0.0` tag, or redeploy Pages until judging ends. The rules only allow changes the
  organizers permit after the deadline. Continue on a branch such as `next`.
- Don't rename the repo or make it private: the submitted URLs and the Pages site would break.
