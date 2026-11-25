# Radix scales

`radix_scales.dart` holds the Radix Colors scales the token generator reads: sand, slate, blue, green, red, and amber
(12 light steps, 12 dark steps, and alpha steps a3 and a4 for each).

- Source: https://github.com/radix-ui/colors, commit `dbdb854` (`src/light.ts`, `src/dark.ts`), MIT.
- No colour is typed by hand. The file is written by `fetch_scales.dart`.
- Re-run from `skeleton/` (needs network): `dart run tool/radix/fetch_scales.dart`
- To change the commit or the scale list, edit the constants at the top of `fetch_scales.dart` and re-run.

`kit tokens` (Phase 2) replaces this stand-in with the full scale set.
