# 10 — Quality, CI, and deployment

## 1. Test types

| Type | Where | Required for |
|---|---|---|
| Unit | `test/**` | mappers, usecases, repositories (mock data sources), formatters, settings, `kit` |
| Bloc | `bloc_test` | every bloc/cubit (TEST001) |
| Widget | `XView` with mock blocs | every page view: each state renders |
| Stress | `stressTest`: profile `quick` locally, `full` in CI (`04` §12) | every core widget and page view (UI005) |
| Accessibility | `flutter_test` guideline matchers inside the stress harness (`04` §12) | every core widget and page view |
| Golden | tag `golden`, generated and compared on the developer's Mac | every core widget; every page view × 3 window classes × light and dark, at device pixel ratio 2 |
| Property-based | Kiro spec correctness properties + the library chosen in S10 | `kit` (tokens, diff, gen-dto), Tally money logic, `stressProperty` |
| Integration | `integration_test/` | one happy path per app (Orbit: open an article; Tally: load sample data → the dashboard shows totals) |
| Template | CI job | `create_app` output passes analyze, check, and test |
| Toolkit scenarios | Kiro IDE and Kiro CLI (`06` §8) | before each demo recording and before release |

Coverage is not a target; the required tests above are.

## 2. GitHub Actions

### `.github/workflows/ci.yml` (push + PR)

Matrix over `skeleton`, `app_orbit`, `app_tally` (path filters so unchanged projects are skipped), Ubuntu:
1. Checkout, set up Flutter (version pinned in `skeleton/README.md`), cache pub.
2. `flutter pub get` → `dart run build_runner build -d`.
3. `git diff --exit-code` (generated code committed and fresh).
4. `flutter analyze --fatal-infos`.
5. `dart run kit:kit tokens --check` and `dart run kit:kit check --all` (fail on errors, including PLAT001–PLAT002).
6. `flutter test --exclude-tags golden --dart-define=STRESS=full`; upload `failures/` as an artifact on failure.
7. `flutter build web --release --base-href /<repo>/<app>/` (apps only).

Goldens are not compared in CI, because font rendering differs between macOS and Linux (`04` §12).

Extra jobs:
- `kit-tests`: `dart test` in `skeleton/tool/kit`.
- `template`: `dart run tool/create_app.dart ci_app --out /tmp` → analyze, check, test.
- `android` (apps, on `main` only): `flutter build apk --release` → artifact.

### `.github/workflows/deploy-pages.yml` (`main`)
Build both apps for web and publish to GitHub Pages:
- `https://<user>.github.io/flutter-kiro-skeleton/orbit/`
- `https://<user>.github.io/flutter-kiro-skeleton/tally/`
- Root `index.html`: a landing page linking both apps, the video, and the repo.

SPA routing on Pages: `usePathUrlStrategy` + a copy of `index.html` as `404.html`, or hash URLs (S8).

## 3. Platform builds (manual, on the Mac)

| Platform | How | When |
|---|---|---|
| Web | CI | every push |
| Android | CI APK + a manual run on an emulator or phone; the release APK must load data (`03` §5) | Phases 3–5 |
| iOS | `flutter build ios --no-codesign` + a run on the simulator; device optional | Phases 3–5 (video footage) |
| macOS | `flutter run -d macos`; needs the network client entitlement (`03` §5) | Phase 5 (desktop footage) |
| Windows/Linux | compile in CI only if time allows | stretch |

Release artifacts in GitHub Releases: Android APKs for both apps (debug-signed release builds are fine for judging).

## 4. Definition of done (any task)

- `flutter analyze` clean, `kit check` without errors, tests pass (stress profile `quick`), generated files fresh.
- New or changed UI: stress test, goldens updated on the Mac (`flutter test --tags golden`), looks right at
  375/834/1440 px in light and dark, TAC rules clean, no open `/ui-reviewer` Flags for screens shown in the video.
- `FEATURE.md` / `api_map.yaml` / `CHANGELOG.md` updated when relevant.
- Before recording a demo: the matching toolkit scenario passes (`06` §8).
- `docs/kiro-journal.md` entry if Kiro did something worth mentioning (good or bad).
