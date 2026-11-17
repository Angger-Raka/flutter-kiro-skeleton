# 09 — Demo app 2: Tally (design-driven)

**Tally** is a personal expense and budget tracker that works fully offline. It proves the skeleton handles local
data and forms with tactile defaults (sand neutral, designed light-first; it follows the device theme until the user
picks one), and it is the stage for the `design-to-ui`,
`ui-update`, `promote-widget`, and `ui-reviewer` demos.

## 1. How Tally differs from Orbit

| | Orbit | Tally |
|---|---|---|
| Data | Remote REST API | Local SQLite (drift) |
| Interaction | Browse/read | Create/edit/delete, forms, validation |
| Main toolkit demo | api-intake, api-update | design-to-ui, ui-update, promote-widget, ui-reviewer |
| Tokens | remapped: slate, dark-first, Inter + Space Grotesk headings, radius 6 | tactile defaults: sand, light-first, Plus Jakarta Sans, radius 8, identity hues for categories |
| Extra packages | none | `drift`, `drift_flutter`, `sqlite3_flutter_libs` |

## 2. Data model

Money is stored as **integer minor units** (`amountMinor`) plus the currency's decimal digits from settings
(IDR = 0, USD = 2). Never `double` for money.

| Table | Columns |
|---|---|
| `categories` | id (uuid text), name, icon_key, identity_index (int, into `hues.identity`), kind (expense/income), sort_order, archived (bool) |
| `transactions` | id, kind (expense/income), amount_minor (int), category_id → categories, occurred_on (date), note (nullable, ≤ 140 chars), created_at, updated_at, is_sample (bool) |
| `budgets` | id, category_id, month (text `YYYY-MM`), limit_minor (int), is_sample (bool); unique (category_id, month) |

Seeds: 8 expense categories (Food, Transport, Shopping, Bills, Health, Entertainment, Education, Other) and
3 income categories (Salary, Gift, Other). Each gets an identity hue (`identity_index`), cycling through the list.

**Sample data** (for judges and demos): `SampleDataService` in `lib/core/database/` generates 90 days of transactions
with realistic IDR amounts across the seeded categories, plus budgets for the current month where one is near its
limit and one is over. It uses a fixed seed, marks every row `is_sample`, and runs only when the user asks.

Database placement: `lib/core/database/` in Tally (an app-level addition to core) holds table definitions and
`AppDatabase`. Each feature has its own DAO + local data source on those tables and its own entities, so features
never import each other.

Web: drift needs `sqlite3.wasm` and a worker in `web/` **[VERIFY S7]**. Fallback: `hive_ce` behind the same
repository interfaces (domain and presentation unchanged).

## 3. Features and screens

| Feature | Screens (route name — path) | Content |
|---|---|---|
| `dashboard` | `dashboard` — `/` | `PeriodSwitcher` right of the section title; one data card with three `Figure`s (Net, Income, Expense; 32 apart); "Budgets" card of `Meter`s (spent / limit, identity hue, red at ≤ 10 % left); "Last 30 days" card with `AppBarChart` (daily spending); "Recent transactions" with the last 5 `AppRow`s and "View all" after them |
| `transactions` | `transactions` — `/transactions`; `transaction_form` — `/transactions/new`, `/transactions/:id/edit` | Rows grouped by day (day header in `meta`), filter pills (kind, category), search notes; form: `AppSegmented` (Expense / Income), amount field (tabular, 16 on touch), category picker (`AppChoiceTiles`), date, note; **Save** is the form's one primary; delete = destructive trigger → `showConfirm` ("Delete this transaction?" / "Yes, delete") → `AppToast` "Transaction deleted" with **Undo** |
| `budgets` | `budgets` — `/budgets`; `budget_form` — `/budgets/:categoryId?month=` | `PeriodSwitcher`; one `Meter` row per category; a danger badge "Over by Rp 50.000" when spent > limit |
| `categories` | `categories` — `/settings/categories` | Add, rename, archive; icon + identity hue from the token palette |
| `settings` | `settings` — `/settings` | Currency (IDR default, USD, EUR), language (System by default, English, Bahasa Indonesia), theme with `ThemeModeSwitch` (System by default, Light, Dark), **Delete all data**, export CSV (stretch), about |

Navigation: Dashboard · Transactions · Budgets · Settings. **Add transaction** is a page action: a secondary button in
the top strip on tablet/desktop, an `AppPill` "+ Add" in the mobile top bar. No floating action button. The form's
**Save** is the primary.

### Empty state and sample data
- Empty dashboard: `EmptyState` "No transactions yet." / "Add your first one, or load sample data to look around.",
  with **Add transaction** (primary) and **Load sample data** (secondary).
- While sample rows exist, an info notice at the top of the dashboard says "You're looking at sample data." with
  **Delete sample data** (secondary), which removes only `is_sample` rows.
- Settings → **Delete all data**: a destructive trigger, then `showConfirm` ("Delete all data?" / "This removes every
  transaction and budget on this device." / "Yes, delete").
- This is the decision-log exception to tactile's "never show fake data": the user starts it, it is labelled, and it
  can be deleted.

Amount colours (hue carries meaning only): income in info-11 ("money in", as in tactile's source product), expense in
ink-12, over budget in danger-11. Signs use "+" and the real minus "−". `AmountText` handles formatting.

Localization: English + Bahasa Indonesia. Indonesian strings are often longer, which exercises the resilience rules.
Copy rules apply to both ARB files (sentence case, "…", no em dash).

### Adaptive layout
| | Mobile | Tablet | Desktop |
|---|---|---|---|
| Dashboard | one column | figures card full width; budgets + bars side by side; recent below | data column (1200): same as tablet with wider cards |
| Transactions | rows | rows + filter row | rows + filter row (side panel for editing is stretch) |
| Forms | `AppSheet` (tall) | `AppDialog` 620 | `AppDialog` 620 |

### Core widgets created during Tally (new core, synced back to the skeleton)
`Figure`, `Meter`, `AppBarChart`, `AmountText`, `PeriodSwitcher`, `AppChoiceTiles` (and `TransactionRow` if the
ui-update demo picks option b).

## 4. Design references (must exist before Phase 4)

`design-to-ui` needs real input images. Create them in Figma (preferred; also enables the Figma MCP demo) at mobile
size (390×844), light theme. **Make them quickly and do not follow tactile perfectly.** Three planted conflicts give
the agent something real to catch:

| File | Screen | Must contain |
|---|---|---|
| `design/references/dashboard/dashboard.1.png` | Dashboard | period switcher, big net amount, category bars, daily bars, "Recent" rows. **Planted conflicts:** bold section titles, a green filled "Add" plus a second filled "Export" button, 18 px card padding |
| `design/references/transactions/transactions.1.png` | Transactions | day group headers, the **same row** as the dashboard |
| `design/references/transactions/transaction_form.1.png` | Add transaction | kind toggle, amount field, category grid, date, note |
| `design/references/budgets/budgets.1.png` | Budgets | the **same period switcher** as the dashboard (reuse demo), category bars |
| `design/references/transactions/transactions.2.png` | Updated row | category badge instead of icon + note line (sent later, without saying where) |

Optional: share the Figma file read-only and link it in the README.

## 5. Toolkit demo moments (scripted)

1. **Conflicts (P7):** dashboard first → the decision sheet flags the planted conflicts and asks; the user answers
   "follow the system".
2. **Reuse (P3):** the dashboard creates `PeriodSwitcher` in core. Send `budgets.1.png` without mentioning it → the
   classification table says **reuse** (similarity 0.9+).
3. **Promote (P2):** a category badge is first built inside `transactions` (it takes the `Category` entity). Budgets needs
   it → the cross-feature import is blocked by the guard → `promote-widget` moves it to core as
   `CategoryBadge(label, iconKey, identityIndex)` built on `AppBadge`.
4. **Update without location (P5):** send `transactions.2.png` with "update this" → the agent lists the 2 candidate
   screens and the 4 usages of the row and asks.
5. **Resilience (P6):** category "Pendidikan dan Pengembangan Diri Anak" + amount "Rp 1.250.000.000" at text scale 2.0
   on 320 px → a stress test catches the overflow in a first draft; the amount switches to compact notation with a tooltip.
6. **Review (P7):** `/ui-reviewer` on the dashboard in dark mode → Changed / Moved / Flag report → the user accepts two fixes.

## 6. Visual identity (`app_tally/design/tokens.yaml`)

```yaml
neutral: sand
hues: { accent: jade, success: green, danger: red, warning: amber, info: blue,
        identity: [cyan, violet, plum, pink, lime, purple] }
primary: neutral
typography:
  sans: { family: Plus Jakarta Sans, files: [assets/fonts/PlusJakartaSans-Medium.ttf], weight: 500 }
  size_factor: <from typeface fit, S21>
radius_control: 8
```
- Accent jade is within 25° of green, so it becomes the success scale; the brand colour itself appears only in the
  app icon and splash.
- `kit tokens` validates the identity list against status hues (TAC010). With jade as the success scale (171°), all six
  listed hues are at least 30° from every status hue (the closest pair is cyan and blue; teal would be only 11° from jade).
- 11 categories share 6 identity hues in order; the icon and label tell categories with the same hue apart.
- Font: Plus Jakarta Sans (SIL OFL), one static weight chosen by the typeface-fit test.
- Branding: app icon (a tally mark on the sand ground), splash, and web loading screen; `og.png` for link previews.

## 7. Acceptance criteria

1. All screens built through `design-to-ui` / `ui-update` from the reference images; decision sheets, classification
   tables, and conflict answers saved in each feature's `FEATURE.md` → Decisions.
2. Works offline on web (deployed), Android, iOS, macOS; data persists across restarts (web: OPFS/IndexedDB via drift).
3. Money correct: unit tests + property tests (sum of transactions = dashboard totals for random data; formatting
   round-trips per currency).
4. No overflow at stress sizes in both languages and both themes; goldens at 3 window classes.
5. Undo delete works; budgets and dashboard update live after a change.
6. `kit check` clean, including TAC rules; `/ui-reviewer` report has no open Flags.
7. A judge can open the deployed app, tap **Load sample data**, and see a filled dashboard, budgets, and transactions;
   **Delete sample data** removes only those rows.
