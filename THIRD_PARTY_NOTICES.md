# Third-party notices

## tactile-design
- Source: https://github.com/kosta4a/tactile-design, commit 30495a2
- Copyright: the tactile-design authors (Kosta / 4hands)
- Licence: MIT; the full text is in skeleton/.kiro/skills/tactile-design/LICENSE
- Use: vendored unchanged in skeleton/.kiro/skills/tactile-design/

Radix Colors, the fonts, the icon set, and the Spaceflight News API are added here when they enter the repo.

## Inter 4.1
- Source: https://github.com/rsms/inter/releases/tag/v4.1
- Copyright: 2016 The Inter Project Authors
- Licence: SIL Open Font License 1.1; the text is in skeleton/assets/fonts/OFL.txt
- Use: skeleton/assets/fonts/Inter-Medium.ttf (also copied into spikes/tactile_spike)

## lucide_icons_flutter 4.0.3
- Source: https://pub.dev/packages/lucide_icons_flutter
- Licence: MIT (the Lucide glyphs it bundles are ISC); the licence text was not re-checked in the pub cache
- Use: pub dependency, chosen in S23 (spikes/icon_spike/pubspec.yaml); nothing vendored

## material_symbols_icons 4.2960.0
- Source: https://pub.dev/packages/material_symbols_icons
- Licence: Apache-2.0 (font by Google)
- Use: pub dependency, S23 fallback (spikes/icon_spike/pubspec.yaml); nothing vendored

## kiri_check 1.4.0
- Source: https://pub.dev/packages/kiri_check
- Licence: Apache-2.0
- Use: dev dependency chosen in S10 (spikes/pbt_spike/pubspec.yaml); glados 1.1.7 (MIT) is the fallback; nothing vendored

## Spaceflight News API (The Space Devs)
- Source: https://api.spaceflightnewsapi.net/v4/
- Licence: none stated by the project
- Use: runtime HTTP data source only; nothing vendored. Article images belong to their publishers and are not redistributed.

## Space Grotesk 2.0.0
- Source: https://github.com/floriankarsten/space-grotesk/releases/tag/2.0.0 (SpaceGrotesk-2.0.0.zip, ttf/static)
- Copyright: 2020 The Space Grotesk Project Authors
- Licence: SIL Open Font License 1.1; the text is in skeleton/assets/fonts/OFL-SpaceGrotesk.txt
- Use: skeleton/assets/fonts/SpaceGrotesk-Medium.ttf (Orbit display and section titles)

## Plus Jakarta Sans 2.7.1
- Source: https://github.com/tokotype/PlusJakartaSans/releases/tag/2.7.1 (PlusJakartaSans-2.7.1.zip, ttf)
- Copyright: 2020 The Plus Jakarta Sans Project Authors
- Licence: SIL Open Font License 1.1; the text is in skeleton/assets/fonts/OFL-PlusJakartaSans.txt
- Use: skeleton/assets/fonts/PlusJakartaSans-Medium.ttf (Tally)

## Radix Colors (commit dbdb854)
- Source: https://github.com/radix-ui/colors, commit dbdb854
- Copyright: 2021-2022 Modulz
- Licence: MIT
- Use: colour data (sand, slate, blue, green, red, amber) fetched by skeleton/tool/radix/fetch_scales.dart into skeleton/tool/radix/radix_scales.dart
