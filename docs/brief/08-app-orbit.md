# 08 — Demo app 1: Orbit (API-driven)

**Orbit** is a spaceflight news reader. It proves the skeleton handles a remote, paginated, searchable API, and it
is the stage for the `api-intake` and `api-update` demos. It uses tactile-design with a **remapped** brand
(slate neutral, designed dark-first, a heading face), while Tally keeps the tactile defaults. Like every app from the
skeleton, it follows the device theme until the user picks Light or Dark.

## 1. Data source

[Spaceflight News API (SNAPI) v4](https://api.spaceflightnewsapi.net/v4/docs/) by The Space Devs.
Checked 13 Nov 2026:
- OpenAPI 3.0.3 at `https://api.spaceflightnewsapi.net/v4/schema/` (spec version 4.37.1). 7 operations:
  `articles_list`, `articles_retrieve`, `blogs_list`, `blogs_retrieve`, `reports_list`, `reports_retrieve`, `info_retrieve`.
- No auth, no API key. Responses send `Access-Control-Allow-Origin: *`, so Flutter Web works directly.
- Article images come from many news sites. A check of 10 image hosts on 17 Nov 2026: 5 allow CORS, 3 don't, and 2
  rejected a script request (403). On web, `AppNetworkImage` relies on Flutter's `<img>` fallback (S24), and some
  articles will show the image fallback (`04` §11).
- List params include `limit`, `offset`, `search`, `ordering`, `title_contains`, `news_site`, `published_at_gte/lte`, `is_featured`.
  Paginated responses: `count`, `next`, `previous`, `results`.
- `Article`: id, title, authors, url, image_url, news_site, summary, published_at, updated_at, featured, launches, events.
- `info_retrieve` returns `version` and `news_sites` (used for the filter).

Attribution: "News data from Spaceflight News API by The Space Devs" in Settings and README.
No licence or terms page is published (S14). Article `image_url` points at the publishers' servers, so real article
images and titles stay out of the demo video and screenshots; use placeholders. Send a custom `User-Agent` (the default
Python one got a 403) and cache responses for about 10 minutes (`cache-control: max-age=600`).

## 2. Demo fixture for `api-update`

The real API won't change during the hackathon, so the app includes `api/demo/openapi.v1.yaml`: a trimmed,
older-looking version of the spec, clearly labelled as a demo fixture in `info.description` and in the README, with:
- only `articles_list`, `articles_retrieve`, `info_retrieve`;
- camelCase fields `newsSite`, `imageUrl`, `publishedAt`, `updatedAt` (SNAPI v3 used camelCase);
- no `featured` field.

Sequence: intake with v1 → later `api-update` with the real v4 spec → the impact report shows the renames, the new
`featured` field, and 4 unmapped operations → the user adds `blogs`.

The deployed app always talks to the real v4 API. For the v1 part of the recording, either point the data source at a
JSON fixture server (`dart run tool/mock_server.dart api/demo/fixtures/`) or record only code generation. Decide in Phase 3.

## 3. Features and screens

| Feature | Source | Screens (route name — path) | Notes |
|---|---|---|---|
| `articles` | api | `articles` — `/articles`; `article_detail` — `/articles/:id`; `bookmarks` — `/saved` | Bookmarks live in `articles` (local data source), so no cross-feature import |
| `blogs` | api | `blogs` — `/blogs`; `blog_detail` — `/blogs/:id` | Added during the api-update demo; reuses the Orbit-created core widgets |
| `settings` | local | `settings` — `/settings` | Theme with `ThemeModeSwitch` (System by default, Light, Dark), about + attribution, licences |

Destinations: News · Blogs · Saved · Settings (bottom tab bar on mobile, rail on tablet/desktop).

### `articles` behavior (tactile applied)
- **List page** (data column): newest first (`ordering=-published_at`), page size 20, infinite scroll, pull to refresh.
  No primary action on the page.
- **Toolbar** above the list, one row: a `FilterPill` "News site" and `SearchField` at the right.
  Mobile: search first (full width, raised in light), the filter row under it scrolls sideways with 20 px edge fades.
- **Search:** `search` param, 400 ms debounce, restartable, clear button.
- **Filter:** the pill opens a picker with `AppChoiceList` (checkbox rows) from `info_retrieve` and a primary **Apply**
  (the one primary inside the picker; faint while nothing changed). Desktop/tablet: `AppDialog` (460) until `AppMenu`
  exists; mobile: `AppSheet`. Once applied, the pill reads "News site NASA, SpaceNews" (label ink-10, value ink-12,
  value truncates at 180 px) with a × to clear. Multi-value format: one comma-separated param, `news_site=A,B` (union); never a repeated key (S14).
- **Detail:** 16:9 hero image with a 0.5 px frame; title as `display` (24/32 on mobile when it wraps past 2 lines);
  news site + date as `meta`; summary as `body` capped at 70 ch in the reading column; one primary
  **Read full article** (it leaves the app, so it gets the external-link arrow); **Save** as a secondary toggle;
  **Copy link** as an `AppPill` with the tick feedback (no toast).
- **Saved:** bookmarks stored via `KeyValueStore` as JSON snapshots (id, title, imageUrl, newsSite, publishedAt).
  Works offline. Empty state: "No saved articles yet." / "Save an article and it will appear here."
- **Offline fallback:** after each successful load, the first page of the list and the news-site list are cached in
  `KeyValueStore`. If a reload fails and a cache exists, the cached items show with an info notice ("You're offline.
  Showing articles from 10:42.") and a secondary "Try again". Without a cache, `ErrorView`.
- **States:** skeleton rows while loading (page size, max 10), `EmptyState` for no results ("No articles match
  'xyz'." / "Try another word, or clear the filter."), `ErrorView` with "Try again", an end-of-list line in `meta`.

### Adaptive layout
| | Mobile | Tablet | Desktop |
|---|---|---|---|
| Articles | list of `MediaCard.horizontal` | 2-column grid of `MediaCard` | list (400 px) + detail pane (reading column); `/articles/:id` selects the item |
| Detail | full screen | full screen in the reading column (800) | inside the right pane |
| Filter picker | `AppSheet` | `AppDialog` 460 | `AppDialog` 460 (or `AppMenu` if built) |

### Core widgets created during Orbit (new core, synced back to the skeleton)
`MediaCard`, `AppNetworkImage`, `PagedListView`, `AppChoiceList`, `FilterPill`. Each is classified as **new core** by
`design-to-ui` or `api-intake` (W1 step 8), with catalog block, stress test, and goldens.

## 4. Visual identity (`app_orbit/design/tokens.yaml`)

```yaml
neutral: slate
hues: { accent: blue, success: green, danger: red, warning: amber, info: blue, identity: [] }
primary: neutral          # near-white primary in dark mode
typography:
  sans: { family: Inter, files: [assets/fonts/Inter-Medium.ttf], weight: 500 }
  heading: { family: Space Grotesk, files: [assets/fonts/SpaceGrotesk-Medium.ttf], weight: 500 }   # display + section only
radius_control: 6
```
- Accent blue sits within 25° of info blue, so the collision rule makes it the info scale. Brand blue appears only as
  info tints, for example the "Featured" badge.
- News-site labels are neutral badges. No identity hues.
- Fonts: Inter and Space Grotesk, both SIL OFL, bundled.
- Branding: app icon (a simple orbit mark on the slate ground), splash, and web loading screen in the same colours;
  `og.png` for link previews.

## 5. Acceptance criteria

1. Built through the toolkit in Kiro: `FEATURE.md` for each feature, `api_map.yaml` complete (FEAT003 clean).
2. Works on web (deployed), Android, iOS, macOS.
3. No overflow at all stress sizes; goldens for all views at 3 window classes, light and dark.
4. Desktop list-detail works with browser back/forward and deep links (`/articles/123`).
5. Offline: Saved opens without network; the list shows the cached first page with the offline notice, or `ErrorView`
   with "Try again" when nothing is cached.
6. `kit check` clean, including TAC rules; `/ui-reviewer` report has no open Flags.
7. Web first load under 5 s on a normal connection (measure; optimize only if bad).
8. The release APK and the macOS build load articles (`03` §5). The deployed web app shows each image or the
   intentional fallback, never a broken layout.
